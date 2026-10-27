# ============================================
# 游戏运行库自动检测安装工具 v2.1
# ============================================

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $result = [System.Windows.Forms.MessageBox]::Show(
        "此工具需要管理员权限才能安装运行库。`n`n是否以管理员身份重新启动？",
        "需要管理员权限",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($result -eq "Yes") {
        Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    } else {
        [System.Windows.Forms.MessageBox]::Show("未获取管理员权限，部分功能可能无法使用。", "提示", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Script:Is64Bit = [Environment]::Is64BitOperatingSystem
$Script:Arch = if ($Script:Is64Bit) { "x64" } else { "x86" }

$Script:LogDir = Join-Path $PSScriptRoot "日志"
if (-not (Test-Path $Script:LogDir)) {
    New-Item -ItemType Directory -Path $Script:LogDir -Force | Out-Null
}
$Script:LogFile = Join-Path $Script:LogDir ("运行库安装日志_{0}.txt" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $Script:LogFile -Value $logEntry -Encoding UTF8
}

Write-Log "========== 程序启动 =========="
Write-Log "系统架构：$Script:Arch"

$Script:CacheDir = Join-Path $PSScriptRoot "运行库缓存"
if (-not (Test-Path $Script:CacheDir)) {
    New-Item -ItemType Directory -Path $Script:CacheDir -Force | Out-Null
}
Write-Log "缓存目录：$Script:CacheDir"

function Test-RegistryPath {
    param([string]$Path)
    $paths = @($Path)
    if ($Script:Is64Bit -and $Path -notlike "*WOW6432Node*") {
        $wowPath = $Path -replace 'HKLM:\\SOFTWARE\\', 'HKLM:\SOFTWARE\WOW6432Node\'
        $paths += $wowPath
    }
    foreach ($p in $paths) {
        if (Test-Path $p) { return $true }
    }
    return $false
}

$Script:Runtimes = @(
    @{
        Name = "Visual C++ 2005 x86"
        Category = "common"
        Arch = "x86"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A49F249F-0C91-497F-86DF-B2585E8E76B7}" }
        DownloadUrl = "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE"
        FileName = "vcredist_2005_x86.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2005 x64"
        Category = "common"
        Arch = "x64"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{ad8a2fa1-06e7-4b0d-927d-6e54b3d31028}" }
        DownloadUrl = "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE"
        FileName = "vcredist_2005_x64.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2008 x86"
        Category = "common"
        Arch = "x86"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}" }
        DownloadUrl = "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe"
        FileName = "vcredist_2008_x86.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2008 x64"
        Category = "common"
        Arch = "x64"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4}" }
        DownloadUrl = "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe"
        FileName = "vcredist_2008_x64.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2010 x86"
        Category = "common"
        Arch = "x86"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1F4F1D2A-D9DA-32CF-9909-48485DA06DD5}" }
        DownloadUrl = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe"
        FileName = "vcredist_2010_x86.exe"
        InstallArgs = "/q /norestart"
    },
    @{
        Name = "Visual C++ 2010 x64"
        Category = "common"
        Arch = "x64"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{932CC528-46B4-3553-8D01-B657B5404E2A}" }
        DownloadUrl = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe"
        FileName = "vcredist_2010_x64.exe"
        InstallArgs = "/q /norestart"
    },
    @{
        Name = "Visual C++ 2012 x86"
        Category = "common"
        Arch = "x86"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{BD95A8CD-1D9F-35AD-981A-3E7925026EBB}" }
        DownloadUrl = "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe"
        FileName = "vcredist_2012_x86.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "Visual C++ 2012 x64"
        Category = "common"
        Arch = "x64"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CF2BEA3C-26EA-32F8-AA9B-331F7E34BA97}" }
        DownloadUrl = "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"
        FileName = "vcredist_2012_x64.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "Visual C++ 2013 x86"
        Category = "common"
        Arch = "x86"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F65DB027-FBEF-3678-915C-18EC053634AF}" }
        DownloadUrl = "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe"
        FileName = "vcredist_2013_x86.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "Visual C++ 2013 x64"
        Category = "common"
        Arch = "x64"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{DE2C306F-A067-38EF-B86C-03DE4B0312F9}" }
        DownloadUrl = "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe"
        FileName = "vcredist_2013_x64.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "Visual C++ 2015-2022 x86"
        Category = "common"
        Arch = "x86"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" }
        DownloadUrl = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
        FileName = "vc_redist_2015-2022_x86.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "Visual C++ 2015-2022 x64"
        Category = "common"
        Arch = "x64"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" }
        DownloadUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
        FileName = "vc_redist_2015-2022_x64.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "DirectX 最终用户运行库"
        Category = "common"
        Arch = "both"
        CheckScript = { (Test-Path "C:\Windows\System32\d3dx9_43.dll") -or (Test-Path "C:\Windows\SysWOW64\d3dx9_43.dll") }
        DownloadUrl = "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe"
        FileName = "directx_Jun2010_redist.exe"
        InstallArgs = "/Q /T:$env:TEMP\dx_extract"
        PreExtract = $true
    },
    @{
        Name = ".NET Framework 3.5"
        Category = "common"
        Arch = "both"
        CheckScript = {
            $reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" -ErrorAction SilentlyContinue
            $reg -and $reg.Install -eq 1
        }
        DownloadUrl = $null
        UseWindowsFeature = $true
        FileName = $null
        InstallArgs = $null
    },
    @{
        Name = ".NET Framework 4.8"
        Category = "common"
        Arch = "both"
        CheckScript = {
            $reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue
            $reg -and $reg.Release -ge 528040
        }
        DownloadUrl = "https://go.microsoft.com/fwlink/?linkid=2203217"
        FileName = "ndp48-x86-x64-allos-enu.exe"
        InstallArgs = "/q /norestart"
    },
    @{
        Name = "Java Runtime (JRE) 8"
        Category = "optional"
        Arch = "both"
        CheckScript = { (Test-RegistryPath "HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment\1.8") -or (Test-Path "C:\Program Files\Java\jre1.8*") -or (Test-Path "C:\Program Files (x86)\Java\jre1.8*") }
        DownloadUrl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=248279_89d678f2be164786b292527658ca1605"
        FileName = "jre-8-windows-x64.exe"
        InstallArgs = "/s"
    },
    @{
        Name = "OpenAL 音频库"
        Category = "optional"
        Arch = "both"
        CheckScript = { (Test-RegistryPath "HKLM:\SOFTWARE\OpenAL") -or (Test-Path "C:\Windows\System32\OpenAL32.dll") }
        DownloadUrl = "https://www.openal.org/downloads/oalinst.zip"
        FileName = "oalinst.zip"
        InstallArgs = "/S"
        IsArchive = $true
    },
    @{
        Name = "PhysX 物理引擎"
        Category = "optional"
        Arch = "both"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\NVIDIA Corporation\PhysX" }
        DownloadUrl = "https://us.download.nvidia.com/GFE/PACKAGES/PhysX/9.23.1019/PhysX_9.23.1019_SystemSoftware.exe"
        FileName = "PhysX_SystemSoftware.exe"
        InstallArgs = "/s"
    },
    @{
        Name = "XNA Framework 3.1"
        Category = "optional"
        Arch = "both"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\XNA\Framework\v3.1" }
        DownloadUrl = "https://download.microsoft.com/download/A/C/2/AC2C900B-D931-47E0-BB5F-3A0B200BACD0/xnafx31_redist.msi"
        FileName = "xnafx31_redist.msi"
        InstallArgs = "/q /norestart"
    },
    @{
        Name = "XNA Framework 4.0"
        Category = "optional"
        Arch = "both"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\XNA\Framework\v4.0" }
        DownloadUrl = "https://download.microsoft.com/download/E/4/1/E4173890-A24A-4936-9FC9-AF930FE3FA40/xnafx40_redist.msi"
        FileName = "xnafx40_redist.msi"
        InstallArgs = "/q /norestart"
    },
    @{
        Name = "Games for Windows LIVE"
        Category = "optional"
        Arch = "both"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Games for Windows - LIVE" }
        DownloadUrl = "https://download.microsoft.com/download/C/4/9/C4921094-9125-4DBE-A55B-1C53D7F5333E/gfwlivesetup.exe"
        FileName = "gfwlivesetup.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Microsoft Games for Windows Marketplace"
        Category = "optional"
        Arch = "both"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Games for Windows - LIVE\Client" }
        DownloadUrl = "https://download.microsoft.com/download/4/1/7/4179E479-C595-4732-8092-687312D0D29E/gfwmsetup.exe"
        FileName = "gfwmsetup.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2008 SP1 ATL 安全更新"
        Category = "optional"
        Arch = "x86"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1F1C2DFC-2D24-3E06-BCB8-725134ADF989}" }
        DownloadUrl = "https://download.microsoft.com/download/3/2/2/3224B87F-CFA0-4E70-BDA3-3DE650EFEBA5/vcredist_x86.exe"
        FileName = "vcredist_2008_sp1_x86.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2008 SP1 ATL 安全更新 x64"
        Category = "optional"
        Arch = "x64"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{30300800-95FE-3846-A80A-EB4B0C4F0FBE}" }
        DownloadUrl = "https://download.microsoft.com/download/3/2/2/3224B87F-CFA0-4E70-BDA3-3DE650EFEBA5/vcredist_x64.exe"
        FileName = "vcredist_2008_sp1_x64.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Runtimes (All-in-One) 2024"
        Category = "common"
        Arch = "both"
        CheckScript = {
            $has2022x86 = Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86"
            $has2022x64 = Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64"
            $has2022x86 -and $has2022x64
        }
        DownloadUrl = "https://github.com/abbodi1406/vcredist/releases/download/v0.74.0/VisualCppRedist_AIO_x86_x64_74.zip"
        FileName = "VisualCppRedist_AIO_x86_x64_74.zip"
        InstallArgs = ""
        IsArchive = $true
    },
    @{
        Name = ".NET Desktop Runtime 6.0"
        Category = "common"
        Arch = "x64"
        CheckScript = {
            Test-Path "HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.WindowsDesktop.App\6.0*"
        }
        DownloadUrl = "https://download.visualstudio.microsoft.com/download/pr/3330b6ce-1712-4014-b4f0-000000000000/windowsdesktop-runtime-6.0.36-win-x64.exe"
        FileName = "windowsdesktop-runtime-6.0.36-win-x64.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "Microsoft Edge WebView2"
        Category = "common"
        Arch = "both"
        CheckScript = { Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" }
        DownloadUrl = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
        FileName = "MicrosoftEdgeWebview2Setup.exe"
        InstallArgs = "/silent /install"
    },
    @{
        Name = "Microsoft Build of OpenJDK 17"
        Category = "optional"
        Arch = "x64"
        CheckScript = { (Test-RegistryPath "HKLM:\SOFTWARE\Microsoft\JDK\17*") -or (Test-Path "C:\Program Files\Microsoft\jdk-*") }
        DownloadUrl = "https://aka.ms/download-jdk/microsoft-jdk-17-windows-x64.msi"
        FileName = "microsoft-jdk-17-windows-x64.msi"
        InstallArgs = "/q /norestart"
    }
)

$form = New-Object System.Windows.Forms.Form
$form.Text = "游戏运行库自动检测安装工具 v2.1"
$form.Size = New-Object System.Drawing.Size(780, 650)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "游戏运行库检测与安装"
$titleLabel.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(20, 15)
$titleLabel.AutoSize = $true
$form.Controls.Add($titleLabel)

$archLabel = New-Object System.Windows.Forms.Label
$archLabel.Text = "系统：$Script:Arch"
$archLabel.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$archLabel.Location = New-Object System.Drawing.Point(680, 18)
$archLabel.AutoSize = $true
$archLabel.ForeColor = [System.Drawing.Color]::Gray
$form.Controls.Add($archLabel)

$cacheDirLabel = New-Object System.Windows.Forms.Label
$cacheDirLabel.Text = "缓存目录:"
$cacheDirLabel.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$cacheDirLabel.Location = New-Object System.Drawing.Point(20, 50)
$cacheDirLabel.AutoSize = $true
$form.Controls.Add($cacheDirLabel)

$cacheDirTextBox = New-Object System.Windows.Forms.TextBox
$cacheDirTextBox.Text = $Script:CacheDir
$cacheDirTextBox.Size = New-Object System.Drawing.Size(480, 25)
$cacheDirTextBox.Location = New-Object System.Drawing.Point(90, 47)
$cacheDirTextBox.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$form.Controls.Add($cacheDirTextBox)

$btnChangeCacheDir = New-Object System.Windows.Forms.Button
$btnChangeCacheDir.Text = "浏览..."
$btnChangeCacheDir.Size = New-Object System.Drawing.Size(70, 25)
$btnChangeCacheDir.Location = New-Object System.Drawing.Point(580, 46)
$btnChangeCacheDir.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$form.Controls.Add($btnChangeCacheDir)

$btnOpenCacheDir = New-Object System.Windows.Forms.Button
$btnOpenCacheDir.Text = "打开目录"
$btnOpenCacheDir.Size = New-Object System.Drawing.Size(80, 25)
$btnOpenCacheDir.Location = New-Object System.Drawing.Point(660, 46)
$btnOpenCacheDir.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$form.Controls.Add($btnOpenCacheDir)

$selectAllBtn = New-Object System.Windows.Forms.Button
$selectAllBtn.Text = "全选缺失项"
$selectAllBtn.Size = New-Object System.Drawing.Size(100, 28)
$selectAllBtn.Location = New-Object System.Drawing.Point(20, 80)
$selectAllBtn.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$form.Controls.Add($selectAllBtn)

$deselectAllBtn = New-Object System.Windows.Forms.Button
$deselectAllBtn.Text = "取消全选"
$deselectAllBtn.Size = New-Object System.Drawing.Size(100, 28)
$deselectAllBtn.Location = New-Object System.Drawing.Point(130, 80)
$deselectAllBtn.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$form.Controls.Add($deselectAllBtn)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "点击「检测」开始扫描，然后「下载」→「安装」"
$statusLabel.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$statusLabel.Location = New-Object System.Drawing.Point(250, 86)
$statusLabel.AutoSize = $true
$form.Controls.Add($statusLabel)

$dataGrid = New-Object System.Windows.Forms.DataGridView
$dataGrid.Location = New-Object System.Drawing.Point(20, 118)
$dataGrid.Size = New-Object System.Drawing.Size(725, 420)
$dataGrid.AllowUserToAddRows = $false
$dataGrid.AllowUserToDeleteRows = $false
$dataGrid.ReadOnly = $false
$dataGrid.SelectionMode = "FullRowSelect"
$dataGrid.RowHeadersVisible = $false
$dataGrid.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$dataGrid.ColumnHeadersDefaultCellStyle.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9, [System.Drawing.FontStyle]::Bold)
$dataGrid.BackgroundColor = [System.Drawing.Color]::White
$dataGrid.GridColor = [System.Drawing.Color]::LightGray
$dataGrid.EnableHeadersVisualStyles = $false
$dataGrid.ColumnHeadersHeight = 30

$colCheck = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn
$colCheck.HeaderText = "选择"
$colCheck.Width = 50
$colCheck.Name = "Check"

$colName = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colName.HeaderText = "运行库名称"
$colName.Width = 230
$colName.Name = "Name"
$colName.ReadOnly = $true

$colCategory = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colCategory.HeaderText = "类型"
$colCategory.Width = 50
$colCategory.Name = "Category"
$colCategory.ReadOnly = $true

$colDownloadStatus = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colDownloadStatus.HeaderText = "下载状态"
$colDownloadStatus.Width = 80
$colDownloadStatus.Name = "DownloadStatus"
$colDownloadStatus.ReadOnly = $true

$colInstallStatus = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colInstallStatus.HeaderText = "安装状态"
$colInstallStatus.Width = 80
$colInstallStatus.Name = "InstallStatus"
$colInstallStatus.ReadOnly = $true

$colProgress = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colProgress.HeaderText = "进度/原因"
$colProgress.Width = 230
$colProgress.Name = "Progress"
$colProgress.ReadOnly = $true

$dataGrid.Columns.Add($colCheck)
$dataGrid.Columns.Add($colName)
$dataGrid.Columns.Add($colCategory)
$dataGrid.Columns.Add($colDownloadStatus)
$dataGrid.Columns.Add($colInstallStatus)
$dataGrid.Columns.Add($colProgress)

$form.Controls.Add($dataGrid)

$btnDetect = New-Object System.Windows.Forms.Button
$btnDetect.Text = "检  测"
$btnDetect.Size = New-Object System.Drawing.Size(120, 40)
$btnDetect.Location = New-Object System.Drawing.Point(200, 550)
$btnDetect.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$btnDetect.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnDetect.ForeColor = [System.Drawing.Color]::White
$btnDetect.FlatStyle = "Flat"
$form.Controls.Add($btnDetect)

$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Text = "下  载"
$btnDownload.Size = New-Object System.Drawing.Size(100, 40)
$btnDownload.Location = New-Object System.Drawing.Point(340, 550)
$btnDownload.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$btnDownload.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnDownload.ForeColor = [System.Drawing.Color]::White
$btnDownload.FlatStyle = "Flat"
$btnDownload.Enabled = $false
$form.Controls.Add($btnDownload)

$btnInstallOnly = New-Object System.Windows.Forms.Button
$btnInstallOnly.Text = "安  装"
$btnInstallOnly.Size = New-Object System.Drawing.Size(100, 40)
$btnInstallOnly.Location = New-Object System.Drawing.Point(450, 550)
$btnInstallOnly.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$btnInstallOnly.BackColor = [System.Drawing.Color]::FromArgb(16, 124, 16)
$btnInstallOnly.ForeColor = [System.Drawing.Color]::White
$btnInstallOnly.FlatStyle = "Flat"
$btnInstallOnly.Enabled = $false
$form.Controls.Add($btnInstallOnly)

$btnChangeCacheDir.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "选择运行库安装包缓存目录"
    $folderBrowser.SelectedPath = $cacheDirTextBox.Text
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $cacheDirTextBox.Text = $folderBrowser.SelectedPath
        $Script:CacheDir = $folderBrowser.SelectedPath
        if (-not (Test-Path $Script:CacheDir)) {
            New-Item -ItemType Directory -Path $Script:CacheDir -Force | Out-Null
        }
    }
})

$btnOpenCacheDir.Add_Click({
    $dir = $cacheDirTextBox.Text
    if (Test-Path $dir) {
        Start-Process explorer.exe -ArgumentList $dir
    } else {
        [System.Windows.Forms.MessageBox]::Show("目录不存在：$dir", "提示", "OK", "Warning")
    }
})

$btnDetect.Add_Click({
    $Script:CacheDir = $cacheDirTextBox.Text
    if (-not (Test-Path $Script:CacheDir)) {
        New-Item -ItemType Directory -Path $Script:CacheDir -Force | Out-Null
    }

    $statusLabel.Text = "正在检测..."
    $btnDetect.Enabled = $false
    $btnDownload.Enabled = $false
    $btnInstallOnly.Enabled = $false
    $dataGrid.Rows.Clear()
    $form.Refresh()

    $filteredRuntimes = $Script:Runtimes | Where-Object {
        $_.Arch -eq "both" -or $_.Arch -eq $Script:Arch
    }

    foreach ($rt in $filteredRuntimes) {
        $installed = & $rt.CheckScript
        $categoryText = if ($rt.Category -eq "common") { "通用" } else { "可选" }

        $cacheFile = Join-Path $Script:CacheDir $rt.FileName
        $partialFile = "$cacheFile.partial"
        $downloaded = (Test-Path $cacheFile) -and (-not (Test-Path $partialFile))

        $downloadStatusText = if ($rt.UseWindowsFeature) {
            "无需下载"
        } elseif ($downloaded) {
            "已下载"
        } else {
            "未下载"
        }

        $rowIndex = $dataGrid.Rows.Add()
        $row = $dataGrid.Rows[$rowIndex]
        $row.Cells["Check"].Value = (-not $installed -and $rt.Category -eq "common")
        $row.Cells["Name"].Value = $rt.Name
        $row.Cells["Category"].Value = $categoryText
        $row.Cells["DownloadStatus"].Value = $downloadStatusText
        $row.Cells["InstallStatus"].Value = if ($installed) { "已安装" } else { "未安装" }
        $row.Cells["Progress"].Value = ""

        if ($rt.UseWindowsFeature) {
            $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Gray
        } elseif ($downloaded) {
            $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Green
        } else {
            $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Red
        }

        if ($installed) {
            $row.Cells["Check"].ReadOnly = $true
            $row.Cells["InstallStatus"].Style.ForeColor = [System.Drawing.Color]::Green
        } else {
            $row.Cells["InstallStatus"].Style.ForeColor = [System.Drawing.Color]::Red
        }
    }

    $missingCount = ($filteredRuntimes | Where-Object { -not (& $_.CheckScript) }).Count
    $totalCount = $filteredRuntimes.Count
    $statusLabel.Text = "检测完成：$missingCount / $totalCount 项需要安装（已过滤 $Script:Arch 不匹配项）"
    $btnDetect.Enabled = $true
    $btnDownload.Enabled = ($missingCount -gt 0)
    $btnInstallOnly.Enabled = ($missingCount -gt 0)
})

$selectAllBtn.Add_Click({
    foreach ($row in $dataGrid.Rows) {
        if ($row.Cells["InstallStatus"].Value -ne "已安装") {
            $row.Cells["Check"].Value = $true
        }
    }
})

$deselectAllBtn.Add_Click({
    foreach ($row in $dataGrid.Rows) {
        $row.Cells["Check"].Value = $false
    }
})

$btnDownload.Add_Click({
    $Script:CacheDir = $cacheDirTextBox.Text
    if (-not (Test-Path $Script:CacheDir)) {
        New-Item -ItemType Directory -Path $Script:CacheDir -Force | Out-Null
    }

    $selectedRows = @()
    foreach ($row in $dataGrid.Rows) {
        if ($row.Cells["Check"].Value -eq $true -and $row.Cells["InstallStatus"].Value -ne "已安装") {
            $selectedRows += $row
        }
    }

    if ($selectedRows.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("请先选择需要下载的运行库", "提示", "OK", "Information")
        return
    }

    $btnDetect.Enabled = $false
    $btnDownload.Enabled = $false
    $btnInstallOnly.Enabled = $false
    $selectAllBtn.Enabled = $false
    $deselectAllBtn.Enabled = $false
    $btnChangeCacheDir.Enabled = $false
    $btnOpenCacheDir.Enabled = $false

    $totalItems = $selectedRows.Count
    $downloadedCount = 0

    foreach ($row in $selectedRows) {
        $rtName = $row.Cells["Name"].Value
        $rt = $Script:Runtimes | Where-Object { $_.Name -eq $rtName }
        if (-not $rt) { continue }

        if ($rt.UseWindowsFeature) {
            $row.Cells["DownloadStatus"].Value = "无需下载"
            $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Gray
            $row.Cells["Progress"].Value = "系统功能，安装时自动启用"
            $downloadedCount++
            continue
        }

        $row.Cells["DownloadStatus"].Value = "下载中..."
        $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Orange
        $row.Cells["Progress"].Value = ""
        $form.Refresh()

        $cacheFile = Join-Path $Script:CacheDir $rt.FileName
        $partialFile = "$cacheFile.partial"

        if ((Test-Path $cacheFile) -and (-not (Test-Path $partialFile))) {
            $row.Cells["DownloadStatus"].Value = "已下载"
            $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Green
            $row.Cells["Progress"].Value = "已缓存"
            $downloadedCount++
            Write-Log "已缓存：$rtName" "INFO"
            continue
        }

        if (Test-Path $partialFile) {
            Remove-Item $partialFile -Force
        }

        try {
            Write-Log "开始下载：$rtName - $($rt.DownloadUrl)" "INFO"
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($rt.DownloadUrl, $partialFile)

            if (Test-Path $partialFile) {
                Move-Item $partialFile $cacheFile -Force
            }

            $row.Cells["DownloadStatus"].Value = "已下载"
            $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Green
            $row.Cells["Progress"].Value = "下载完成"
            $downloadedCount++
            Write-Log "下载成功：$rtName -> $cacheFile" "INFO"
        } catch {
            $errorMsg = $_.Exception.Message
            if (Test-Path $partialFile) {
                Remove-Item $partialFile -Force
            }
            $row.Cells["DownloadStatus"].Value = "失败"
            $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Red
            $row.Cells["Progress"].Value = "失败：$errorMsg"
            Write-Log "下载失败：$rtName - $errorMsg" "ERROR"
        }

        $form.Refresh()
    }

    $statusLabel.Text = "下载完成！共 $downloadedCount / $totalItems 项，点击「安装」继续"
    $btnDetect.Enabled = $true
    $btnDownload.Enabled = $true
    $btnInstallOnly.Enabled = $true
    $selectAllBtn.Enabled = $true
    $deselectAllBtn.Enabled = $true
    $btnChangeCacheDir.Enabled = $true
    $btnOpenCacheDir.Enabled = $true
})

$btnInstallOnly.Add_Click({
    $Script:CacheDir = $cacheDirTextBox.Text
    if (-not (Test-Path $Script:CacheDir)) {
        New-Item -ItemType Directory -Path $Script:CacheDir -Force | Out-Null
    }

    $selectedRows = @()
    foreach ($row in $dataGrid.Rows) {
        if ($row.Cells["Check"].Value -eq $true -and $row.Cells["InstallStatus"].Value -ne "已安装") {
            $selectedRows += $row
        }
    }

    if ($selectedRows.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("请先选择需要安装的运行库", "提示", "OK", "Information")
        return
    }

    $btnDetect.Enabled = $false
    $btnDownload.Enabled = $false
    $btnInstallOnly.Enabled = $false
    $selectAllBtn.Enabled = $false
    $deselectAllBtn.Enabled = $false
    $btnChangeCacheDir.Enabled = $false
    $btnOpenCacheDir.Enabled = $false

    $totalItems = $selectedRows.Count
    $installedCount = 0
    $needReboot = $false

    foreach ($row in $selectedRows) {
        $rtName = $row.Cells["Name"].Value
        $rt = $Script:Runtimes | Where-Object { $_.Name -eq $rtName }
        if (-not $rt) { continue }

        $row.Cells["InstallStatus"].Value = "安装中..."
        $row.Cells["InstallStatus"].Style.ForeColor = [System.Drawing.Color]::Orange
        $row.Cells["Progress"].Value = ""
        $form.Refresh()

        $success = $false
        $cacheFile = Join-Path $Script:CacheDir $rt.FileName

        try {
            Write-Log "开始安装：$rtName" "INFO"

            if ($rt.UseWindowsFeature) {
                $result = Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart -ErrorAction Stop
                if ($result.State -eq "Enabled") {
                    $success = $true
                } elseif ($result.RestartNeeded) {
                    $success = $true
                    $needReboot = $true
                } else {
                    throw "启用 Windows 功能失败"
                }
            }
            elseif ($rt.PreExtract) {
                $extractDir = Join-Path $env:TEMP "dx_extract"
                if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
                New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
                $extractProcess = Start-Process -FilePath $cacheFile -ArgumentList "/Q /T:`"$extractDir`"" -Wait -NoNewWindow -PassThru
                if ($extractProcess.ExitCode -ne 0) {
                    throw "DirectX 解压失败，退出码：$($extractProcess.ExitCode)"
                }
                $setupFile = Join-Path $extractDir "DXSETUP.exe"
                if (-not (Test-Path $setupFile)) {
                    throw "未找到 DXSETUP.exe"
                }
                $installProcess = Start-Process -FilePath $setupFile -ArgumentList "/silent" -Wait -NoNewWindow -PassThru
                if ($installProcess.ExitCode -ne 0 -and $installProcess.ExitCode -ne 3010) {
                    throw "DirectX 安装失败，退出码：$($installProcess.ExitCode)"
                }
                $success = $true
                if ($installProcess.ExitCode -eq 3010) { $needReboot = $true }
            }
            elseif ($rt.IsArchive) {
                $extractDir = Join-Path $Script:CacheDir ($rt.FileName -replace '\.(zip|rar|7z)$', '')
                if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
                Expand-Archive -Path $cacheFile -DestinationPath $extractDir -Force
                $setupFile = Get-ChildItem -Path $extractDir -Include "*.exe","*.msi","*.bat" -Recurse | Where-Object { $_.Name -match "setup|install" } | Select-Object -First 1
                if (-not $setupFile) {
                    $setupFile = Get-ChildItem -Path $extractDir -Filter "*.exe" -Recurse | Select-Object -First 1
                }
                if (-not $setupFile) {
                    $setupFile = Get-ChildItem -Path $extractDir -Filter "*.msi" -Recurse | Select-Object -First 1
                }
                if (-not $setupFile) {
                    throw "未找到安装文件（.exe/.msi/.bat）"
                }
                Write-Log "找到安装文件：$($setupFile.Name)" "INFO"
                $installProcess = Start-Process -FilePath $setupFile.FullName -ArgumentList $rt.InstallArgs -Wait -NoNewWindow -PassThru
                if ($installProcess.ExitCode -ne 0 -and $installProcess.ExitCode -ne 1638 -and $installProcess.ExitCode -ne 3010) {
                    throw "安装失败，退出码：$($installProcess.ExitCode)"
                }
                $success = $true
                if ($installProcess.ExitCode -eq 1638) {
                    Write-Log "安装跳过：$rtName - 已安装更新版本" "WARN"
                }
                if ($installProcess.ExitCode -eq 3010) { $needReboot = $true }
            }
            else {
                $installArgs = $rt.InstallArgs
                $installArgs = $ExecutionContext.InvokeCommand.ExpandString($installArgs)
                $process = Start-Process -FilePath $cacheFile -ArgumentList $installArgs -Wait -NoNewWindow -PassThru
                if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 1638 -and $process.ExitCode -ne 3010) {
                    throw "安装程序返回错误码：$($process.ExitCode)"
                }
                $success = $true
                if ($process.ExitCode -eq 1638) {
                    Write-Log "安装跳过：$rtName - 已安装更新版本" "WARN"
                }
                if ($process.ExitCode -eq 3010) { $needReboot = $true }
            }
        } catch {
            $errorMsg = $_.Exception.Message
            $row.Cells["InstallStatus"].Value = "失败"
            $row.Cells["InstallStatus"].Style.ForeColor = [System.Drawing.Color]::Red
            $row.Cells["Progress"].Value = "失败：$errorMsg"
            Write-Log "安装失败：$rtName - $errorMsg" "ERROR"
            continue
        }

        if ($success) {
            $recheck = & $rt.CheckScript
            if ($recheck) {
                $row.Cells["InstallStatus"].Value = "已安装"
                $row.Cells["InstallStatus"].Style.ForeColor = [System.Drawing.Color]::Green
                $row.Cells["Progress"].Value = "完成"
                $row.Cells["Check"].Value = $false
                $row.Cells["Check"].ReadOnly = $true
                $installedCount++
                Write-Log "安装成功：$rtName" "INFO"
            } else {
                $row.Cells["InstallStatus"].Value = "待确认"
                $row.Cells["InstallStatus"].Style.ForeColor = [System.Drawing.Color]::Orange
                $row.Cells["Progress"].Value = "已执行，建议重启后重新检测"
                Write-Log "安装待确认：$rtName - 重新检测未通过" "WARN"
                $installedCount++
            }
        }

        $form.Refresh()
    }

    $rebootMsg = if ($needReboot) { "（部分项目需要重启才能生效）" } else { "" }
    $statusLabel.Text = "安装完成！共 $installedCount / $totalItems 项$rebootMsg"
    if ($needReboot) {
        [System.Windows.Forms.MessageBox]::Show("部分运行库安装后需要重启系统才能生效。`n`n建议现在重启电脑。", "需要重启", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    $btnDetect.Enabled = $true
    $btnDownload.Enabled = $true
    $btnInstallOnly.Enabled = $true
    $selectAllBtn.Enabled = $true
    $deselectAllBtn.Enabled = $true
    $btnChangeCacheDir.Enabled = $true
    $btnOpenCacheDir.Enabled = $true
})

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($form)
