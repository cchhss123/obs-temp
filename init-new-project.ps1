<#
.SYNOPSIS
    一鍵從 obs-temp 建立全新專案的 Obsidian 知識庫 Vault。

.DESCRIPTION
    複製 D:\_obs\obs-temp 至 D:\_obs\obs-<ProjectKey>，並自動替換所有模板變數。

.PARAMETER ProjectKey
    專案簡短代號（英文/數字/連字號），例如：smart-prod, crm-v2, line-order

.PARAMETER ProjectName
    專案中文/全稱名稱，例如：智慧生產後端系統, 會員點餐SaaS平台

.PARAMETER RepoPath
    對應的代碼倉庫路徑，預設為 D:\_giti3\<ProjectKey>

.EXAMPLE
    .\init-new-project.ps1 -ProjectKey "line-store" -ProjectName "LINE多租戶點餐系統"
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectKey,

    [Parameter(Mandatory=$true)]
    [string]$ProjectName,

    [Parameter(Mandatory=$false)]
    [string]$RepoPath = "D:\_giti3\$ProjectKey",

    [Parameter(Mandatory=$false)]
    [string]$Author = "cchhss"
)

$SourceDir = $PSScriptRoot
$TargetDir = "D:\_obs\obs-$ProjectKey"
$Today = (Get-Date).ToString("yyyy-MM-dd")

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🚀 正在建立新專案知識庫：" -ForegroundColor Green
Write-Host "   專案代號: $ProjectKey"
Write-Host "   專案名稱: $ProjectName"
Write-Host "   目標路徑: $TargetDir"
Write-Host "   代碼路徑: $RepoPath"
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
    $content = $content.Replace("{{CURRENT_DATE}}", $Today)
    $content = $content.Replace("{{REPO_PATH}}", $RepoPath)
    $content = $content.Replace("{{AUTHOR}}", $Author)
    
    [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
    Write-Host "   ✓ 已更新: $($file.Name)" -ForegroundColor Gray
}

Write-Host "`n🎉 專案知識庫建立完成！" -ForegroundColor Green
Write-Host "👉 Obsidian 開啟路徑: $TargetDir" -ForegroundColor Yellow
