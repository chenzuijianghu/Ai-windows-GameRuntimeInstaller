@echo off
title 游戏运行库安装工具
color 0B

echo ============================================
echo   游戏运行库自动检测安装工具
echo ============================================
echo.

:: 检查 PowerShell 是否可用
powershell -Command "Get-Host" >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 未检测到 PowerShell，请确保系统已安装 PowerShell
    pause
    exit /b 1
)

:: 临时设置执行策略（仅当前会话）
echo [1/3] 设置 PowerShell 执行策略...
powershell -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force" >nul 2>&1

:: 检查脚本文件是否存在
echo [2/3] 检查脚本文件...
if not exist "%~dp0游戏运行库安装工具.ps1" (
    echo [错误] 未找到"游戏运行库安装工具.ps1"
    echo 请确保所有文件在同一目录下
    pause
    exit /b 1
)

:: 运行主程序
echo [3/3] 启动安装工具...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0游戏运行库安装工具.ps1"

:: 检查运行结果
if %errorLevel% neq 0 (
    echo.
    echo [错误] 程序运行失败
    echo.
    echo 可能的原因：
    echo 1. PowerShell 执行策略阻止了脚本运行
    echo 2. 文件路径包含特殊字符
    echo 3. 缺少 .NET Framework 4.5 或更高版本
    echo.
    echo 解决方法：
    echo 右键点击"游戏运行库安装工具.ps1"
    echo 选择"使用 PowerShell 运行"
    echo.
)

pause
