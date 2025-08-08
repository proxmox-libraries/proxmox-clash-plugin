---
layout: default
title: Proxmox Clash 插件文档
---

# Proxmox Clash 插件文档

欢迎使用 Proxmox Clash 插件文档！这是一个深度集成到 Proxmox VE Web UI 的 Clash.Meta (mihomo) 原生插件。

## 📚 文档目录

### 🚀 快速开始
- [安装指南]({{ site.baseurl }}/installation/) - 详细的安装步骤和配置
- [快速配置]({{ site.baseurl }}/configuration/quick-start.md) - 快速上手指南
- [透明代理配置]({{ site.baseurl }}/configuration/transparent-proxy.md) - 安全透明代理配置
- [GitHub 镜像配置]({{ site.baseurl }}/installation/github-mirror.md) - 解决下载慢的问题

### 📖 用户指南
- [版本管理]({{ site.baseurl }}/installation/version-management.md) - 版本管理功能详解
- [升级指南]({{ site.baseurl }}/installation/upgrade.md) - 插件升级方法
- [服务管理]({{ site.baseurl }}/installation/service.md) - systemd 服务配置

### 🔧 开发文档
- [开发指南]({{ site.baseurl }}/development/) - 开发环境搭建和贡献指南
- [API 文档]({{ site.baseurl }}/development/api.md) - API 接口说明
- [UI 开发]({{ site.baseurl }}/development/ui.md) - 前端界面开发
- [架构设计]({{ site.baseurl }}/development/architecture.md) - 系统架构说明

### 🛠️ 运维文档
- [故障排除]({{ site.baseurl }}/troubleshooting/) - 常见问题和解决方案
- [脚本工具]({{ site.baseurl }}/scripts/) - 脚本使用和管理
  - [安装脚本]({{ site.baseurl }}/scripts/install.md) - 安装脚本说明
  - [管理脚本]({{ site.baseurl }}/scripts/management.md) - 管理脚本说明
  - [工具脚本]({{ site.baseurl }}/scripts/utils.md) - 工具脚本说明

## 📋 脚本工具

项目提供了完整的脚本工具集，按功能分类组织：

### 📁 脚本目录结构
```
scripts/
├── install/           # 安装相关脚本
│   └── install_direct.sh
├── management/        # 管理和维护脚本
│   ├── upgrade.sh
│   ├── version_manager.sh
│   ├── uninstall.sh
│   ├── update_subscription.sh
│   └── view_logs.sh
└── utils/            # 工具脚本
    ├── setup_github_mirror.sh
    └── setup_transparent_proxy.sh
```

### 🚀 快速安装
```bash
# 一键安装（推荐）
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash

# 直接脚本安装
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install_direct.sh | sudo bash
```

### 🔗 快捷命令
安装后，以下命令会被创建到 `/usr/local/bin/`：
- `proxmox-clash-install` - 安装脚本
- `proxmox-clash-upgrade` - 升级脚本
- `proxmox-clash-uninstall` - 卸载脚本

## 🎯 快速导航

### 新用户
1. [安装指南]({{ site.baseurl }}/installation/) - 开始安装
2. [快速配置]({{ site.baseurl }}/configuration/quick-start.md) - 基础配置
3. [透明代理配置]({{ site.baseurl }}/configuration/transparent-proxy.md) - 安全透明代理设置
4. [版本管理]({{ site.baseurl }}/installation/version-management.md) - 版本管理

### 管理员
1. [故障排除]({{ site.baseurl }}/troubleshooting/) - 问题解决
2. [开发指南]({{ site.baseurl }}/development/) - 开发环境

### 开发者
1. [开发指南]({{ site.baseurl }}/development/) - 开发环境

## 📈 最新版本

- 查看最新发布: [releases/]({{ site.baseurl }}/releases/)
- 最新版本说明: [releases/release-v1.2.0.md]({{ site.baseurl }}/releases/release-v1.2.0.md)

## 🔗 相关链接

- [GitHub 仓库](https://github.com/proxmox-libraries/proxmox-clash-plugin)
- [问题反馈](https://github.com/proxmox-libraries/proxmox-clash-plugin/issues)
- [功能请求](https://github.com/proxmox-libraries/proxmox-clash-plugin/issues/new)
- [贡献指南]({{ site.baseurl }}/development/#贡献指南)

## 📝 文档更新

本文档会随着项目更新而持续维护。如果您发现文档有误或需要补充，欢迎提交 Issue 或 Pull Request。

---

**注意**: 本文档适用于 Proxmox Clash 插件 v1.0.0 及以上版本。
