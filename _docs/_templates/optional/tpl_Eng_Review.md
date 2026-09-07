# 🛡️ 工程架構與資安審查清單 (Engineering & Security Review)

> **審查模組**：【填入模組/功能名稱】
> **審查日期**：{{DATE}}
> **審查結論**：🟢 通過 (CLEAN) / 🟡 附帶條件修正 / 🔴 阻斷動工 (BLOCK)
> **負責人 / 審查員**：{{AUTHOR}} / AI 資安架構師

---

## 🔒 1. 身分認證、授權與 Session 隔離 (Auth & Permissions)

- [ ] **Token 簽章與有效性**：JWT / API Key 是否有時效 (exp)、來源 (iss/aud) 驗證？
- [ ] **越權存取防禦 (BOLA / IDOR)**：查詢或修改資源時，是否有校驗「登入者 ID 與資料所有權歸屬」？
- [ ] **權限即時性 (Immediate Revocation)**：當管理員被停權或降級時，Session/Token 是否能即時阻斷？
- [ ] **密碼與雜湊安全**：密碼是否採用標準 BCrypt / Argon2 雜湊？（嚴禁明文或 MD5/SHA1）。

---

## 🛡️ 2. 資料存取與注入防禦 (Data Security & Injection)

- [ ] **SQL 注入防禦**：所有 SQL 查詢是否 100% 採用 PDO 參數化綁定？（`ATTR_EMULATE_PREPARES => false`）。
- [ ] **XSS 跨站腳本防禦**：使用者輸入之富文本/字串，在前台渲染或後台儲存時是否經過 HTML 實體轉義？
- [ ] **檔案上傳安全**：上傳檔案是否有副檔名白名單、MIME 驗證、以及隨機雜湊重命名儲存？

---

## ⚡ 3. 穩定性、超時與防禦性編程 (Fail-safe & Resilience)

- [ ] **外部 I/O 限制 (Timeout)**：所有 `curl`、HTTP Request 或外部第三方 API 呼叫是否強制設定 `timeout <= 5s`？
- [ ] **第三方 SDK 例外隔離 (Graceful Degradation)**：第三方服務（如 LINE SDK、金流、SMS）報錯時，是否用 `try-catch` 包裹並無感降級，保證主流程不崩潰？
- [ ] **快取損毀自癒 (Cache Self-Healing)**：讀取 JSON 快取或 Redis 失敗時，是否有自動重建或刪除損毀快取的降級邏輯？

---

## 📋 4. 法規、隱私與日誌合規 (Compliance & Logging)

- [ ] **個資脫敏 (PDPA / Privacy)**：日誌輸出中是否已過濾密碼、信用卡號、真實身分證字號？
- [ ] **敏感錯誤不洩漏**：正式機是否關閉 `display_errors`，避免將 Database Stack Trace 暴露給使用者？
- [ ] **重大操作稽核日誌**：帳號停權、刪除資料、權限提升是否有寫入 Audit Log？

---

## 📝 5. 審查發現缺失與修復行動 (Findings & TODOS)

| 缺失編號 | 嚴重程度 (高/中/低) | 發現問題描述 | 修正措施 / 對應 TODOS |
| :--- | :---: | :--- | :--- |
| **SEC-01** | 高 | 外部 Webhook 缺乏簽名驗證 | 補齊 HMAC-SHA256 驗證邏輯 |
| **PERF-01** | 中 | 未設定 curl 超時可能導致請求卡死 | 加入 `CURLOPT_TIMEOUT => 5` |
