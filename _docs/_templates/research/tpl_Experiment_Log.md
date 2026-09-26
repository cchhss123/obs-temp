# 🧪 Experiment_Log_【實驗代號/名稱】實驗環境、變因控制與數據收集日誌

> **實驗日期**：{{DATE}}
> **對應領域**：03_工作紀錄與驗證
> **關聯計畫**：[[Research_Proposal_對應計畫名稱]]
> **執行人員**：{{AUTHOR}}

---

## 🎛️ 1. 實驗設計與變因控制 (Experiment Design)

| 變數類型 | 變數名稱 | 操作定義 (Operational Definition) | 測量方式 / 單位 |
| :--- | :--- | :--- | :--- |
| **自變數 (IV)** | [例如：學習率] | [例如：設定模型訓練的步長] | [數值型：0.01, 0.05, 0.1] |
| **因變數 (DV)** | [例如：準確率] | [例如：模型在測試集上的表現] | [百分比 %] |
| **控制變數 (CV)** | [例如：硬體環境] | [例如：確保所有實驗在相同 GPU 上執行] | [固定值：RTX 3090] |

---

## 🖥️ 2. 實驗環境與材料 (Environment & Materials)

- **硬體規格 (Hardware)**：[CPU / GPU / RAM 描述]
- **軟體/套件版本 (Software)**：[OS版本, Python 3.9, PyTorch 1.12 等]
- **資料集/樣本描述 (Dataset)**：[來源、大小、前處理方式]
- **倫理審查 (Ethical Approval)**：[如適用：IRB 編號 / 免審查說明]

---

## 📝 3. 實驗執行日誌 (Experiment Execution Log)
> 💡 **提示**：採用 Running Log 格式，隨時間遞增紀錄。

- **[YYYY-MM-DD HH:MM] 實驗啟動**
  - 參數設定：`batch_size=32`, `lr=0.01`
  - 觀察：[例如：初期 Loss 降幅符合預期]
- **[YYYY-MM-DD HH:MM] 中期觀察**
  - 觀察：[例如：第 50 epoch 出現 overfitting 跡象]
- **[YYYY-MM-DD HH:MM] 實驗中斷/完成**
  - 狀態：✅ 順利完成 / ❌ 報錯中斷 (Error: Out of Memory)

---

## 📈 4. 原始數據收集表 (Raw Data Collection Table)

| 批次/試驗 (Trial) | 參數設定 (IV) | 測量結果 (DV) | 耗時 / 備註 |
| :--- | :--- | :--- | :--- |
| Trial 01 | `lr=0.01` | Accuracy: 85.2% | 120 mins |
| Trial 02 | `lr=0.05` | Accuracy: 88.7% | 115 mins |
| Trial 03 | `lr=0.10` | Accuracy: 70.1% | 118 mins (不收斂) |

---

## 💡 5. 初步觀察與筆記 (Preliminary Observations & Notes)

- **異常數據探討**：[解釋為何 Trial 03 表現異常，是否需排除？]
- **後續調整建議**：[下一波實驗應該調整哪些變數？]
- **下一步**：[將結果彙整至 [[Research_Findings]]]

> ⚠️ **注意事項**：[保存原始資料(Raw Data)的路徑：`/data/raw/exp_01/`]
