<#
.SYNOPSIS
    一鍵從 obs-temp 建立全新專案的 Obsidian 知識庫 Vault（v2.3.0 跨領域多態性支援）。

.DESCRIPTION
    複製 D:\_obs\obs-temp 至 D:\_obs\obs-<ProjectKey>，並自動依據開發領域動態生成資源表格、
    按需複製領域專屬模板，並精確裁剪非相關領域資產。
    
    支援單一 -Mode 階層前綴與波斯泰爾寬鬆容錯輸入（PascalCase / kebab-case / 歷史相容別名）。
    支援向下相容之 -RepoPaths 字串陣列，以及語意化 -RepoMap 具名雜湊表。

.PARAMETER ProjectKey
    專案簡短代號（英文/數字/連字號），例如：smart-prod, crm-v2, gtm-apac, thesis-ai

.PARAMETER ProjectName
    專案中文/全稱名稱，例如：智慧生產後端系統, 亞太出海GTM策略, 多模態深度學習研究

.PARAMETER Mode
    專案領域與模式（支援寬鬆輸入）：
    - 軟體工程：SoftwareGreenField（預設, 別名: GreenField）、SoftwareLegacy（別名: LegacyModule）
    - 商業管理：Business（綜合商業企劃/運營）、BusinessMarket（市場調研/出海/GTM）
    - 學術研究：Research（論文研究/假說驗證/文獻回顧）

.PARAMETER RepoPaths
    （向下相容）關聯實體路徑陣列。
    軟體模式下預設為 @("D:\_giti3\<ProjectKey>")；商業模式為 @("D:\_biz\<ProjectKey>")；研究模式為 @("D:\_data\<ProjectKey>")。

.PARAMETER RepoMap
    （語意化推薦）具名資源雜湊表，精確定義每個資源的角色名稱與實體/雲端路徑。
    例如：
      軟體：@{ "後端API"="D:\_giti3\api"; "前端Web"="D:\_giti3\web" }
      商業：@{ "CRM系統"="https://crm.company.com"; "ERP資料庫"="D:\_nas\erp" }
      研究：@{ "原始數據集"="D:\_datasets\eeg"; "文獻庫"="D:\_zotero\library" }

.PARAMETER Author
    負責人名稱，預設為 cchhss

.EXAMPLE
    # 範例 1：預設全新軟體專案
    .\init-new-project.ps1 -ProjectKey "crm-v2" -ProjectName "新世代CRM系統"

.EXAMPLE
    # 範例 2：歷史別名向下相容 (LegacyModule)
    .\init-new-project.ps1 -ProjectKey "ezvas" -ProjectName "ezvas電子工單系統" -Mode "LegacyModule"

.EXAMPLE
    # 範例 3：商業出海 GTM 專案 (寬鬆 kebab-case)
    .\init-new-project.ps1 -ProjectKey "apac-gtm" -ProjectName "亞太品牌出海專案" -Mode "business-market"

.EXAMPLE
    # 範例 4：學術研究專案與自訂數據資產
    .\init-new-project.ps1 `
        -ProjectKey "thesis-eeg" `
        -ProjectName "腦波訊號深度學習分析研究" `
        -Mode "Research" `
        -RepoMap @{
            "腦電原始數據" = "D:\_datasets\eeg_raw";
            "特徵工程腳本" = "D:\_research\eeg_pipeline";
            "Zotero 文獻庫" = "D:\_zotero\neuro_ai"
        }
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectKey,

    [Parameter(Mandatory=$true)]
    [string]$ProjectName,

    [Parameter(Mandatory=$false)]
    [string]$Mode = "SoftwareGreenField",

    [Parameter(Mandatory=$false)]
    [string[]]$RepoPaths,

    [Parameter(Mandatory=$false)]
    [hashtable]$RepoMap,

    [Parameter(Mandatory=$false)]
    [string]$Author = "cchhss"
)

# ==============================================================================
# 1. 波斯泰爾寬鬆容錯正規化 (Postel's Law Normalization - ADR-07)
# ==============================================================================
$rawMode = $Mode.Trim()
$normalizedMode = $rawMode.ToLower().Replace("-", "").Replace("_", "")

$CanonicalMode = ""
$Domain = ""

switch ($normalizedMode) {
    "softwaregreenfield" { $CanonicalMode = "SoftwareGreenField"; $Domain = "Software" }
    "greenfield"         { $CanonicalMode = "SoftwareGreenField"; $Domain = "Software" } # 向下相容歷史別名
    "softwarelegacy"     { $CanonicalMode = "SoftwareLegacy";     $Domain = "Software" }
    "legacymodule"       { $CanonicalMode = "SoftwareLegacy";     $Domain = "Software" } # 向下相容歷史別名
    "business"           { $CanonicalMode = "Business";           $Domain = "Business" }
    "businessmarket"     { $CanonicalMode = "BusinessMarket";     $Domain = "Business" }
    "research"           { $CanonicalMode = "Research";           $Domain = "Research" }
    default {
        Write-Error "❌ 不支援的專案模式：'$Mode'。`n支援標準值：`n - SoftwareGreenField (相容別名: GreenField, software-greenfield)`n - SoftwareLegacy (相容別名: LegacyModule, software-legacy)`n - Business (相容別名: business)`n - BusinessMarket (相容別名: business-market)`n - Research (相容別名: research)"
        exit 1
    }
}

$ModeLabel = switch ($CanonicalMode) {
    "SoftwareGreenField" { "🌱 SoftwareGreenField（全新從 0 到 1 軟體專案開發）" }
    "SoftwareLegacy"     { "🔄 SoftwareLegacy（既有舊系統之模組擴充 / 多倉庫協同 / 重構）" }
    "Business"           { "💼 Business（綜合商業企劃 / 公司營運管理 / 年度 OKR）" }
    "BusinessMarket"     { "🚀 BusinessMarket（市場調研 / 競品分析 / 品牌出海 / GTM）" }
    "Research"           { "🎓 Research（學術論文研究 / 假說驗證 / 文獻回顧與投稿）" }
}

$SourceDir = $PSScriptRoot
$TargetDir = "D:\_obs\obs-$ProjectKey"
$Today = (Get-Date).ToString("yyyy-MM-dd")
$targetNormalized = $TargetDir.Replace("\", "/")

# ==============================================================================
# 2. 資源關聯表格動態多態性生成 (Dynamic Resource Association - ADR-08)
# ==============================================================================
$RepoTableLines = @()
$DisplayRepoInfo = ""

if ($Domain -eq "Software") {
    $RepoTableLines += "| 倉庫角色 | 本機 Git 路徑 | 職責與技術棧 |"
    $RepoTableLines += "| :--- | :--- | :--- |"
    $RepoTableLines += "| **知識大腦** | [``$TargetDir``](file:///$targetNormalized) | 需求規劃、架構、日誌、ADR |"

    if ($RepoMap -and $RepoMap.Count -gt 0) {
        foreach ($role in $RepoMap.Keys) {
            $p = $RepoMap[$role].ToString().Trim()
            $pNormalized = $p.Replace("\", "/")
            $RepoTableLines += "| **$role** | [``$p``](file:///$pNormalized) | 業務邏輯實作與測試 |"
        }
        $DisplayRepoInfo = ($RepoMap.Keys | ForEach-Object { "$_ -> $($RepoMap[$_])" }) -join "; "
    } else {
        if (-not $RepoPaths -or $RepoPaths.Count -eq 0) {
            $RepoPaths = @("D:\_giti3\$ProjectKey")
        }
        for ($i = 0; $i -lt $RepoPaths.Count; $i++) {
            $p = $RepoPaths[$i].Trim()
            $pNormalized = $p.Replace("\", "/")
            $roleName = if ($RepoPaths.Count -eq 1) { "主代碼庫" } else { "代碼庫 $($i + 1)" }
            $RepoTableLines += "| **$roleName** | [``$p``](file:///$pNormalized) | 業務邏輯實作與測試 |"
        }
        $DisplayRepoInfo = $RepoPaths -join ", "
    }
}
elseif ($Domain -eq "Business") {
    $RepoTableLines += "| 營運資源角色 | 本機 / 雲端路徑 | 系統定位與管理權限 |"
    $RepoTableLines += "| :--- | :--- | :--- |"
    $RepoTableLines += "| **知識大腦** | [``$TargetDir``](file:///$targetNormalized) | 策略規劃、營運指標、會議復盤 |"

    if ($RepoMap -and $RepoMap.Count -gt 0) {
        foreach ($role in $RepoMap.Keys) {
            $p = $RepoMap[$role].ToString().Trim()
            $pNormalized = $p.Replace("\", "/")
            $RepoTableLines += "| **$role** | [``$p``](file:///$pNormalized) | 營運資產管理與流程運作 |"
        }
        $DisplayRepoInfo = ($RepoMap.Keys | ForEach-Object { "$_ -> $($RepoMap[$_])" }) -join "; "
    } else {
        if (-not $RepoPaths -or $RepoPaths.Count -eq 0) {
            $RepoPaths = @("D:\_biz\$ProjectKey")
        }
        for ($i = 0; $i -lt $RepoPaths.Count; $i++) {
            $p = $RepoPaths[$i].Trim()
            $pNormalized = $p.Replace("\", "/")
            $roleName = if ($RepoPaths.Count -eq 1) { "主營運資源目錄" } else { "營運資源 $($i + 1)" }
            $RepoTableLines += "| **$roleName** | [``$p``](file:///$pNormalized) | 營運資產管理與流程運作 |"
        }
        $DisplayRepoInfo = $RepoPaths -join ", "
    }
}
elseif ($Domain -eq "Research") {
    $RepoTableLines += "| 研究資產角色 | 本機路徑 / 數據庫 | 資料規格與用途說明 |"
    $RepoTableLines += "| :--- | :--- | :--- |"
    $RepoTableLines += "| **知識大腦** | [``$TargetDir``](file:///$targetNormalized) | 研究假說、文獻分析、投稿追蹤 |"

    if ($RepoMap -and $RepoMap.Count -gt 0) {
        foreach ($role in $RepoMap.Keys) {
            $p = $RepoMap[$role].ToString().Trim()
            $pNormalized = $p.Replace("\", "/")
            $RepoTableLines += "| **$role** | [``$p``](file:///$pNormalized) | 研究實驗數據與分析腳本 |"
        }
        $DisplayRepoInfo = ($RepoMap.Keys | ForEach-Object { "$_ -> $($RepoMap[$_])" }) -join "; "
    } else {
        if (-not $RepoPaths -or $RepoPaths.Count -eq 0) {
            $RepoPaths = @("D:\_data\$ProjectKey")
        }
        for ($i = 0; $i -lt $RepoPaths.Count; $i++) {
            $p = $RepoPaths[$i].Trim()
            $pNormalized = $p.Replace("\", "/")
            $roleName = if ($RepoPaths.Count -eq 1) { "核心實驗數據目錄" } else { "研究數據 $($i + 1)" }
            $RepoTableLines += "| **$roleName** | [``$p``](file:///$pNormalized) | 研究實驗數據與分析腳本 |"
        }
        $DisplayRepoInfo = $RepoPaths -join ", "
    }
}

$RepoTableMarkdown = $RepoTableLines -join "`r`n"

# ==============================================================================
# 3. 目錄檢查與資訊輸出
# ==============================================================================
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🚀 正在建立新專案知識庫 (obs-temp v2.3.0 多領域擴充版)：" -ForegroundColor Green
Write-Host "   專案代號: $ProjectKey"
Write-Host "   專案名稱: $ProjectName"
Write-Host "   領域屬性: $Domain"
Write-Host "   正規化模式: $CanonicalMode"
Write-Host "   模式標籤: $ModeLabel"
Write-Host "   目標路徑: $TargetDir"
Write-Host "   關聯資源: $DisplayRepoInfo"
Write-Host "=================================================="

if (Test-Path $TargetDir) {
    Write-Error "❌ 目標目錄已存在：$TargetDir。操作已中止以防覆蓋。"
    exit 1
}

# ==============================================================================
# 4. 目錄複製與基礎清理
# ==============================================================================
Copy-Item -Path $SourceDir -Destination $TargetDir -Recurse -Force
Remove-Item -Path "$TargetDir\init-new-project.ps1" -Force -ErrorAction SilentlyContinue
if (Test-Path "$TargetDir\.git") {
    Remove-Item -Path "$TargetDir\.git" -Recurse -Force -ErrorAction SilentlyContinue
}

# ==============================================================================
# 5. 跨領域模板與選配資產複製/裁剪矩陣 (ADR-10 方案 A+)
# ==============================================================================
# 5.1 CLAUDE.md 變體處理 (若目標存在 CLAUDE_<Domain>.md 則覆蓋並清除其他變體)
$claudeDomainVariant = "$TargetDir\CLAUDE_$Domain.md"
if (Test-Path $claudeDomainVariant) {
    Copy-Item -Path $claudeDomainVariant -Destination "$TargetDir\CLAUDE.md" -Force
}
Get-ChildItem -Path $TargetDir -Filter "CLAUDE_*.md" | Remove-Item -Force -ErrorAction SilentlyContinue

# 5.2 依領域裁剪專屬模板與模組
if ($Domain -eq "Software") {
    # 軟體模式：裁剪商業與研究專屬模板
    Remove-Item -Path "$TargetDir\_docs\_templates\business" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$TargetDir\_docs\_templates\research" -Recurse -Force -ErrorAction SilentlyContinue
}
elseif ($Domain -eq "Business") {
    # 商業模式：保留 business/ 模板，裁剪非相關研究模板
    Remove-Item -Path "$TargetDir\_docs\_templates\research" -Recurse -Force -ErrorAction SilentlyContinue

    # 裁剪軟體專屬核心模板 (保留 tpl_ADR.md)
    @("tpl_Plan.md", "tpl_Walkthrough.md", "tpl_Research.md", "tpl_Server_Environment.md", "tpl_Docker_Architecture.md") | ForEach-Object {
        Remove-Item -Path "$TargetDir\_docs\_templates\$_" -Force -ErrorAction SilentlyContinue
    }

    # 裁剪軟體專屬 optional 模板 (保留 tpl_Meeting_Briefing, tpl_Project_Showcase, tpl_AI_Chat_Summary, tpl_obs_temp_enhancement_proposal)
    @("tpl_Eng_Review.md", "tpl_Smoke_Test.md") | ForEach-Object {
        Remove-Item -Path "$TargetDir\_docs\_templates\optional\$_" -Force -ErrorAction SilentlyContinue
    }

    # 裁剪軟體選配體系
    Remove-Item -Path "$TargetDir\_docs\workflows" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$TargetDir\_docs\context\02_技術研究與分析\patterns" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$TargetDir\_docs\技術債與延後決策.md" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$TargetDir\_docs\選配體系使用指南.md" -Force -ErrorAction SilentlyContinue
}
elseif ($Domain -eq "Research") {
    # 學術研究模式：保留 research/ 模板，裁剪商業專屬模板
    Remove-Item -Path "$TargetDir\_docs\_templates\business" -Recurse -Force -ErrorAction SilentlyContinue

    # 裁剪軟體專屬核心模板 (保留 tpl_ADR.md)
    @("tpl_Plan.md", "tpl_Walkthrough.md", "tpl_Research.md", "tpl_Server_Environment.md", "tpl_Docker_Architecture.md") | ForEach-Object {
        Remove-Item -Path "$TargetDir\_docs\_templates\$_" -Force -ErrorAction SilentlyContinue
    }

    # 裁剪軟體專屬 optional 模板 (保留 tpl_AI_Chat_Summary, tpl_obs_temp_enhancement_proposal)
    @("tpl_Eng_Review.md", "tpl_Smoke_Test.md", "tpl_Meeting_Briefing.md", "tpl_Project_Showcase.md") | ForEach-Object {
        Remove-Item -Path "$TargetDir\_docs\_templates\optional\$_" -Force -ErrorAction SilentlyContinue
    }

    # 裁剪軟體選配體系
    Remove-Item -Path "$TargetDir\_docs\workflows" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$TargetDir\_docs\context\02_技術研究與分析\patterns" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$TargetDir\_docs\技術債與延後決策.md" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$TargetDir\_docs\選配體系使用指南.md" -Force -ErrorAction SilentlyContinue
}

# ==============================================================================
# 6. 遍歷 Markdown 檔案並替換佔位符
# ==============================================================================
$MdFiles = Get-ChildItem -Path $TargetDir -Filter "*.md" -Recurse

foreach ($file in $MdFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    $content = $content.Replace("{{PROJECT_NAME}}", $ProjectName)
    $content = $content.Replace("{{PROJECT_KEY}}", $ProjectKey)
    $content = $content.Replace("{{PROJECT_MODE_LABEL}}", $ModeLabel)
    $content = $content.Replace("{{REPO_TABLE_MARKDOWN}}", $RepoTableMarkdown)
    $content = $content.Replace("{{CURRENT_DATE}}", $Today)
    $content = $content.Replace("{{DATE}}", $Today)
    $content = $content.Replace("{{AUTHOR}}", $Author)
    
    [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
    Write-Host "   ✓ 已更新: $($file.FullName.Replace($TargetDir, ''))" -ForegroundColor Gray
}

Write-Host "`n🎉 專案知識庫建立完成！" -ForegroundColor Green
Write-Host "👉 Obsidian 開啟路徑: $TargetDir" -ForegroundColor Yellow
Write-Host "👉 包含 _tools/ 工具庫與 _docs/_raw_documents/ 原始文檔池。" -ForegroundColor Yellow
Write-Host "👉 領域專屬模板與裁剪機制已生效 ($Domain - $CanonicalMode)。" -ForegroundColor Yellow
Write-Host "👉 建議將 [$TargetDir] 與關聯資源加入 Antigravity 工作區開始協同！" -ForegroundColor Cyan
