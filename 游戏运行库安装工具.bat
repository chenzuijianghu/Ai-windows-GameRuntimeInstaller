@echo off
chcp 65001 >nul
title 游戏运行库安装工具
powershell -ExecutionPolicy Bypass -File "%~dp0游戏运行库安装工具.ps1"
pause
