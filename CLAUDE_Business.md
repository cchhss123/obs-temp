# CLAUDE.md — {{PROJECT_NAME}} 專案商業營運大腦

> 這個 Obsidian vault 是 **{{PROJECT_NAME}}** 的專屬商業策略與營運管理知識大腦。
> 負責記錄商業計畫、市場調研 (STP/4P)、競品分析、營運決策 (ADR)、每日工作日誌與 SOP 規範。
> 供 AI 助手（Claude Code / Antigravity / Gemini / Cursor 等）輔助工作時快速載入完整脈絡，實現跨對話持續累積。

---

## 專案核心元資料 (Metadata)

| 項目 | 設定值 / 說明 |
| :--- | :--- |
| **專案名稱** | {{PROJECT_NAME}} |
| **專案模式** | {{PROJECT_MODE_LABEL}} |
| **專案定位** | [簡短描述專案商業目標、目標市場與核心價值主張] |
| **知識庫路徑** | `D:\_obs\obs-{{PROJECT_KEY}}` |
| **營運系統/工具** | [例如：CRM (HubSpot/Salesforce), ERP, GA4, BI 看板, Meta/Google 廣告] |

---

## 關聯營運資源 (Associated Operations Resources)

{{REPO_TABLE_MARKDOWN}}

---

## 目前進度

**{{CURRENT_DATE}} (專案知識庫建立與初始化)**
- **需求與策略背景**：對齊商業專案初始章程，建立知識庫結構與雙層解耦機制。
- **策略與計畫推進**：商業模式畫布與專案目標設定 (N/A)
- **市場與營運推進**：目標客群定位與推廣管道配置 (N/A)
- **核心指標與預算**：初始 KPI 目標與預算模型確立
- **實機/現場驗收結果**：核心商業模板與 Context 板塊檢驗通過

*(💡 提示：日常推進時，請依據「策略背景、營運推進、指標數據、跨部門協同、成果驗收」記錄高密度進度；若當日某項無變更請標記 N/A)*

---

## 注意事項與工作流原則

1. **Hub-and-Spoke 雙層連動**：
   - 本庫為 **{{PROJECT_NAME}}** 的「深度大腦 (Spoke)」，記錄所有商業計畫、競品矩陣、會議紀錄與營運數據。
   - 每日結束工作時，產出 1~2 行「高階里程碑摘要」，回貼至 `workIdeax`（工作/客戶）或 `obs-and`（個人/生涯）總管理駕駛艙 (Hub)。
2. **跨部門協作與權責劃分 (RACI)**：
   - 重大業務專案落地前，優先調用 `tpl_Plan_Business.md` 定義跨部門 RACI 矩陣與 As-Is ➔ To-Be 業務流程。
   - 避免未經利害關係人對齊即逕行推動流程變更。
3. **商業機密與數據安全**：
   - 敏感財務報表、客戶 PII 個資與未公開合約，嚴格隔離於本地或受保護雲端，禁止無脫敏上傳。
   - 外部原始報表交付件存放於 `_docs/_raw_documents/`，透過 `_tools/` 解析為 Markdown，收納於 `_docs/context/` 4 大板塊（`01_規劃`、`02_研究`、`03_驗證`、`04_維運`）。
4. **架構反哺原則 (Upstream Feedback)**：
   - 本庫遵循「無雜訊原則」，日常營運不進行自動提醒。
   - 若在專案推進中沉澱出具備跨專案通用價值的優良商業模板、分析框架或會議 SOP，負責人可主動調用 `tpl_obs_temp_enhancement_proposal` 產出建議書，並反哺回母模板 `obs-temp`。詳見 [[專案知識庫開發歷程]]。

---

## AI 輔助常用指令庫

### 1. 每次結束工作時（商業營運高密度進度與全域摘要）
```text
請根據今天的對話與產出：
1. 更新 CLAUDE.md 的「目前進度」，依標準規格記錄：
   - 需求與策略背景（對齊之商業計畫或目標單號）
   - 策略與計畫推進（畫布調整、RACI 矩陣、流程再造）
   - 市場與營運推進（推廣活動、KOL 合作、素材產出）
   - 核心指標與預算（CAC、ROI、轉換率或預算執行進度）
   - 成果驗收與復盤（Walkthrough 報告或會議共識）
2. 將今日詳細營運工作內容附加到 @_docs/工作日誌.md 最上方
3. 若有待辦異動，更新到 @_docs/待辦.md
4. 若有重大商業決策，記錄到 @_docs/context/01_規劃與計畫/決策紀錄.md
5. 在對話最後輸出「全域日誌摘要（1~2行）」，方便我複製回貼到總駕駛艙。
```

### 2. 繼續上次工作時（快速恢復商業脈絡）
```text
請依序讀取：
1. CLAUDE.md（了解目前進度、商業模式與關聯營運資源）
2. @_docs/待辦.md（了解進行中與待推動項目）
3. @_docs/工作日誌.md（了解最近一次營運與決策細節）
確認理解目前專案狀態後，向我匯報並討論下一步。
```

### 3. 發起全新商業企劃或專案計畫
```text
請參考 @_docs/_templates/business/tpl_Plan_Business.md，
為我們即將推動的 [商業專案名稱] 撰寫實施計畫書：
1. 梳理業務痛點與專案章程 (Goals & Non-Goals)。
2. 設計 As-Is ➔ To-Be 流程圖 (Mermaid) 與跨部門 RACI 權責表。
3. 拆解實施階段 (調查 ➔ 試點 ➔ 推廣 ➔ 效益檢視) 與資源預算。
4. 評估營運中斷與法規合規風險，存檔於 @_docs/context/01_規劃與計畫/。
```

### 4. 競品分析與市場定位 (STP / 4P)
```text
請參考 @_docs/_templates/business/tpl_Competitor_Matrix.md 與 tpl_GTM_Strategy.md：
1. 針對我們的產品與市場競品，產出功能對比矩陣與 SWOT 分析。
2. 評估 TAM/SAM/SOM 市場規模漏斗，明確目標客群畫像 (Persona)。
3. 輸出具體的差異化定位聲明與 4P 行銷組合建議，存檔於 @_docs/context/02_技術研究與分析/。
```

### 5. 專案結案復盤與效益驗收 (Walkthrough)
```text
專案已順利推動完成，請參考 @_docs/_templates/business/tpl_Walkthrough_Business.md：
1. 盤點交付物清單（政策規範發布、人員培訓完成、新流程上線）。
2. 進行 KPI 與 ROI 驗證對照（Target vs Actual），並檢核「零營運破壞驗證」。
3. 整理亮點、挑戰與經驗總結 (Post-Mortem)，存檔於 @_docs/context/03_工作紀錄與驗證/。
```

### 6. 外部原始文件解析（Office 零依賴工具鏈）
```text
請協助我解析 @_docs/_raw_documents/ 下的原始商業交付件：
1. 若為 Word：執行 python _tools/read_docx.py [路徑] -p 50 預覽內容。
2. 若為 Excel：執行 python _tools/read_xlsx.py [路徑] --list-sheets 探測工作表，再指定分頁提取表格。
3. 提取完成後，請協助將關鍵市場數據或需求提煉為正式計畫書或分析矩陣。
```

---

## 目錄快捷導覽

- **專案使用指南**：[[專案使用指南|📖 專案知識庫使用指南]]
- **架構開發歷程**：[[專案知識庫開發歷程|📜 專案知識庫開發歷程與架構演進]]
- **版本異動說明**：[[版本異動說明|📝 版本異動說明 (v2.3.0)]]
- **長期記憶總索引 (Master MOC)**：[[_docs/context/00_長期記憶導覽索引]]
- **輕量級工具箱**：`_tools/`（內建 `read_docx.py`, `read_xlsx.py`, `probe_health.py`）
- **原始規格文檔池**：`_docs/_raw_documents/`（外部文件輸入源頭）
- **日常高頻看板**：[[_docs/待辦]] ｜ [[_docs/工作日誌]] ｜ [[_docs/專案索引]]
- **商業專屬模板庫**：`_docs/_templates/business/`
  - [[_docs/_templates/business/tpl_Lean_Canvas|🎨 精實商業模式畫布]]
  - [[_docs/_templates/business/tpl_Plan_Business|📋 通用商業專案實施計畫]]
  - [[_docs/_templates/business/tpl_Walkthrough_Business|✅ 商業專案結案驗收與復盤]]
  - [[_docs/_templates/business/tpl_GTM_Strategy|🚀 市場進入策略 (GTM)]]
  - [[_docs/_templates/business/tpl_Competitor_Matrix|⚔️ 競品定價與功能對照矩陣]]
  - [[_docs/_templates/business/tpl_Marketing_Funnel|🌪️ 行銷漏斗數據分析與復盤]]
  - [[_docs/_templates/business/tpl_OKR_Review|🎯 OKR 季/月度檢視]]
- **01 規劃與計畫**：[[_docs/context/01_規劃與計畫/決策紀錄]]
- **04 維運與SOP**：[[_docs/context/04_維運與部署/工作流管理議題]]
