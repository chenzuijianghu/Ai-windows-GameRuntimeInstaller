@echo off
chcp 65001 >nul
title Game Runtime Installer
color 0B

echo ============================================
echo   Game Runtime Installer
echo ============================================
echo.

:: Check PowerShell
powershell -Command "Get-Host" >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] PowerShell not found
    pause
    exit /b 1
)

:: Set execution policy
echo [1/3] Setting PowerShell execution policy...
powershell -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force" >nul 2>&1

:: Check script file
echo [2/3] Checking script file...
if not exist "%~dp0游戏运行库安装工具.ps1" (
    echo [ERROR] Script file not found
    pause
    exit /b 1
)

:: Run main program
echo [3/3] Starting installer...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0游戏运行库安装工具.ps1"

:: Check result
if %errorLevel% neq 0 (
    echo.
    echo [ERROR] Program failed
    echo.
    echo Please try:
    echo Right-click "游戏运行库安装工具.ps1"
    echo Select "Run with PowerShell"
    echo.
)

pause
