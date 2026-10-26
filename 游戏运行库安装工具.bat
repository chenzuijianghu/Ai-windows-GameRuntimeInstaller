@echo off
chcp 65001 >nul
set SCRIPT_NAME=游戏运行库安装工具.ps1

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b 0
)

powershell -ExecutionPolicy Bypass -File "%~dp0%SCRIPT_NAME%"
pause
