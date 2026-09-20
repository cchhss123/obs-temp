# 🖥️ 伺服器環境拓撲與連線管理備忘

> **建立日期**：{{CURRENT_DATE}}  
> **專案代號**：{{PROJECT_KEY}}  
> **負責人**：{{AUTHOR}}  
> 
> [!CAUTION]
> **機密與資安防護宣告**：
> 本文檔僅供內部開發團隊與授權維運人員本機參照。
> **嚴禁將真實正式環境（Production）密碼、生產 DB 帳密或私人金鑰 Commit 至公開 Git 倉庫！**
> 敏感憑證檔（`*.ovpn`, `*.key`, `*.pem`）請確認已納入根目錄 `.gitignore` 排除。

---

## 🌐 1. 網路架構與 VPN 設定

*   **VPN 類型**：[例如：OpenVPN / WireGuard / SSL-VPN / 企業內部內網直連]
*   **設定檔位置**：`_docs/_raw_documents/連線設定/client.ovpn`（已受 `.gitignore` 保護）
*   **連線帳號**：`[連線帳號]`
*   **網關 / 跳板機 (Bastion Host)**：`[例如：10.11.12.1 或跳板機 IP]`
*   **網管 / SA 聯絡窗口**：`[MIS / SA 窗口名稱與分機]`

---

## 🧪 2. 測試環境 (Staging / Development)

| 服務項目 / 角色 | 連線位置 / 網址 | 連接埠 (Port) | 帳號 | 密碼 / 認證方式 | 備註說明 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **前端 Web / 管理後台** | `http://10.x.x.x/admin/` | 80 / 443 | `admin` | `[密碼]` | 前端靜態資源站點 |
| **後端 API 服務** | `http://10.x.x.x/api/` | 8080 | - | - | REST / WebService 端點 |
| **主機 SSH / 終端機** | `10.x.x.x` | 22 | `deploy` | SSH Key / 密碼 | 具備 sudo 權限 |
| **關聯式資料庫 (DB)** | `10.x.x.x` | 3306 / 5432 | `db_user` | `[密碼]` | 資料庫名稱: `proj_test` |
| **DB 管理介面** | `http://10.x.x.x/phpmyadmin/` | 80 | `root` | `[密碼]` | 僅限內網訪問 |
| **訊息佇列 (MQ)** | `http://10.x.x.x:15672/` | 5672 / 15672 | `guest` | `guest` | RabbitMQ 管理介面 |

---

## 🚀 3. 正式環境 (Production)

| 服務項目 / 角色 | 連線位置 / 網址 | 連接埠 (Port) | 帳號 | 密碼 / 認證方式 | 備註說明 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **正式站點 (Domain)** | `https://app.example.com/` | 443 | - | - | 外部公開入口 |
| **API 閘道 (Gateway)** | `https://api.example.com/` | 443 | - | - | 附帶 Rate Limit 與 WAF |
| **主機 SSH** | `[正式主機 IP / 跳板機]` | 22 | `sysadmin` | 私鑰 (Ed25519) | 需經由 VPN 訪問 |
| **主資料庫 (Primary DB)** | `[內網 DB IP]` | 3306 / 5432 | `app_prod` | `[參照金鑰庫]` | 生產資料庫，定期備份 |

---

## ⚡ 4. 常用維運指令速記

### SSH 快速登入
```bash
ssh -p 22 deploy@10.x.x.x
```

### 資料庫遠端連線測試
```bash
mysql -h 10.x.x.x -P 3306 -u db_user -p proj_test
```

### 服務連線健康探測 (使用母版工具)
```bash
python _tools/probe_health.py http://10.x.x.x/api/health
```
