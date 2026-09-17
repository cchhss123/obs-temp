<#
.SYNOPSIS
    一鍵從 obs-temp 建立全新專案的 Obsidian 知識庫 Vault（支援全新專案與舊系統擴充雙模式、多代碼倉庫綁定）。

.DESCRIPTION
    複製 D:\_obs\obs-temp 至 D:\_obs\obs-<ProjectKey>，並自動替換所有模板變數、產生多倉庫 Markdown 表格。

.PARAMETER ProjectKey
    專案簡短代號（英文/數字/連字號），例如：smart-prod, crm-v2, ezvas

.PARAMETER ProjectName
    專案中文/全稱名稱，例如：智慧生產後端系統, ezvas電子工單系統

.PARAMETER Mode
    專案開發模式：
    - GreenField（預設）：全新從0到1專案開發
    - LegacyModule：既有舊系統之新模組擴充/重構

.PARAMETER RepoPaths
    對應的代碼倉庫路徑陣列，支援傳入多個路徑（例如前端、後端、後台）。
    預設為 @("D:\_giti3\<ProjectKey>")

.PARAMETER Author
    負責人名稱，預設為 cchhss

.EXAMPLE
    # 範例 1：最簡全新專案
    .\init-new-project.ps1 -ProjectKey "crm-v2" -ProjectName "新世代CRM系統"

.EXAMPLE
    # 範例 2：多 Repo 舊系統新模組擴充
    .\init-new-project.ps1 `
        -ProjectKey "ezvas" `
        -ProjectName "ezvas電子工單系統" `
        -Mode "LegacyModule" `
        -RepoPaths "D:\_giti3\ezvas-backend", "D:\_giti3\ezvas-frontend", "D:\_giti3\ezvas-admin"
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectKey,

    [Parameter(Mandatory=$true)]
    [string]$ProjectName,

    [Parameter(Mandatory=$false)]
    [ValidateSet("GreenField", "LegacyModule")]
    [string]$Mode = "GreenField",

    [Parameter(Mandatory=$false)]
    [string[]]$RepoPaths,

    [Parameter(Mandatory=$false)]
    [string]$Author = "cchhss"
)

# 處理預設 Repo 路徑
if (-not $RepoPaths -or $RepoPaths.Count -eq 0) {
    $RepoPaths = @("D:\_giti3\$ProjectKey")
}

$SourceDir = $PSScriptRoot
$TargetDir = "D:\_obs\obs-$ProjectKey"
$Today = (Get-Date).ToString("yyyy-MM-dd")

$ModeLabel = if ($Mode -eq "LegacyModule") {
    "🔄 LegacyModule（舊系統新模組擴充 / 多倉庫整合）"
} else {
    "🌱 GreenField（全新從 0 到 1 專案開發）"
}

# 建立多倉庫 Markdown 表格
$targetNormalized = $TargetDir.Replace("\", "/")
$RepoTableLines = @(
    "| 倉庫角色 | 本機 Git 路徑 | 職責與技術棧 |",
    "| :--- | :--- | :--- |",
    "| **知識大腦** | [``$TargetDir``](file:///$targetNormalized) | 需求規劃、架構、日誌、ADR |"
)

for ($i = 0; $i -lt $RepoPaths.Count; $i++) {
    $p = $RepoPaths[$i].Trim()
    $pNormalized = $p.Replace("\", "/")
    $roleName = if ($RepoPaths.Count -eq 1) {
        "主代碼庫"
    } else {
        "代碼庫 $($i + 1)"
    }
    $RepoTableLines += "| **$roleName** | [``$p``](file:///$pNormalized) | 業務邏輯實作與測試 |"
}
$RepoTableMarkdown = $RepoTableLines -join "`r`n"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🚀 正在建立新專案知識庫 (obs-temp 2.0)：" -ForegroundColor Green
Write-Host "   專案代號: $ProjectKey"
Write-Host "   專案名稱: $ProjectName"
Write-Host "   專案模式: $ModeLabel"
Write-Host "   目標路徑: $TargetDir"
Write-Host "   關聯倉庫: $($RepoPaths -join ', ')"
Write-Host "=================================================="

if (Test-Path $TargetDir) {
    Write-Error "❌ 目標目錄已存在：$TargetDir。操作已中止以防覆蓋。"
    exit 1
}

# 1. 複製範本目錄（排除腳本自身與 git）
Copy-Item -Path $SourceDir -Destination $TargetDir -Recurse -Force
Remove-Item -Path "$TargetDir\init-new-project.ps1" -Force -ErrorAction SilentlyContinue
if (Test-Path "$TargetDir\.git") {
    Remove-Item -Path "$TargetDir\.git" -Recurse -Force -ErrorAction SilentlyContinue
}

# 2. 遍歷所有 Markdown 檔案並替換佔位符
$MdFiles = Get-ChildItem -Path $TargetDir -Filter "*.md" -Recurse

foreach ($file in $MdFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    $content = $content.Replace("{{PROJECT_NAME}}", $ProjectName)
    $content = $content.Replace("{{PROJECT_KEY}}", $ProjectKey)
    $content = $content.Replace("{{PROJECT_MODE_LABEL}}", $ModeLabel)
    $content = $content.Replace("{{REPO_TABLE_MARKDOWN}}", $RepoTableMarkdown)
    $content = $content.Replace("{{CURRENT_DATE}}", $Today)
    $content = $content.Replace("{{AUTHOR}}", $Author)
    
    [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
    Write-Host "   ✓ 已更新: $($file.Name)" -ForegroundColor Gray
}

Write-Host "`n🎉 專案知識庫建立完成！" -ForegroundColor Green
Write-Host "👉 Obsidian 開啟路徑: $TargetDir" -ForegroundColor Yellow
Write-Host "👉 建議將 [$TargetDir] 與關聯代碼倉庫加入 Antigravity 工作區開始開發！" -ForegroundColor Cyan
