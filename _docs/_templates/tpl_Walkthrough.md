# Walkthrough_【功能/模組名稱】工作總結與驗證說明

> **完成日期**：{{DATE}}
> **對應計畫**：[[Plan_對應計畫名稱]]
> **專案模式**：GreenField (全新開發) / LegacyModule (舊系統擴充)
> **驗證結果**：🟢 100% 驗收通過 / 🟡 部分通過需微調 / 🔴 待修復

---

## 📋 1. 工作範疇與完成項目清單

本次迭代完成的核心功能與修復摘要：
1. **[後端 API / 服務]**：完成 ...
2. **[前端介面 / 元件]**：完成 ...
3. **[舊系統防腐層 / 相容性]**：完成 ...
4. **[Bug 修復與防禦]**：修復 ...

---

## 🛠️ 2. 跨 Repo 核心代碼變更清單

### 2.1 後端倉庫 (Backend Repo)
- `[NEW]` `src/services/NewService.php`
- `[MODIFY]` `src/controllers/ApiController.php`
- `[MIGRATION]` `migrations/2026_09_07_add_table.sql`

### 2.2 前端應用倉庫 (Frontend Repo)
- `[NEW]` `src/components/NewFeatureModal.vue`
- `[MODIFY]` `src/api/client.js`

### 2.3 管理後台倉庫 (Admin Repo / Optional)
- `[MODIFY]` `src/views/ReportView.vue`

---

## 🧪 3. 測試與驗證結果 (Verification & Test Cases)

### 3.1 自動化 / 單元測試
- 測試指令：`pytest tests/` 或 `composer test`
- 執行結果：`All tests passed (100% green).`

### 3.2 功能情境測試
| 測試情境 | 操作步驟 | 預期結果 | 實測狀態 |
| :--- | :--- | :--- | :---: |
| **情境 A：正常端到端流程** | 前端填寫表單並點擊提交 | 後端回傳 200，DB 成功寫入，前端顯示成功 Toast | 🟢 通過 |
| **情境 B：例外/邊界測試** | 模擬網路超時或重複提交 | 觸發防重放或冪等保護機制，資料不重複新增 | 🟢 通過 |

### 3.3 零回歸與資料相容性驗證 (Zero Regression) ※舊系統新模組必驗
| 舊系統功能 / 資料表 | 驗證重點 | 實測結果 |
| :--- | :--- | :---: |
| **既有舊訂單查詢** | 舊查詢 API 功能不受新欄位影響 | 🟢 100% 正常 |
| **舊版資料格式對齊** | 新舊系統計算結果對齊（差異為 0） | 🟢 100% 吻合 |

---

## 📸 4. 驗收畫面與成果截圖 (Screenshots)

> 若有截圖可置於此處：`![說明](圖片路徑)`

---

## 💡 5. 全域駕駛艙摘要 (Hub Summary)

> 💡 **請複製以下摘要，回貼至 `workIdeax/_docs/工作日誌.md` 或 `obs-and`**：
> `{{PROJECT_KEY}}: 完成【功能名稱】開發與跨端聯調，通過本地 UAT 與零回歸驗收。`

---

## 📌 6. 遺留問題與後續優化建議 (Follow-ups)

- [ ] 下一階段優化項目 A
- [ ] 待顧問/主管確認之業務邏輯細節
