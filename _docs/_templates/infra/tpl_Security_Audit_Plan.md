# 🛡️ 主機資安防護、弱點掃描修復與憑證管理計畫 (Security & Compliance)

> **建立日期**：{{CURRENT_DATE}}  
> **專案代號**：{{PROJECT_KEY}}  
> **負責人**：{{AUTHOR}}  
> 
> 💡 **關聯文檔**：
> - [[_docs/_templates/tpl_Server_Environment|🖥️ 伺服器環境配置]]
> - [[_docs/_templates/infra/tpl_Host_Maintenance_SOP|🛠️ 主機日常維運 SOP]]

---

## 🔒 1. 伺服器基礎資安加固基準 (Hardening Baseline)

### 1.1 SSH 存取防禦
- [ ] **停用 Root 直接遠端登入**：`/etc/ssh/sshd_config` 設定 `PermitRootLogin no`。
- [ ] **全面改用金鑰認證 (Public Key Only)**：停用密碼登入 `PasswordAuthentication no`。
- [ ] **更改預設連接埠 (選配)**：將 Port 22 改為自訂高位連接埠（如 22222）。
- [ ] **安裝暴力破解防護 (Fail2ban)**：
  ```bash
  sudo apt install fail2ban -y
  sudo systemctl enable fail2ban --now
  ```

### 1.2 網路防火牆與零信任存取
- [ ] **主機級防火牆 (UFW / iptables)**：預設全部 DROP，僅放行必要埠號（80, 443, SSH）。
  ```bash
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow 22/tcp
  sudo ufw allow 80/tcp
  sudo ufw allow 443/tcp
  sudo ufw enable
  ```
- [ ] **零信任通道 (Cloudflare Tunnel)**：生產環境完全關閉對外公開 IP 的 22/3306 埠號，透過 `cloudflared` 進行身分驗證轉發。

---

## 📜 2. SSL/TLS 憑證管理與自動續期 (Certificates)

| 網域名稱 (Domain) | 憑證類型 | 簽發機構 (CA) | 取得/部署方式 | 自動續期機制 | 到期日與提醒 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `app.example.com` | Edge Certificate | Cloudflare Universal | Cloudflare Proxy | 自動隨雲端續期 | 雲端全自動 |
| `api.example.com` | Origin / Let's Encrypt | Let's Encrypt | Certbot (Standalone/Nginx) | `certbot renew` Cron | 90 天週期 (前 30 天續約) |

### Certbot 手動測試與強迫續約指令速查
```bash
# 測試續期流程 (Dry Run)
sudo certbot renew --dry-run

# 強制手動立即續約
sudo certbot renew --force-renewal

# 查看目前系統所有憑證狀態與過期日
sudo certbot certificates
```

---

## 🔍 3. 弱點掃描 (Vulnerability Scan) 修復追蹤表

記錄如 EZVAS、Nessus、OpenVAS 等第三方弱掃結果與修護指令：

| 漏洞名稱 / CVE 編號 | 風險等級 | 影響服務 / 元件 | 處置方案與修護指令 | 複掃狀態 |
| :--- | :--- | :--- | :--- | :--- |
| **TLS 1.0 / 1.1 啟用中** | Medium | Nginx / Apache | 配置僅啟用 `TLSv1.2 TLSv1.3`，禁用不安全密碼套件 | ✅ 已修復 |
| **SSH 弱加密演算法支援** | Low | OpenSSH Daemon | 修改 `sshd_config` 排除 CBC / MD5 相關 Ciphers | ✅ 已修復 |
| **Linux 核心漏洞 (CVE-xxxx)** | High | Kernel / OS | 執行 `sudo apt update && sudo apt dist-upgrade` 後重啟 | 🟡 待排程 |
| **PHP 資訊洩漏 (X-Powered-By)**| Low | PHP Engine | `php.ini` 設定 `expose_php = Off` | ✅ 已修復 |

---

## 🔐 4. 系統帳號密碼政策 (Password Policy)

針對企業客戶資安稽核要求：
```bash
# 安裝密碼品質檢查模組
sudo apt install libpam-pwquality -y

# 編輯 /etc/security/pwquality.conf
# minlen = 12       (最少 12 字元)
# dcredit = -1      (至少一個數字)
# ucredit = -1      (至少一個大寫英文)
# lcredit = -1      (至少一個小寫英文)
# ocredit = -1      (至少一個特殊符號)
```
