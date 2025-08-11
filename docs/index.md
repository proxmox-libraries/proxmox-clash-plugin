---
layout: default
title: Proxmox Clash 插件文档
---

# Proxmox Clash 插件文档

欢迎使用 Proxmox Clash 原生插件文档！本插件专为 Proxmox VE 设计，提供安全透明代理和完整的命令行管理功能。

## 📚 文档导航

### 🚀 快速开始
- **[功能特性](features.md)** - 插件的主要功能和技术特性
- **[快速参考](quick-reference.md)** - 常用命令和快速操作指南
- **[安装指南](installation/)** - 详细的安装说明和配置

### 📖 使用指南
- **[使用方法](usage.md)** - 详细的使用说明和操作指南
- **[配置管理](configuration/)** - 配置文件说明和配置指南
- **[安全配置](security.md)** - 安全最佳实践和配置模板

### 🔧 技术文档
- **[脚本工具](scripts/)** - 脚本使用说明和工具文档
- **[开发文档](development/)** - 开发指南和架构说明
- **[故障排除](troubleshooting/)** - 常见问题和解决方案

### 📋 其他文档
- **[发布说明](releases/)** - 版本更新日志和发布说明
- **[迁移指南](migration-guide.md)** - 从单文件脚本迁移到模块化架构
- **[重构总结](refactoring-summary.md)** - 重构完成状态和成果总结

## 🎯 快速导航

### 新用户
1. 查看 [功能特性](features.md) 了解插件能力
2. 阅读 [安装指南](installation/) 进行安装
3. 参考 [快速参考](quick-reference.md) 开始使用

### 现有用户
1. 查看 [使用方法](usage.md) 了解新功能
2. 参考 [安全配置](security.md) 优化安全设置
3. 浏览 [故障排除](troubleshooting/) 解决常见问题

### 开发者
1. 阅读 [开发文档](development/) 了解架构
2. 查看 [脚本工具](scripts/) 了解工具使用
3. 参考 [迁移指南](migration-guide.md) 了解重构内容

## 🔗 重要链接

- **GitHub 仓库**: [proxmox-libraries/proxmox-clash-plugin](https://github.com/proxmox-libraries/proxmox-clash-plugin)
- **最新版本**: [v1.2.0+](https://github.com/proxmox-libraries/proxmox-clash-plugin/releases/tag/v1.2.0)
- **一键安装**: `curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash`

## 📝 文档更新

本文档持续更新中，最新版本请查看 GitHub 仓库。如有问题或建议，欢迎提交 Issue 或 Pull Request。

## 🆕 最新更新

- **模块化重构**: 安装脚本重构为11个模块，提升可维护性
- **新功能**: 支持选择性执行、安装后验证、服务自动验证
- **质量提升**: 代码行数减少72.6%，维护难度显著降低
- **文档完善**: 新增功能特性、使用方法、安全配置等详细文档

---

*最后更新: 2024-12-19*
