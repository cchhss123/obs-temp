# CLAUDE.md — {{PROJECT_NAME}} 專案學術研究大腦

> 這個 Obsidian vault 是 **{{PROJECT_NAME}}** 的專屬學術論文研究與假說驗證大腦。
> 負責記錄研究問題 (RQ)、理論假說 (Hypothesis)、文獻綜述 (Literature Review)、實驗日誌、統計分析與投稿 Rebuttal。
> 供 AI 助手（Claude Code / Antigravity / Gemini / Cursor 等）輔助科研工作時快速載入完整脈絡，實現跨對話持續累積。

---

## 專案核心元資料 (Metadata)

| 項目 | 設定值 / 說明 |
| :--- | :--- |
| **專案名稱** | {{PROJECT_NAME}} |
| **專案模式** | {{PROJECT_MODE_LABEL}} |
| **專案定位** | [簡短描述研究主題、核心理論假說與學術創新貢獻] |
| **知識庫路徑** | `D:\_obs\obs-{{PROJECT_KEY}}` |
| **研究工具/環境** | [例如：Python, PyTorch, R, SPSS, Zotero, Overleaf/LaTeX, Jupyter] |

---

## 關聯研究資產 (Associated Research Assets)

{{REPO_TABLE_MARKDOWN}}

---

## 目前進度

**{{CURRENT_DATE}} (專案知識庫建立與初始化)**
- **研究題目與假說背景**：確立研究開題方向與問題陳述 (RQ) 初稿。
- **文獻回顧推進**：核心文獻探討與理論缺口盤點 (N/A)
- **實驗與數據進展**：變因控制表與首波實驗環境配置 (N/A)
- **假說驗證與統計分析**：跨實驗交叉分析與顯著性檢定
- **論文撰寫與投稿狀態**：目標期刊評估與投稿檢核表建立

*(💡 提示：日常研究時，請依據「研究題目背景、文獻進展、實驗數據、假說判定、論文投稿」記錄高密度進度；若當日某項無變更請標記 N/A)*

---

## 注意事項與工作流原則

1. **Hub-and-Spoke 雙層連動**：
   - 本庫為 **{{PROJECT_NAME}}** 的「深度大腦 (Spoke)」，記錄所有實驗參數、原始數據路徑、統計顯著性檢定與文獻卡片。
   - 每日結束工作時，產出 1~2 行「高階里程碑摘要」，回貼至 `workIdeax`（學術工作）或 `obs-and`（個人研究）總管理駕駛艙 (Hub)。
2. **科研誠信與可重現性 (Reproducibility)**：
   - 所有實驗執行必須在 `tpl_Experiment_Log.md` 中詳細記錄 IV/DV/CV 變因、亂數種子 (Seed)、軟硬體版本與環境。
   - 原始數據 (Raw Data) 存放於唯讀目錄或外部存儲，不得任意修改原始記錄。
3. **文獻脈絡結構化流轉**：
   - 外部文獻 PDF 或補充資料放入 `_docs/_raw_documents/`。
   - 經 AI 閱讀與筆記後，收納至單篇文獻卡，並整合至 `tpl_Literature_Review.md` 跨文獻矩陣。
4. **架構反哺原則 (Upstream Feedback)**：
   - 本庫遵循「無雜訊原則」，日常實驗不進行自動提醒。
   - 若在研究過程中淬煉出優良的研究方法論模板、統計分析工作流或投稿避坑清單，研究員可主動調用 `tpl_obs_temp_enhancement_proposal` 產出建議書，反哺回母模板 `obs-temp`。詳見 [[專案知識庫開發歷程]]。

---

## AI 輔助常用指令庫

### 1. 每次結束工作時（學術研究高密度進度與全域摘要）
```text
請根據今天的研究討論與實驗產出：
1. 更新 CLAUDE.md 的「目前進度」，依標準規格記錄：
   - 研究題目與假說背景（對齊之 Research Proposal 或章節）
   - 文獻回顧推進（新增閱讀篇數、理論框架修正、文獻卡更新）
   - 實驗與數據進展（實驗批次 Trial、參數設定、數據前處理）
   - 假說驗證與統計分析（p-value、消融實驗、假說判定結論）
   - 論文撰寫與投稿狀態（Draft 章節完成度、Checklist 進展）
2. 將今日詳細實驗與研究內容附加到 @_docs/工作日誌.md 最上方
3. 若有待辦異動，更新到 @_docs/待辦.md
4. 若有核心研究方法決策，記錄到 @_docs/context/01_規劃與計畫/決策紀錄.md
5. 在對話最後輸出「全域日誌摘要（1~2行）」，方便我複製回貼到總駕駛艙。
```

### 2. 繼續上次工作時（快速恢復研究脈絡）
```text
請依序讀取：
1. CLAUDE.md（了解目前進度、研究假說與關聯研究資產）
2. @_docs/待辦.md（了解進行中與待驗證項目）
3. @_docs/工作日誌.md（了解最近一次實驗與統計細節）
確認理解目前研究狀態後，向我匯報並討論下一步。
```

### 3. 開題報告與研究假說推導
```text
請參考 @_docs/_templates/research/tpl_Research_Proposal.md：
1. 協助我聚焦研究動機與核心研究問題 (RQ1, RQ2)。
2. 從現有文獻缺口中推導可被檢驗的研究假設 (H1, H2)。
3. 繪製研究流程管線圖 (Pipeline Mermaid) 並規劃研究甘特圖，存檔於 @_docs/context/01_規劃與計畫/。
```

### 4. 文獻深度評析與比較矩陣
```text
請參考 @_docs/_templates/research/tpl_Literature_Review.md：
1. 針對這篇文獻建立「單篇文獻卡片」（記錄 APA 引用、核心論點、方法論、研究限制與關聯度）。
2. 將其納入「跨文獻比較矩陣」，對比其與其他文獻在樣本、模型與核心發現之差異。
3. 提煉現有文獻缺口 (Research Gap) 與理論框架圖，存檔於 @_docs/context/02_技術研究與分析/。
```

### 5. 階段成果總結與假說判定 (Findings Walkthrough)
```text
本階段實驗已完成，請參考 @_docs/_templates/research/tpl_Research_Findings.md：
1. 回顧 [[Research_Proposal]] 中的假說清單 (H1, H2, H3)。
2. 匯總多份 [[Experiment_Log]] 進行消融實驗與 Baseline 對照分析。
3. 對各假說給出判定結論 (✅ 支持 / ❌ 駁回 / ⚠️ 部分支持) 並附上統計佐證。
4. 剖析內部效度、外部效度與建構效度威脅，存檔於 @_docs/context/03_工作紀錄與驗證/。
```

### 6. 期刊投稿檢核與審稿回覆 (Rebuttal)
```text
請參考 @_docs/_templates/research/tpl_Paper_Submission_Checklist.md：
1. 協助我逐項檢驗投稿前 Checklist（格式、字數、圖表品質、倫理與利益衝突宣告）。
2. 若收到 Reviewer 意見：建立 Point-by-Point 審稿回覆表（Reviewer 意見 ➔ 我方回應 ➔ 具體修改處與行號）。
3. 記錄修訂版追蹤日誌，存檔於 @_docs/context/04_維運與部署/。
```

---

## 目錄快捷導覽

- **專案使用指南**：[[專案使用指南|📖 專案知識庫使用指南]]
- **架構開發歷程**：[[專案知識庫開發歷程|📜 專案知識庫開發歷程與架構演進]]
- **版本異動說明**：[[版本異動說明|📝 版本異動說明 (v2.3.0)]]
- **長期記憶總索引 (Master MOC)**：[[_docs/context/00_長期記憶導覽索引]]
- **輕量級工具箱**：`_tools/`（內建 `read_docx.py`, `read_xlsx.py`, `probe_health.py`）
- **原始規格文檔池**：`_docs/_raw_documents/`（外部論文與數據輸入源頭）
- **日常高頻看板**：[[_docs/待辦]] ｜ [[_docs/工作日誌]] ｜ [[_docs/專案索引]]
- **研究專屬模板庫**：`_docs/_templates/research/`
  - [[_docs/_templates/research/tpl_Research_Proposal|📝 研究計畫與問題陳述 (Proposal)]]
  - [[_docs/_templates/research/tpl_Literature_Review|📚 文獻探討與比較評析筆記]]
  - [[_docs/_templates/research/tpl_Experiment_Log|🧪 實驗環境與數據收集日誌]]
  - [[_docs/_templates/research/tpl_Research_Findings|🏆 階段假說驗證與成果總結]]
  - [[_docs/_templates/research/tpl_Paper_Submission_Checklist|📤 期刊投稿檢驗與審稿回覆]]
- **01 規劃與計畫**：[[_docs/context/01_規劃與計畫/決策紀錄]]
- **04 維運與投稿**：[[_docs/context/04_維運與部署/工作流管理議題]]
