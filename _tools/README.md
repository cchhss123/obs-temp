# 🛠️ 專案輕量級工具箱 (_tools)

> **設計哲學**：
> 1. **零第三方依賴 (Zero Dependency)**：堅持使用 Python 3 內建標準庫（`zipfile`, `xml`, `urllib`, `argparse`），在任何未配置 Python 虛擬環境的精簡主機、Windows 或 Docker 容器中皆能即開即用。
> 2. **領域中立 (Domain-Neutral)**：工具專注於「非結構化文件純文字/表格提取」與「端點探測」，通用於軟體開發、商業分析、學術論文等各種知識管理情境。
> 3. **AI 輔助友善**：支援 stdout 預覽與 Markdown 格式輸出，方便 AI 助手快速載入上下文進行分析。

---

## 📦 工具庫清單與用法

### 1. `read_docx.py` — Word 文件零依賴文字提取器
純標準庫解析 `.docx`（`word/document.xml`），提取所有段落文字。

```bash
# 預覽前 50 段
python _tools/read_docx.py _docs/_raw_documents/規格書.docx

# 指定提取特定段落數
python _tools/read_docx.py _docs/_raw_documents/規格書.docx -p 20

# 完整導出為 Markdown / 文字檔
python _tools/read_docx.py _docs/_raw_documents/規格書.docx -o _docs/context/01_規劃與計畫/Plan_提取規格.md
```

---

### 2. `read_xlsx.py` — Excel 表格提取與工作表探測器
純標準庫解析 `.xlsx`，支援多工作表名稱探測與 Markdown 表格轉換。

```bash
# 步驟 1：探測工作簿所有分頁名稱
python _tools/read_xlsx.py _docs/_raw_documents/資料字典.xlsx --list-sheets

# 步驟 2：讀取指定工作表（依名稱或編號），預覽為 Markdown 表格
python _tools/read_xlsx.py _docs/_raw_documents/資料字典.xlsx -s "使用者主檔"

# 步驟 3：將指定分頁匯出至 Markdown 檔供長期記憶引用
python _tools/read_xlsx.py _docs/_raw_documents/資料字典.xlsx -s 2 -o _docs/context/02_技術研究與分析/Table_欄位規格.md
```

---

### 3. `probe_health.py` — 服務端點健康檢查與延遲探測器
純標準庫進行 HTTP/HTTPS 連線探測，回傳狀態碼與耗時（毫秒），適用於部署前後冒煙測試。

```bash
# 探測單一或多個服務網址
python _tools/probe_health.py http://localhost:8080/api/health http://10.11.12.176/admin/

# 指定超時與忽略自簽憑證
python _tools/probe_health.py https://staging.internal/ping -t 3 --insecure
```

---

### 4. `deploy_template.py.sample` — 遠端自動化部署參考範本
提供「遠端備份 ➔ SFTP/SCP 同步 ➔ 語法檢查 ➔ Docker 重啟 ➔ 冒煙驗證」的五部曲標準結構。
可複製為專案自訂腳本（例如 `deploy_backend.py`）進行客製化。

---

## 💡 擴充原則
若專案需要新增自訂工具，請遵循以下原則：
- 優先使用標準庫，避免強加第三方套件安裝成本。
- 若必須引入特定套件（如資料庫驅動），請在腳本開頭提供明確的安裝指示與降級容錯方案。
