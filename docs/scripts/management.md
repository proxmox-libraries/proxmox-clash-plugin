---
layout: page
title: 管理脚本
---

# 管理脚本

这个目录包含 Proxmox Clash 插件的管理和维护脚本。

## 📋 脚本概览

### 核心管理脚本
- **[upgrade.sh](upgrade.sh)** - 升级插件到最新版本或指定版本
- **[version_manager.sh](version_manager.sh)** - 版本管理核心脚本
- **[uninstall.sh](uninstall.sh)** - 完全卸载插件
- **[update_subscription.sh](update_subscription.sh)** - 更新 Clash 订阅配置
- **[view_logs.sh](view_logs.sh)** - 查看和管理插件日志

## 🚀 使用方法

### 版本升级
```bash
# 检查可用更新
sudo /opt/proxmox-clash/scripts/management/upgrade.sh -c

# 升级到最新版本
sudo /opt/proxmox-clash/scripts/management/upgrade.sh -l

# 升级到指定版本
sudo /opt/proxmox-clash/scripts/management/upgrade.sh -v v1.1.0

# 创建备份
sudo /opt/proxmox-clash/scripts/management/upgrade.sh -b

# 从备份恢复
sudo /opt/proxmox-clash/scripts/management/upgrade.sh -r backup_20231201_143022
```

### 版本管理
```bash
# 显示最新版本
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -l

# 显示当前版本
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -c

# 列出所有可用版本
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -a

# 显示版本详细信息
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -i v1.1.0

# 检查更新
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -u

# 设置当前版本
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -s v1.1.0

# 清理版本缓存
sudo /opt/proxmox-clash/scripts/management/version_manager.sh --clear-cache

# 强制刷新版本信息
sudo /opt/proxmox-clash/scripts/management/version_manager.sh --refresh
```

### 订阅管理
```bash
# 更新订阅
sudo /opt/proxmox-clash/scripts/management/update_subscription.sh

# 指定订阅 URL 更新
sudo /opt/proxmox-clash/scripts/management/update_subscription.sh "YOUR_SUBSCRIPTION_URL"

# 查看订阅状态
curl http://127.0.0.1:9090/proxies
```

### 日志管理
```bash
# 查看插件日志
sudo /opt/proxmox-clash/scripts/management/view_logs.sh

# 实时跟踪日志
sudo /opt/proxmox-clash/scripts/management/view_logs.sh -f

# 只显示错误日志
sudo /opt/proxmox-clash/scripts/management/view_logs.sh -e

# 显示服务日志
sudo /opt/proxmox-clash/scripts/management/view_logs.sh -s

# 显示所有相关日志
sudo /opt/proxmox-clash/scripts/management/view_logs.sh -a

# 清空日志文件
sudo /opt/proxmox-clash/scripts/management/view_logs.sh -c
```

### 插件卸载
```bash
# 完全卸载插件
sudo /opt/proxmox-clash/scripts/management/uninstall.sh

# 卸载前确认
sudo /opt/proxmox-clash/scripts/management/uninstall.sh --confirm

# 保留配置文件
sudo /opt/proxmox-clash/scripts/management/uninstall.sh --keep-config
```

## 🔧 快捷命令

安装后，以下命令会被创建到 `/usr/local/bin/`：

```bash
# 安装脚本
proxmox-clash-install

# 升级脚本
proxmox-clash-upgrade

# 卸载脚本
proxmox-clash-uninstall

# 版本管理
proxmox-clash-version

# 订阅更新
proxmox-clash-subscription

# 日志查看
proxmox-clash-logs
```

## 📊 脚本特性

### 智能版本管理
- **GitHub 集成** - 直接从 GitHub Releases 获取版本信息
- **智能缓存** - 本地缓存版本信息，减少 API 调用
- **版本比较** - 自动比较版本号，智能提示更新
- **多版本支持** - 支持安装、升级到任意可用版本

### 安全升级
- **自动备份** - 升级前自动创建备份，确保数据安全
- **降级支持** - 支持降级到较低版本（需确认）
- **回滚机制** - 升级失败时自动回滚到上一个版本

### 日志管理
- **多源日志** - 支持插件日志、服务日志、系统日志
- **实时监控** - 支持实时日志跟踪和过滤
- **日志轮转** - 自动日志轮转和清理

## 🔍 故障排除

### 常见问题
```bash
# 升级失败
sudo /opt/proxmox-clash/scripts/management/upgrade.sh --debug

# 版本信息获取失败
sudo /opt/proxmox-clash/scripts/management/version_manager.sh --clear-cache --refresh

# 订阅更新失败
sudo /opt/proxmox-clash/scripts/management/update_subscription.sh --debug

# 日志查看问题
sudo /opt/proxmox-clash/scripts/management/view_logs.sh --help
```

### 调试模式
```bash
# 启用详细日志
sudo /opt/proxmox-clash/scripts/management/upgrade.sh --debug

# 查看脚本帮助
sudo /opt/proxmox-clash/scripts/management/upgrade.sh --help
sudo /opt/proxmox-clash/scripts/management/version_manager.sh --help
```

## 📚 相关文档

- **[使用方法](../usage.md)** - 详细的使用说明和操作指南
- **[快速参考](../quick-reference.md)** - 常用命令和快速操作
- **[故障排除](../troubleshooting/)** - 常见问题和解决方案
- **[版本管理](../installation/version-management.md)** - 版本管理功能详解

---

*最后更新: 2024-12-19*
