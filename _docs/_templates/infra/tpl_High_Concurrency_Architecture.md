# 🚀 高併發系統與基礎設施架構規劃書 (High-Concurrency Architecture)

> **建立日期**：{{CURRENT_DATE}}  
> **專案代號**：{{PROJECT_KEY}}  
> **負責人**：{{AUTHOR}}  
> 
> 💡 **關聯文檔**：
> - [[_docs/_templates/tpl_ADR|🏛️ 架構決策紀錄 (ADR)]]
> - [[_docs/_templates/infra/tpl_Host_Maintenance_SOP|🛠️ 主機維運 SOP]]
> - [[_docs/context/02_技術研究與分析/patterns/pat_async_mq_upsert|⚡ 異步隊列與原子 Upsert 設計模式]]

---

## 🌐 1. 全域高併發流量架構拓撲圖 (Mermaid)

```mermaid
flowchart TD
    Client["📱 終端使用者 / 前端 SPA"] -->|HTTPS / DNS 智慧分流| Edge["🛡️ 邊緣層 (Cloudflare WAF / CDN)"]
    
    subgraph EdgeLayer["邊緣加速與防護 (Edge & Security)"]
        Edge -->|靜態資產命中 / 快取| EdgeCache[("⚡ 邊緣快取 (HTML/CSS/JS/圖片)")]
        Edge -->|API 動態請求 / 安全通道| Tunnel["🚇 Cloudflare Tunnel / 專線"]
    end

    Tunnel --> Gateway["⚖️ 負載平衡器 (Nginx / HAProxy / Cloud LB)"]

    subgraph AppCluster["無狀態應用服務叢集 (Stateless App Tier)"]
        Gateway --> App1["⚙️ App 節點 1 (API Server)"]
        Gateway --> App2["⚙️ App 節點 2 (API Server)"]
        Gateway --> AppN["⚙️ App 節點 N (水平自動擴展)"]
    end

    subgraph CacheAndMQ["快取與削峰解耦層 (Cache & MQ Tier)"]
        App1 & App2 & AppN -->|讀取高頻資料| RedisCache[("⚡ Redis 快取叢集 (Session/Hot Data)")]
        App1 & App2 & AppN -->|非同步寫入/突發流量| MQ["📬 訊息隊列 (RabbitMQ / Kafka)"]
    end

    subgraph WorkerTier["非同步處理叢集 (Background Workers)"]
        MQ --> Worker1["👷 消費者 Worker 1"]
        MQ --> Worker2["👷 消費者 Worker 2"]
    end

    subgraph DataStorage["持久化資料庫層 (Data Storage Tier)"]
        App1 & App2 & AppN -->|只讀查詢 (Read)| DBReplica[("📖 DB 從庫 (Read Replica / 唯讀)")]
        Worker1 & Worker2 -->|原子 Upsert 寫入 (Write)| DBPrimary[("✍️ DB 主庫 (Primary Master)")]
        DBPrimary -.->|主從同步 (Replication)| DBReplica
    end
```

---

## 📊 2. 流量與容量預估 (Capacity & Concurrency Target)

| 指標項目 | 基準現況 (Baseline) | 目標峰值 (Target Peak) | 應對架構策略 |
| :--- | :--- | :--- | :--- |
| **QPS / RPS** | 50 ~ 100 req/s | 2,000 ~ 5,000 req/s | CDN 快取靜態請求 + Redis 抵擋 80% 讀取 |
| **並行連線數 (Connections)** | 500 連線 | 10,000+ 連線 | Nginx epoll 最佳化 + Keep-Alive 連線池 |
| **寫入峰值 (Write Burst)** | 10 TPS | 500+ TPS | RabbitMQ 異步隊列削峰 + Worker 批量原子 Upsert |
| **P99 延遲目標** | < 1,500 ms | < 200 ms | 讀寫分流 + 慢查詢索引加固 |

---

## ⚡ 3. 核心分層架構設計規範

### 3.1 邊緣與負載平衡層 (CDN & Load Balancer)
- **邊緣防護**：開啟 Cloudflare WAF、DDoS 防護與 Bot Fight Mode。
- **靜態快取**：前端靜態構建檔案（`.js`, `.css`, 圖片、字體）快取 TTL 設為 30 天，啟用版本雜湊（Cache Busting）。
- **LB 負載均衡演算法**：優先採用 `least_conn`（最小連線數）或 `ip_hash`（會話綁定）；對於無狀態 API 採用 `round-robin`。

### 3.2 應用服務層 (Stateless Application)
- **無狀態化原則**：所有應用節點不得儲存本地 Session，使用者狀態一律交由 JWT 或集中式 Redis 存放。
- **連線池復用**：資料庫與 Redis 連線禁止頻繁新建，採用持久連線池（Connection Pool）避免 TIME_WAIT 端口耗盡。

### 3.3 快取層架構 (Redis Cache Strategy)
- **快取模式**：標準採用 **Cache-Aside** 模式（讀時先查 Redis，Miss 再查 DB 並回填）。
- **防禦三大快取隱患**：
  - **快取穿透 (Cache Penetration)**：布隆過濾器 (Bloom Filter) 或快取空物件（TTL 60 秒）。
  - **快取擊穿 (Cache Breakdown)**：針對高頻熱點 Key 採用互斥鎖 (Mutex) 或邏輯過期。
  - **快取雪崩 (Cache Avalanche)**：Key 過期時間加上隨機抖動值（Random Jitter: 1~5 分鐘）。

### 3.4 訊息佇列與削峰填谷 (MQ & Async Worker)
- **架構角色**：大流量寫入、耗時報表運算、第三方外部同步（如 T9/ERP、發信、推播）。
- **數據一致性保證**：
  - Worker 端執行消費時，必須保證 **冪等性 (Idempotence)**（使用 `INSERT ... ON DUPLICATE KEY UPDATE` 或唯一防重 Key）。
  - 配置死信隊列 (Dead Letter Exchange/DLX)，重試 3 次失敗後告警人工介入。

### 3.5 資料庫層讀寫分流與保護 (Database Tier)
- **主從複製架構**：Master 負責 Transactions、INSERT/UPDATE/DELETE；Slave 負責報表、列表查詢。
- **慢查詢防線**：全面嚴格限制查詢未使用 Index 的 SQL；單次查詢分頁強制限制 `LIMIT <= 100`。

---

## 🛠️ 4. 系統核心效能調優參數備忘 (Kernel & Nginx)

### Linux 核心連線數調優 (`/etc/sysctl.conf`)
```ini
# 開放最大檔案描繪符與連線隊列
fs.file-max = 2097152
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535

# 快速回收 TIME_WAIT
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15

# 本地連接埠範圍
net.ipv4.ip_local_port_range = 1024 65535
```

### Nginx 高併發核心配置 (`nginx.conf`)
```nginx
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    use epoll;
    worker_connections 65535;
    multi_accept on;
}

http {
    keepalive_timeout 65;
    keepalive_requests 10000;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    gzip on;
    gzip_min_length 1k;
    gzip_types text/plain application/javascript application/json text/css;
}
```

---

## 📋 5. 高併發上線檢驗清單 (Checklist)

- [ ] 壓力測試完成（使用 k6 / wrk / Locust 測得最大承受 QPS 與瓶頸點）
- [ ] Redis 記憶體上限與淘汰策略設定（`maxmemory-policy allkeys-lru`）
- [ ] 訊息隊列 (MQ) 磁碟告警與死信隊列已連通
- [ ] 資料庫主從延遲監控已建立（Replica Lag < 1s）
- [ ] 系統降級開關 (Circuit Breaker) 與緊急維護頁面準備就緒
