#  游戏运行库自动检测安装工具

> **AI Generated** - 本项目由 AI 辅助开发-纯度很高

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://docs.microsoft.com/powershell)
[![Windows](https://img.shields.io/badge/Windows-7/8/10/11-lightgrey.svg)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

一款专为 Windows 游戏玩家设计的运行库管理工具，可自动检测系统缺失的游戏运行库，并支持一键下载和安装。

## ✨ 特性

- 🔍 **自动检测** - 扫描 30+ 种游戏运行库的安装状态
-  **智能选择** - 通用运行库自动选中，可选运行库手动勾选
- ⚡ **一键安装** - 自动下载并静默安装，无需用户干预
-  **离线缓存** - 安装包本地缓存，支持离线使用
-  **自定义目录** - 可自由指定缓存目录位置

## 📋 支持的运行库

### 通用（14 项）
- Visual C++ 2005/2008/2010/2012/2013/2015-2022 (x86 + x64)
- DirectX 最终用户运行库
- .NET Framework 3.5 / 4.8
- .NET Desktop Runtime 6.0
- Microsoft Edge WebView2
- Visual C++ All-in-One 2024

### 可选（16 项）
- Java Runtime 8 / OpenJDK 17
- OpenAL / PhysX
- XNA Framework 2.0 / 3.1 / 4.0
- Games for Windows LIVE / Marketplace
- Visual C++ 2008 SP1 安全更新
- Microsoft GameInput
- Visual J# 2.0 / Visual F# 2.0

## 🚀 快速开始

### 方法一：直接运行（推荐）
1. 下载 [`GameRuntimeInstaller.bat`](GameRuntimeInstaller.bat) 和 [`GameRuntimeInstaller.ps1`](GameRuntimeInstaller.ps1)
2. 双击 `GameRuntimeInstaller.bat` 即可运行

### 方法二：从源码运行
```powershell
# 以管理员身份打开 PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\GameRuntimeInstaller.ps1
```

## 📖 使用说明

1. **检测** - 点击「检测」按钮扫描系统运行库
2. **选择** - 通用运行库自动选中，可选的按需勾选
3. **安装** - 点击「安装」开始下载和安装
4. **缓存** - 所有安装包保存到 `D:\游戏运行库\`（可自定义）

## ️ 项目结构

```
GameRuntimeInstaller/
├── GameRuntimeInstaller.bat      # 启动器（双击运行）
├── GameRuntimeInstaller.ps1      # PowerShell 脚本本体
└── README.md                     # 本文档
```

## 💡 使用场景

### 新电脑/重装系统后
一次性装齐所有运行库，避免玩游戏时反复弹窗提示缺少 DLL。

### 离线环境使用
在有网的电脑上运行一次，将缓存目录复制到 U 盘，带到没网的电脑上直接使用。

### 排查游戏报错
游戏启动时提示缺少某个 DLL，用这个工具快速补装对应运行库。

## ⚙️ 技术细节

- **语言**: PowerShell 5.1+
- **界面**: Windows Forms
- **编码**: UTF-8 with BOM
- **依赖**: 无（Windows 自带）

## 📝 更新日志

### v4.0.0 (2026-10-26)
- ✨ 新增 8 种运行库（.NET 6、WebView2、GameInput、XNA 2.0、OpenJDK 17、Visual J#、Visual F#）
- ✨ 「可选」类型运行库默认不选中
- ✨ 缓存目录默认改为 D 盘
- ✨ 支持自定义缓存目录

### v3.0.0
- ✨ 新增 .NET 4.8、Java 8、Games for Windows LIVE 等
- 🎨 界面优化，窗口更大

### v2.0.0
- ✨ 支持自定义缓存目录
- ✨ 新增 DirectX、.NET 3.5 等特殊处理逻辑

### v1.0.0
- 🎉 初始版本发布


## 📄 许可证

本项目采用 [MIT License](LICENSE) 开源协议。

## 🏷️ 标签

`#AI-Generated` `#Windows` `#Gaming` `#Runtime` `#PowerShell` `#Utility`

---

<p align="center">Made with ❤️ by AI</p>
