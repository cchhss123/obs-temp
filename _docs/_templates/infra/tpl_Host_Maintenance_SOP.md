# 🛠️ 主機例行維護、擴容與日常維運 SOP

> **建立日期**：{{CURRENT_DATE}}  
> **專案代號**：{{PROJECT_KEY}}  
> **負責人**：{{AUTHOR}}  
> 
> 💡 **關聯文檔**：
> - [[_docs/_templates/tpl_Server_Environment|🖥️ 伺服器連線與環境配置]]
> - [[_docs/_templates/infra/tpl_Disaster_Recovery_Plan|💾 備份驗證與災難復原演練]]

---

## 📅 1. 維運排程與檢查頻率

| 週期 | 檢查項目 | 核心動作 | 預期健康狀態 |
| :--- | :--- | :--- | :--- |
| **每日 (Daily)** | 系統監控告警 | Telegram / Discord 機器人健康通報 | 無 Critical 告警、服務正常運作 |
| **每週 (Weekly)** | 磁碟使用量 | `df -h` 檢查根目錄與 `/data` | 磁碟空間使用率 < 80% |
| **每月 (Monthly)** | 系統安全更新 | `apt update`、Docker 基礎鏡像更新 | 無高危 CVE 漏洞未補 |
| **每季 (Quarterly)**| 備份還原演練 | 從 GCS / S3 提取備份檔案進行本機還原測試 | 資料庫結構與數據 100% 可還原 |

---

## 🧹 2. 磁碟空間清理標準作業程序 (Disk Cleanup SOP)

當伺服器空間不足或進行每月例行維護時，依照以下優先順序清理：

### 步驟 1：檢視磁碟占用現況
```bash
# 查看各分區剩餘空間
df -h

# 找出前 10 大占用目錄 (針對根目錄或 /var)
du -ahx / 2>/dev/null | sort -rh | head -n 10
```

### 步驟 2：清理 Docker 無用資源 (安全清理)
```bash
# 清理已停止容器、未使用的映像檔與建置快取
docker system prune -f

# 徹底清除未掛載的虛擬磁碟卷 (⚠️ 確認無重要獨立資料卷)
docker volume prune -f

# 檢查 Docker 專屬目錄占用
du -sh /var/lib/docker
```

### 步驟 3：清理系統日誌與 Journalctl
```bash
# 檢查 systemd-journald 占用
journalctl --disk-usage

# 僅保留最近 7 天的系統日誌
sudo journalctl --vacuum-time=7d

# 或限制日誌最大占用 500MB
sudo journalctl --vacuum-size=500M
```

### 步驟 4：清理 APT 快取與孤立套件
```bash
sudo apt-get clean
sudo apt-get autoremove -y
```

---

## 🔄 3. 主機安全重啟與軟體升級流程 (Maintenance & Restart)

針對生產機（Production）的例行核心升級或主機重開機：

### 階段一：事前準備
1. 發布維護公告，或於離峰時段（例如凌晨 02:00 ~ 04:00）進行。
2. 進行即時快照（GCP Snapshot / AWS AMI）或手動 Dump 資料庫。
   ```bash
   mysqldump -u root -p --all-databases --single-transaction > /data/backup/pre_upgrade_$(date +%F).sql
   ```
3. 確認 Cloudflare 進入維護模式（可導向靜態 503 維護中網頁）。

### 階段二：依序優雅停止服務
```bash
# 1. 先停外部流量 (反向代理 / Nginx)
sudo systemctl stop nginx  # 或 docker stop nginx-proxy

# 2. 停止背景 Worker 避免資料中斷
sudo supervisorctl stop all  # 或 docker stop mq-worker

# 3. 停止應用服務
docker compose down

# 4. 最後停止資料庫 (讓 Dirty Pages 刷入磁碟)
docker stop mysql-db
```

### 階段三：執行系統更新與重開機
```bash
sudo apt update && sudo apt upgrade -y
sudo reboot
```

### 階段四：重開機後健康度驗收
```bash
# 檢查服務自動啟動狀態
docker compose ps
docker stats --no-stream

# 測試 HTTP 健康端點
curl -I https://localhost/health

# 檢查系統日誌是否有內核報錯
dmesg -T --level=err,warn
```

---

## 📈 4. VM 規格垂直升級 SOP (Resize / Upgrade)

當 CPU / RAM 常態超過 85% 時的升級步驟（以 GCP / AWS 為例）：

1. **靜態 IP 綁定確認**：確認 VM 已綁定「靜態外部 IP」，避免關機重啟後 IP 變更導致 DNS 失效。
2. **建立機器映像檔 (Machine Image)**：作為回滾保護。
3. **停止 VM 實例**：`gcloud compute instances stop <instance-name>`。
4. **修改機型規格**：
   - 例：從 `e2-medium` (2 vCPU, 4GB RAM) 升級為 `e2-standard-2` (2 vCPU, 8GB RAM)。
5. **啟動 VM 實例**：`gcloud compute instances start <instance-name>`。
6. **校驗服務與調優參數**：
   - 進入主機確認 `free -m` 記憶體增加。
   - 視情況調整 MySQL `innodb_buffer_pool_size` 或 PHP-FPM `pm.max_children` 讓新資源生效。
