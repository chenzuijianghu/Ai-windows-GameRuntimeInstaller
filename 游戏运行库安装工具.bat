@echo off
chcp 65001 >nul
set SCRIPT_NAME=游戏运行库安装工具.ps1
powershell -ExecutionPolicy Bypass -File "%~dp0%SCRIPT_NAME%"
pause
