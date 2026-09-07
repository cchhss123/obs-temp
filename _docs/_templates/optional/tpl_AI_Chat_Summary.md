# 💡 AI 深度除錯與避坑知識卡片 (AI Deep Debugging Card)

> **問題主題**：【填入遭遇的具體 Bug 或技術難題】
> **記錄日期**：{{DATE}}
> **所屬模組**：【後端 / Docker / 資料庫 / 前端 / 網路】
> **影響程度**：阻斷開發 / 伺服器 500 報錯 / 效能瓶頸

---

## 🔍 1. 問題現象與錯誤訊息 (Symptoms & Logs)

- **錯誤現象**：[例如：Docker 容器啟動時持續 Restarting，或 MySQL 報 ERROR 3780]
- **原始錯誤日誌 (Stack Trace)**：
```text
[ERROR] 1114: Cannot add foreign key constraint. Incompatible collation 'utf8mb4_0900_ai_ci' and 'utf8mb4_unicode_ci'.
```

---

## ❌ 2. 曾嘗試過但失敗的路徑 (Failed Attempts)

1. **嘗試一**：直接在應用層忽略字元集報錯 ➔ 結果：ORM 依然拋出 Fatal 外鍵約束失敗。
2. **嘗試二**：手動修改單一欄位字元集 ➔ 結果：引發其他既有關聯表校對衝突。

---

## 🎯 3. 根本原因深入剖析 (Root Cause)

- **根本原因**：[深入技術原理，例如：MySQL 8.0 與舊版 MySQL 預設 Collation 差異，導致主鍵與外鍵校對集不匹配]

---

## 🛠️ 4. 最終成功修復方案 (Solution & Code)

### 4.1 修復步驟 / Migration 腳本：
```sql
ALTER TABLE admins MODIFY profile_id VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 4.2 驗證指令：
```bash
docker compose exec db mysql -u root -p -e "SHOW CREATE TABLE admins;"
```

---

## 💡 5. 未來避坑與最佳實踐建議 (Takeaways)

1. 在新建任何 Migration 腳本時，必須明確宣告資料表與外鍵欄位的 `COLLATE`。
2. 跨容器網路連線必須優先以 service name 互通，避免硬寫實體 IP。
