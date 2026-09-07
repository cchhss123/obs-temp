# 🧪 冒煙測試與驗收用例庫 (Smoke Test & Acceptance Suite)

> **測試模組/版本**：【填入模組或 Phase 名稱】
> **測試日期**：{{DATE}}
> **測試環境**：本地 Docker / GCP VM 測試機
> **測試結論**：🟢 100% 綠燈全數通過 / 🔴 發現阻斷性 Bug

---

## 🎯 1. 冒煙測試執行原則

1. **Happy Path 優先**：核心正常業務流程必須 100% 順暢。
2. **邊界與例外覆蓋**：包含空值、特殊字元、非法權限與重複提交。
3. **零回歸保證 (Zero Regression)**：確認既有舊模組運作未受影響。

---

## 📋 2. 核心功能驗收測試矩陣 (Test Matrix)

### 2.1 正常路徑 (Happy Path)
| 用例編號 | 測試情境與步驟 | 預期結果 | 實測狀態 |
| :--- | :--- | :--- | :---: |
| **TC-01** | 管理員填寫完整表單並提交 | 後端回傳 200，DB 成功寫入，前端顯示成功 Toast | 🟢 PASS |
| **TC-02** | 列表即時查詢與分頁載入 | 數據正確顯示且無延遲 | 🟢 PASS |

### 2.2 邊界與安全性測試 (Edge & Security Cases)
| 用例編號 | 測試情境與步驟 | 預期結果 | 實測狀態 |
| :--- | :--- | :--- | :---: |
| **TC-03** | 未登入直接呼叫受保護 API | API 阻斷並回傳 401 Unauthorized | 🟢 PASS |
| **TC-04** | 停權帳號嘗試發送請求 | API 阻斷並回傳 403 Forbidden | 🟢 PASS |
| **TC-05** | 輸入包含 `<script>alert(1)</script>` | 系統轉義儲存，無 XSS 彈窗 | 🟢 PASS |
| **TC-06** | 連續快速點擊提交 3 次 | 觸發防重放或冪等保護，僅寫入 1 筆 | 🟢 PASS |

---

## 🤖 3. 自動化測試腳本執行紀錄 (Automated Runner)

```bash
# 執行 Docker 容器內自動化測試腳本
docker compose exec web php scratch/test_phase.php
```

### 實測執行輸出：
```text
=== STARTING AUTOMATED ACCEPTANCE SUITE ===
[PASS] Test Auth Protection: Blocked unauthenticated request.
[PASS] Test XSS Sanitization: Payload properly escaped.
[PASS] Test Idempotent Write: Duplicate key handled cleanly.
[PASS] Test Zero Regression: Legacy tables untouched.
===========================================
TOTAL: 12 Passed, 0 Failed, 0 Skipped (100% GREEN)
```

---

## 📸 4. 驗收截圖與畫面存證

> `![驗收截圖](圖片路徑)`
