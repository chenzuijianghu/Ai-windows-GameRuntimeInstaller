# 备用启动脚本
# 如果 bat 文件无法运行，可以右键此文件选择"使用 PowerShell 运行"

# 设置执行策略（仅当前会话）
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# 获取脚本所在目录
$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

# 检查主程序是否存在
$mainScript = Join-Path $scriptDir "游戏运行库安装工具.ps1"

if (Test-Path $mainScript) {
    Write-Host "正在启动游戏运行库安装工具..." -ForegroundColor Green
    Write-Host ""
    & $mainScript
} else {
    Write-Host "错误：未找到主程序文件" -ForegroundColor Red
    Write-Host "路径：$mainScript" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "请确保所有文件在同一目录下" -ForegroundColor Yellow
    pause
}
