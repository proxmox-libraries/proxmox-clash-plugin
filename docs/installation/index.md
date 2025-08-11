---
layout: page-with-sidebar
title: 安装指南
---

# 安装指南

欢迎使用 Proxmox Clash 插件安装指南！本指南将帮助您完成插件的安装和基础配置。

## 📚 安装文档

### 🚀 快速开始
- **[基础安装](service.md)** - 基本的安装步骤和服务配置
- **[GitHub 镜像配置](github-mirror.md)** - 解决下载慢的问题

### 🔧 高级功能
- **[版本管理](version-management.md)** - 版本管理功能详解
- **[升级指南](upgrade.md)** - 插件升级方法

## 🚀 快速安装

### 一键安装（推荐）

最简单的安装方式，自动下载并安装最新版本：

```bash
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash
```

### 模块化安装

支持选择性执行和版本选择的模块化安装方式：

```bash
# 安装最新版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash

# 安装指定版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- v1.1.0

# 跳过特定步骤（如依赖检查）
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- --skip dependencies,download

# 启用安装后验证
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- --verify
```

## 🌐 GitHub 访问优化

如果遇到 GitHub 下载慢的问题，可以先配置镜像源：

```bash
# 检查网络连接
bash scripts/utils/setup_github_mirror.sh -c

# 设置 ghproxy 镜像（推荐）
bash scripts/utils/setup_github_mirror.sh -m ghproxy

# 或设置其他镜像源
bash scripts/utils/setup_github_mirror.sh -m fastgit
bash scripts/utils/setup_github_mirror.sh -m cnpmjs
```

## 📋 安装后配置

安装完成后，请参考以下文档进行配置：

- **[使用方法](../usage.md)** - 详细的使用说明和操作指南
- **[安全配置](../security.md)** - 安全最佳实践和配置模板
- **[快速参考](../quick-reference.md)** - 常用命令和快速操作

## 🔧 安装验证

安装完成后，可以使用以下命令验证安装：

```bash
# 检查服务状态
sudo systemctl status clash-meta

# 检查端口监听
sudo netstat -tlnp | grep -E ':(7890|9090)'

# 检查 API 插件
ls -la /usr/share/perl5/PVE/API2/Clash.pm

# 检查前端插件
ls -la /usr/share/pve-manager/ext6/pve-panel-clash.js
```

## 🚨 常见问题

### 安装失败

如果安装过程中遇到问题：

1. 检查网络连接
2. 确保有足够的磁盘空间
3. 检查用户权限
4. 查看安装日志

### 服务无法启动

```bash
# 检查服务状态
sudo systemctl status clash-meta

# 查看日志
sudo journalctl -u clash-meta -f

# 检查配置文件语法
sudo /opt/proxmox-clash/clash-meta -t -c /opt/proxmox-clash/config/config.yaml
```

## 📞 获取帮助

如果在安装过程中遇到问题，请：

1. 查看 [故障排除](../troubleshooting/) 文档
2. 提交 GitHub Issue
3. 查看安装日志获取详细错误信息

---

*最后更新: 2024-12-19*
