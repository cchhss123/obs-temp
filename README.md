# {{PROJECT_NAME}} — 專案知識管理庫

> 歡迎使用 **{{PROJECT_NAME}}** 專案知識庫！本 Vault 是專案的「長期記憶核心、架構儀表板與跨 Repo 指揮中樞」。

---

## 🧭 快速跳轉導覽

```mermaid
graph TD
    Home[專案首頁] --> Active[日常動態看板]
    Home --> LongTerm[長期記憶 Context]
    Home --> Templates[標準模板庫]
    Home --> Repos[關聯代碼倉庫]

    Active --> T1[[[_docs/待辦|📋 待辦清單]]]
    Active --> T2[[[_docs/工作日誌|📝 每日工作日誌]]]
    Active --> T3[[[_docs/專案索引|🗺️ 專案功能索引]]]

    LongTerm --> MOC[[[_docs/context/00_長期記憶導覽索引|🏛️ 長期記憶 Master MOC]]]
    LongTerm --> C1[[[_docs/context/01_規劃與計畫/決策紀錄|💡 決策紀錄 ADR]]]
    LongTerm --> C4[[[_docs/context/04_維運與部署/工作流管理議題|⚙️ 工作流與部署規範]]]

    Templates --> TPL[[[_docs/_templates/|📄 模板目錄]]]
```

---

## 📌 專案基本資訊

- **專案代號**：`{{PROJECT_KEY}}`
- **專案模式**：{{PROJECT_MODE_LABEL}}
- **負責人**：`{{AUTHOR}}`
- **專案使用指南**：[[專案使用指南|📖 如何使用本專案樣版]]
- **AI 助手設定檔**：[[CLAUDE]]

---

## 🗂️ 關聯代碼倉庫清單 (Associated Git Repos)

{{REPO_TABLE_MARKDOWN}}

---

## 🗂️ 目錄結構說明

- `_docs/`：日常高頻維護檔案（待辦、工作日誌、專案索引）。
- `_docs/_templates/`：標準空白模板（Plan、Walkthrough、ADR、Research）。
- `_docs/context/`：專案生命週期四大核心板塊：
  1. `01_規劃與計畫/`：架構計畫（`Plan_*.md`）與架構決策紀錄（`決策紀錄.md`）。
  2. `02_技術研究與分析/`：技術選型、相容性分析、依賴比對（`Research_*.md`）。
  3. `03_工作紀錄與驗證/`：階段驗收、UAT 測試報告、零回歸體檢（`Walkthrough_*.md`）。
  4. `04_維運與部署/`：部署 SOP、工作流規範、環境檢驗清單。
