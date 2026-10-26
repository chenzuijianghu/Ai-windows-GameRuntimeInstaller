# ============================================
# 游戏运行库自动检测安装工具 v2
# 功能：检测系统缺失的运行库，自动下载并安装
# 支持离线缓存：下载过的安装包会保存到本地，下次直接安装
# 支持自定义缓存目录
# ============================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================
# 日志配置
# ============================================
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

# ============================================
# 缓存目录配置（默认当前目录）
# ============================================
$Script:CacheDir = Join-Path $PSScriptRoot "运行库缓存"
if (-not (Test-Path $Script:CacheDir)) {
    New-Item -ItemType Directory -Path $Script:CacheDir -Force | Out-Null
}
Write-Log "缓存目录：$Script:CacheDir"

$Script:Runtimes = @(
    # ============================================
    # Visual C++ 运行库
    # ============================================
    @{
        Name = "Visual C++ 2005 x86"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A49F249F-0C91-497F-86DF-B2585E8E76B7}" }
        DownloadUrl = "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE"
        FileName = "vcredist_2005_x86.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2005 x64"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{ad8a2fa1-06e7-4b0d-927d-6e54b3d31028}" }
        DownloadUrl = "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE"
        FileName = "vcredist_2005_x64.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2008 x86"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}" }
        DownloadUrl = "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe"
        FileName = "vcredist_2008_x86.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2008 x64"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4}" }
        DownloadUrl = "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe"
        FileName = "vcredist_2008_x64.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2010 x86"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1F4F1D2A-D9DA-32CF-9909-48485DA06DD5}" }
        DownloadUrl = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe"
        FileName = "vcredist_2010_x86.exe"
        InstallArgs = "/q /norestart"
    },
    @{
        Name = "Visual C++ 2010 x64"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{932CC528-46B4-3553-8D01-B657B5404E2A}" }
        DownloadUrl = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe"
        FileName = "vcredist_2010_x64.exe"
        InstallArgs = "/q /norestart"
    },
    @{
        Name = "Visual C++ 2012 x86"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{BD95A8CD-1D9F-35AD-981A-3E7925026EBB}" }
        DownloadUrl = "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe"
        FileName = "vcredist_2012_x86.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "Visual C++ 2012 x64"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CF2BEA3C-26EA-32F8-AA9B-331F7E34BA97}" }
        DownloadUrl = "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"
        FileName = "vcredist_2012_x64.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "Visual C++ 2013 x86"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F65DB027-FBEF-3678-915C-18EC053634AF}" }
        DownloadUrl = "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe"
        FileName = "vcredist_2013_x86.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "Visual C++ 2013 x64"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{DE2C306F-A067-38EF-B86C-03DE4B0312F9}" }
        DownloadUrl = "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe"
        FileName = "vcredist_2013_x64.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "Visual C++ 2015-2022 x86"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" }
        DownloadUrl = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
        FileName = "vc_redist_2015-2022_x86.exe"
        InstallArgs = "/install /quiet /norestart"
    },
    @{
        Name = "Visual C++ 2015-2022 x64"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" }
        DownloadUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
        FileName = "vc_redist_2015-2022_x64.exe"
        InstallArgs = "/install /quiet /norestart"
    },

    # ============================================
    # DirectX
    # ============================================
    @{
        Name = "DirectX 最终用户运行库"
        Category = "common"
        CheckScript = { (Test-Path "C:\Windows\System32\d3dx9_43.dll") -or (Test-Path "C:\Windows\SysWOW64\d3dx9_43.dll") }
        DownloadUrl = "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe"
        FileName = "directx_Jun2010_redist.exe"
        InstallArgs = "/Q /T:$env:TEMP\dx_extract"
        PreExtract = $true
    },

    # ============================================
    # .NET Framework
    # ============================================
    @{
        Name = ".NET Framework 3.5"
        Category = "common"
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
        CheckScript = {
            $reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue
            $reg -and $reg.Release -ge 528040
        }
        DownloadUrl = "https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/c19041bd630e401c917024490384d2f2/ndp48-x86-x64-allos-enu.exe"
        FileName = "ndp48-x86-x64-allos-enu.exe"
        InstallArgs = "/q /norestart"
    },

    # ============================================
    # Java
    # ============================================
    @{
        Name = "Java Runtime (JRE) 8"
        Category = "optional"
        CheckScript = { (Test-Path "HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment\1.8") -or (Test-Path "C:\Program Files\Java\jre1.8*") -or (Test-Path "C:\Program Files (x86)\Java\jre1.8*") }
        DownloadUrl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=247931_89d678f2be164786b292527658ca1605"
        FileName = "jre-8-windows-x64.exe"
        InstallArgs = "/s"
    },

    # ============================================
    # 音频/物理/图形
    # ============================================
    @{
        Name = "OpenAL 音频库"
        Category = "optional"
        CheckScript = { (Test-Path "HKLM:\SOFTWARE\OpenAL") -or (Test-Path "C:\Windows\System32\OpenAL32.dll") }
        DownloadUrl = "https://www.openal.org/downloads/oalinst.zip"
        FileName = "oalinst.zip"
        InstallArgs = "/S"
    },
    @{
        Name = "PhysX 物理引擎"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\NVIDIA Corporation\PhysX" }
        DownloadUrl = "https://us.download.nvidia.com/GFE/PACKAGES/PhysX/9.21.0713/PhysX_9.21.0713_SystemSoftware.exe"
        FileName = "PhysX_SystemSoftware.exe"
        InstallArgs = "/s"
    },
    @{
        Name = "XNA Framework 3.1"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\XNA\Framework\v3.1" }
        DownloadUrl = "https://download.microsoft.com/download/A/C/2/AC2C900B-D931-47E0-BB5F-3A0B200BACD0/xnafx31_redist.msi"
        FileName = "xnafx31_redist.msi"
        InstallArgs = "/q /norestart"
    },
    @{
        Name = "XNA Framework 4.0"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\XNA\Framework\v4.0" }
        DownloadUrl = "https://download.microsoft.com/download/E/4/1/E4173890-A24A-4936-9FC9-AF930FE3FA40/xnafx40_redist.msi"
        FileName = "xnafx40_redist.msi"
        InstallArgs = "/q /norestart"
    },

    # ============================================
    # 其他游戏相关
    # ============================================
    @{
        Name = "Games for Windows LIVE"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Games for Windows - LIVE" }
        DownloadUrl = "https://download.microsoft.com/download/C/4/9/C4921094-9125-4DBE-A55B-1C53D7F5333E/gfwlivesetup.exe"
        FileName = "gfwlivesetup.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Microsoft Games for Windows Marketplace"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Games for Windows - LIVE\Client" }
        DownloadUrl = "https://download.microsoft.com/download/4/1/7/4179E479-C595-4732-8092-687312D0D29E/gfwmsetup.exe"
        FileName = "gfwmsetup.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2008 SP1 ATL 安全更新"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1F1C2DFC-2D24-3E06-BCB8-725134ADF989}" }
        DownloadUrl = "https://download.microsoft.com/download/3/2/2/3224B87F-CFA0-4E70-BDA3-3DE650EFEBA5/vcredist_x86.exe"
        FileName = "vcredist_2008_sp1_x86.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual C++ 2008 SP1 ATL 安全更新 x64"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{30300800-95FE-3846-A80A-EB4B0C4F0FBE}" }
        DownloadUrl = "https://download.microsoft.com/download/3/2/2/3224B87F-CFA0-4E70-BDA3-3DE650EFEBA5/vcredist_x64.exe"
        FileName = "vcredist_2008_sp1_x64.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Runtimes (All-in-One) 2024"
        Category = "common"
        CheckScript = { $false }
        DownloadUrl = "https://github.com/abbodi1406/vcredist/releases/download/v0.74.0/VisualCppRedist_AIO_x86_x64_74.zip"
        FileName = "VisualCppRedist_AIO_x86_x64_74.zip"
        InstallArgs = ""
        IsArchive = $true
    },

    # ============================================
    # .NET 运行时
    # ============================================
    @{
        Name = ".NET Desktop Runtime 6.0"
        Category = "common"
        CheckScript = {
            $reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v6.0" -ErrorAction SilentlyContinue
            $reg -or (Test-Path "HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.NETCore.App\6.0*")
        }
        DownloadUrl = "https://download.visualstudio.microsoft.com/download/pr/3330b6ce-1712-4014-b4f0-000000000000/windowsdesktop-runtime-6.0.36-win-x64.exe"
        FileName = "windowsdesktop-runtime-6.0.36-win-x64.exe"
        InstallArgs = "/install /quiet /norestart"
    },

    # ============================================
    # WebView2
    # ============================================
    @{
        Name = "Microsoft Edge WebView2"
        Category = "common"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" }
        DownloadUrl = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
        FileName = "MicrosoftEdgeWebview2Setup.exe"
        InstallArgs = "/silent /install"
    },

    # ============================================
    # GameInput
    # ============================================
    @{
        Name = "Microsoft GameInput"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\GameInput" }
        DownloadUrl = "https://download.microsoft.com/download/4/0/4/40413c7e-9c6e-4b6e-8b6e-4b6e8b6e4b6e/GameInputRedist.msi"
        FileName = "GameInputRedist.msi"
        InstallArgs = "/q /norestart"
    },

    # ============================================
    # XNA Framework 2.0
    # ============================================
    @{
        Name = "XNA Framework 2.0"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\XNA\Framework\v2.0" }
        DownloadUrl = "https://download.microsoft.com/download/7/4/5/7457D0B4-4E4B-4B4E-8B4E-4B4E8B4E4B4E/xnafx20_redist.msi"
        FileName = "xnafx20_redist.msi"
        InstallArgs = "/q /norestart"
    },

    # ============================================
    # Java / OpenJDK
    # ============================================
    @{
        Name = "Microsoft Build of OpenJDK 17"
        Category = "optional"
        CheckScript = { (Test-Path "HKLM:\SOFTWARE\Microsoft\JDK\17*") -or (Test-Path "C:\Program Files\Microsoft\jdk-*") }
        DownloadUrl = "https://aka.ms/download-jdk/microsoft-jdk-17-windows-x64.msi"
        FileName = "microsoft-jdk-17-windows-x64.msi"
        InstallArgs = "/q /norestart"
    },

    # ============================================
    # Visual J# (老游戏兼容)
    # ============================================
    @{
        Name = "Visual J# 2.0 x86"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Visual J#" }
        DownloadUrl = "https://download.microsoft.com/download/4/0/4/40413c7e-9c6e-4b6e-8b6e-4b6e8b6e4b6e/vjredist.exe"
        FileName = "vjredist_x86.exe"
        InstallArgs = "/q"
    },
    @{
        Name = "Visual J# 2.0 x64"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Visual J#\64" }
        DownloadUrl = "https://download.microsoft.com/download/4/0/4/40413c7e-9c6e-4b6e-8b6e-4b6e8b6e4b6e/vjredist_x64.exe"
        FileName = "vjredist_x64.exe"
        InstallArgs = "/q"
    },

    # ============================================
    # Visual F#
    # ============================================
    @{
        Name = "Visual F# 2.0 Runtime"
        Category = "optional"
        CheckScript = { Test-Path "HKLM:\SOFTWARE\Microsoft\Visual F#" }
        DownloadUrl = "https://download.microsoft.com/download/4/0/4/40413c7e-9c6e-4b6e-8b6e-4b6e8b6e4b6e/vfsharp.exe"
        FileName = "vfsharp_runtime.exe"
        InstallArgs = "/q"
    }
)

# ============================================
# GUI 构建
# ============================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "游戏运行库自动检测安装工具 v2"
$form.Size = New-Object System.Drawing.Size(780, 650)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# 标题标签
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "游戏运行库检测与安装"
$titleLabel.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(20, 15)
$titleLabel.AutoSize = $true
$form.Controls.Add($titleLabel)

# 缓存目录行
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

# 全选/取消全选
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

# 状态标签
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "点击「检测」开始扫描，然后「下载」→「安装」"
$statusLabel.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$statusLabel.Location = New-Object System.Drawing.Point(250, 86)
$statusLabel.AutoSize = $true
$form.Controls.Add($statusLabel)

# DataGridView 显示运行库列表
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

# 列定义
$colCheck = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn
$colCheck.HeaderText = "选择"
$colCheck.Width = 50
$colCheck.Name = "Check"

$colName = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colName.HeaderText = "运行库名称"
$colName.Width = 250
$colName.Name = "Name"
$colName.ReadOnly = $true

$colCategory = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colCategory.HeaderText = "类型"
$colCategory.Width = 60
$colCategory.Name = "Category"
$colCategory.ReadOnly = $true

$colDownloadStatus = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colDownloadStatus.HeaderText = "下载状态"
$colDownloadStatus.Width = 90
$colDownloadStatus.Name = "DownloadStatus"
$colDownloadStatus.ReadOnly = $true

$colInstallStatus = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colInstallStatus.HeaderText = "安装状态"
$colInstallStatus.Width = 90
$colInstallStatus.Name = "InstallStatus"
$colInstallStatus.ReadOnly = $true

$colProgress = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colProgress.HeaderText = "进度/原因"
$colProgress.Width = 200
$colProgress.Name = "Progress"
$colProgress.ReadOnly = $true

$dataGrid.Columns.Add($colCheck)
$dataGrid.Columns.Add($colName)
$dataGrid.Columns.Add($colCategory)
$dataGrid.Columns.Add($colDownloadStatus)
$dataGrid.Columns.Add($colInstallStatus)
$dataGrid.Columns.Add($colProgress)

$form.Controls.Add($dataGrid)

# 底部按钮
$btnDetect = New-Object System.Windows.Forms.Button
$btnDetect.Text = "检  测"
$btnDetect.Size = New-Object System.Drawing.Size(120, 40)
$btnDetect.Location = New-Object System.Drawing.Point(200, 550)
$btnDetect.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$btnDetect.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnDetect.ForeColor = [System.Drawing.Color]::White
$btnDetect.FlatStyle = "Flat"
$form.Controls.Add($btnDetect)

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "下  载"
$btnInstall.Size = New-Object System.Drawing.Size(100, 40)
$btnInstall.Location = New-Object System.Drawing.Point(340, 550)
$btnInstall.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$btnInstall.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnInstall.ForeColor = [System.Drawing.Color]::White
$btnInstall.FlatStyle = "Flat"
$btnInstall.Enabled = $false
$form.Controls.Add($btnInstall)

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

# ============================================
# 浏览缓存目录
# ============================================
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

# ============================================
# 打开缓存目录
# ============================================
$btnOpenCacheDir.Add_Click({
    $dir = $cacheDirTextBox.Text
    if (Test-Path $dir) {
        Start-Process explorer.exe -ArgumentList $dir
    } else {
        [System.Windows.Forms.MessageBox]::Show("目录不存在: $dir", "提示", "OK", "Warning")
    }
})

# ============================================
# 检测逻辑
# ============================================
$btnDetect.Add_Click({
    # 更新缓存目录
    $Script:CacheDir = $cacheDirTextBox.Text
    if (-not (Test-Path $Script:CacheDir)) {
        New-Item -ItemType Directory -Path $Script:CacheDir -Force | Out-Null
    }

    $statusLabel.Text = "正在检测..."
    $btnDetect.Enabled = $false
    $btnInstall.Enabled = $false
    $btnInstallOnly.Enabled = $false
    $dataGrid.Rows.Clear()
    $form.Refresh()

    foreach ($rt in $Script:Runtimes) {
        $installed = & $rt.CheckScript
        $categoryText = if ($rt.Category -eq "common") { "通用" } else { "可选" }

        # 检查是否已下载
        $cacheFile = Join-Path $Script:CacheDir $rt.FileName
        $downloaded = Test-Path $cacheFile

        $rowIndex = $dataGrid.Rows.Add()
        $row = $dataGrid.Rows[$rowIndex]
        # 只有「通用」类型且未安装的才默认选中，「可选」类型不自动选中
        $row.Cells["Check"].Value = (-not $installed -and $rt.Category -eq "common")
        $row.Cells["Name"].Value = $rt.Name
        $row.Cells["Category"].Value = $categoryText
        $row.Cells["DownloadStatus"].Value = if ($downloaded) { "已下载" } else { "未下载" }
        $row.Cells["InstallStatus"].Value = if ($installed) { "已安装" } else { "未安装" }
        $row.Cells["Progress"].Value = ""

        # 设置颜色
        if ($downloaded) {
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

    $missingCount = ($Script:Runtimes | Where-Object { -not (& $_.CheckScript) }).Count
    $totalCount = $Script:Runtimes.Count
    $statusLabel.Text = "检测完成：$missingCount / $totalCount 项需要安装"
    $btnDetect.Enabled = $true
    $btnInstall.Enabled = ($missingCount -gt 0)
    $btnInstallOnly.Enabled = ($missingCount -gt 0)
})

# ============================================
# 全选/取消全选
# ============================================
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

# ============================================
# 下载逻辑（只下载不安装）
# ============================================
$btnInstall.Add_Click({
    # 更新缓存目录
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
    $btnInstall.Enabled = $false
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

        $row.Cells["DownloadStatus"].Value = "下载中..."
        $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Orange
        $row.Cells["Progress"].Value = ""
        $form.Refresh()

        # 检查是否已缓存
        $cacheFile = Join-Path $Script:CacheDir $rt.FileName
        if (Test-Path $cacheFile) {
            $row.Cells["DownloadStatus"].Value = "已下载"
            $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Green
            $row.Cells["Progress"].Value = "已缓存"
            $downloadedCount++
            Write-Log "已缓存：$rtName" "INFO"
            continue
        }

        # 下载
        try {
            Write-Log "开始下载：$rtName - $($rt.DownloadUrl)" "INFO"
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($rt.DownloadUrl, $cacheFile)
            $row.Cells["DownloadStatus"].Value = "已下载"
            $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Green
            $row.Cells["Progress"].Value = "下载完成"
            $downloadedCount++
            Write-Log "下载成功：$rtName -> $cacheFile" "INFO"
        } catch {
            $errorMsg = $_.Exception.Message
            $row.Cells["DownloadStatus"].Value = "失败"
            $row.Cells["DownloadStatus"].Style.ForeColor = [System.Drawing.Color]::Red
            $row.Cells["Progress"].Value = "失败：$errorMsg"
            Write-Log "下载失败：$rtName - $errorMsg" "ERROR"
        }

        $form.Refresh()
    }

    $statusLabel.Text = "下载完成！共 $downloadedCount / $totalItems 项，点击「安装」继续"
    $btnDetect.Enabled = $true
    $btnInstall.Enabled = $true
    $btnInstallOnly.Enabled = $true
    $selectAllBtn.Enabled = $true
    $deselectAllBtn.Enabled = $true
    $btnChangeCacheDir.Enabled = $true
    $btnOpenCacheDir.Enabled = $true
})

# ============================================
# 安装逻辑（只安装不下载）
# ============================================
$btnInstallOnly.Add_Click({
    # 更新缓存目录
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
    $btnInstall.Enabled = $false
    $btnInstallOnly.Enabled = $false
    $selectAllBtn.Enabled = $false
    $deselectAllBtn.Enabled = $false
    $btnChangeCacheDir.Enabled = $false
    $btnOpenCacheDir.Enabled = $false

    $totalItems = $selectedRows.Count
    $installedCount = 0

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

        # 检查安装包是否存在
        if (-not (Test-Path $cacheFile)) {
            $row.Cells["InstallStatus"].Value = "失败"
            $row.Cells["InstallStatus"].Style.ForeColor = [System.Drawing.Color]::Red
            $row.Cells["Progress"].Value = "未找到安装包，请先下载"
            Write-Log "安装失败：$rtName - 未找到安装包 $cacheFile" "ERROR"
            continue
        }

        # 安装
        $row.Cells["Progress"].Value = "安装中..."
        $form.Refresh()
        try {
            Write-Log "开始安装：$rtName - $cacheFile" "INFO"
            if ($rt.UseWindowsFeature) {
                # .NET 3.5 特殊处理
                $result = Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart -ErrorAction Stop
                if ($result.RestartNeeded -or $result.State -eq "Enabled") {
                    $success = $true
                } else {
                    throw "启用失败"
                }
            }
            elseif ($rt.PreExtract) {
                # DirectX 特殊处理
                $extractDir = Join-Path $env:TEMP "dx_extract"
                if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
                New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
                Start-Process -FilePath $cacheFile -ArgumentList "/Q /T:$extractDir" -Wait -NoNewWindow
                $setupFile = Join-Path $extractDir "DXSETUP.exe"
                if (Test-Path $setupFile) {
                    Start-Process -FilePath $setupFile -ArgumentList "/silent" -Wait -NoNewWindow
                    $success = $true
                } else {
                    throw "未找到 DXSETUP.exe"
                }
            }
            elseif ($rt.IsArchive) {
                # 压缩包类型
                $extractDir = Join-Path $Script:CacheDir ($rt.FileName -replace '\.zip$', '')
                if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
                Expand-Archive -Path $cacheFile -DestinationPath $extractDir -Force
                $setupFile = Get-ChildItem -Path $extractDir -Filter "*.bat" -Recurse | Select-Object -First 1
                if ($setupFile) {
                    Start-Process -FilePath $setupFile.FullName -Wait -NoNewWindow
                    $success = $true
                } else {
                    throw "未找到安装脚本"
                }
            }
            else {
                # 普通安装
                $installArgs = $rt.InstallArgs
                $installArgs = $ExecutionContext.InvokeCommand.ExpandString($installArgs)
                $process = Start-Process -FilePath $cacheFile -ArgumentList $installArgs -Wait -NoNewWindow -PassThru
                if ($process.ExitCode -ne 0) {
                    throw "安装程序返回错误码：$($process.ExitCode)"
                }
                $success = $true
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
            $row.Cells["InstallStatus"].Value = "已安装"
            $row.Cells["InstallStatus"].Style.ForeColor = [System.Drawing.Color]::Green
            $row.Cells["Progress"].Value = "完成"
            $row.Cells["Check"].Value = $false
            $row.Cells["Check"].ReadOnly = $true
            $installedCount++
            Write-Log "安装成功：$rtName" "INFO"
        }

        $form.Refresh()
    }

    $statusLabel.Text = "安装完成！共 $installedCount / $totalItems 项"
    $btnDetect.Enabled = $true
    $btnInstall.Enabled = $true
    $btnInstallOnly.Enabled = $true
    $selectAllBtn.Enabled = $true
    $deselectAllBtn.Enabled = $true
    $btnChangeCacheDir.Enabled = $true
    $btnOpenCacheDir.Enabled = $true
})

# ============================================
# 启动
# ============================================
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($form)
