# 🌿 舊系統絞殺者遷移與資料對齊架構範式 (Strangler Fig Pattern)

> **適用情境**：既有舊系統（如 ERP、舊版 Odoo 14、Monolith）過於龐大，直接推倒重來風險極高；需要在邊緣建立防腐層，逐步將功能外掛抽離，並以 Python ORM ETL 腳本完成新舊資料「0 元差額」驗證。
> **來源實踐**：`obs-odoo` (Odoo 14 ➔ 19 跨 5 大版本遷移、台灣勞健保計薪社群版解耦)

---

## 🏗️ 1. 絞殺者遷移架構圖 (Strangler Architecture)

```mermaid
graph TD
    Client[客戶端 / 使用者] --> Gateway[API Gateway / 路由分流器]
    
    Gateway -->|舊功能 (逐漸萎縮)| LegacySystem[舊系統核心 Monolith]
    Gateway -->|新功能 / 重構模組| NewSystem[新系統模組 (乾淨解耦)]

    NewSystem --> ACL[防腐層 Anti-Corruption Layer]
    ACL -.->|唯讀/事件同步| LegacyDB[(舊資料庫)]
    NewSystem --> NewDB[(新資料庫)]

    subgraph ETL[跨庫 ETL 資料轉置與精算對齊]
        Script[Python psycopg2 / ORM 轉置腳本]
        LegacyDB --> Script
        Script --> NewDB
    end
```

---

## 💡 2. 四大核心實施階段 (Migration Phases)

### 階段一：防腐層 (Anti-Corruption Layer) 隔離
- **原則**：新開發的模組**絕對不要直接依賴或修改舊系統核心代碼**。
- **做法**：建立 Adapter/Interface，將舊系統的資料模型轉化為新系統的領域物件，實現新舊邊界隔離。

### 階段二：跨庫 Python ETL 轉置驗證
- 不在本地安裝舊環境，改為在同一個資料庫容器中還原舊 DB 備份。
- 撰寫 Python 跨庫轉置腳本（由新系統 Shell 執行），利用新系統 ORM 進行寫入：
  - 自動觸發新系統的欄位型別、必填與 Unique 約束校驗。
  - 扁平舊資料轉為新版一對多版本結構。

### 階段三：零回歸精算對齊 (Zero Difference Verification)
- 針對關鍵業務數據（如勞健保保額、稅額、薪資規則計算），撰寫自動對比腳本。
- **標準**：新舊系統計算結果比對，差額必須精確對到 **0 元**。

### 階段四：舊模組平滑下線 (Decommission)
- 將流量完全切換至新模組後，逐步安全移除舊代碼與舊依賴（例如移除商業版模組依賴，改用開源社群版）。
