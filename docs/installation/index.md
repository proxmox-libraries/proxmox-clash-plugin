---
layout: page-with-sidebar
title: 安装指南
---

# 安装指南

本指南将帮助您在 Proxmox VE 上安装和配置 Clash 插件。

## 🆕 v1.2.7 重大改进

**最新版本 v1.2.7 带来了安装脚本的重大改进！**

- 🚀 **自动 HTML 模板修改** - 无需手动修改配置文件
- 📋 **内置安装验证系统** - 确保安装完整性
- 🛡️ **UI 文件权限优化** - 自动设置正确的权限
- 🔄 **完整卸载清理** - 支持安全回滚和恢复

### 快速开始（推荐）
```bash
# 一键安装并验证
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash -s -- -l --verify
```

### 了解更多
- [📖 安装改进详情](installation-improvements.md) - 完整的改进说明
- [⚡ 快速参考指南](quick-reference.md) - 常用命令速查
- [🔍 故障排除指南](../troubleshooting/) - 问题解决方案

---

## 📋 系统要求

### 硬件要求
- **CPU**: 支持 x86_64 架构
- **内存**: 最少 512MB RAM
- **存储**: 最少 100MB 可用空间

### 软件要求
- **Proxmox VE**: 7.0 或更高版本
- **操作系统**: Debian 11+ 或 Ubuntu 20.04+
- **依赖工具**: curl, wget, jq, tar

## 📁 目录结构

### clash-meta 目录
- 存放 mihomo 可执行文件
- 存放相关的内核文件
- 安装脚本会自动下载并放置 mihomo 内核到此目录

### service 目录
- 包含 systemd 服务配置文件
- `clash-meta.service` - Clash.Meta systemd 服务文件

## 🚀 安装方法

### 方法一：一键安装（推荐）

```bash
# 一键安装最新版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash

# 安装并自动验证（v1.2.7 新功能）
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash -s -- -l --verify
```

### 方法二：直接脚本安装

```bash
# 安装最新版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install_direct.sh | sudo bash

# 安装指定版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install_direct.sh | sudo bash -s -- v1.1.0

# 安装并验证（v1.2.7 新功能）
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install_direct.sh | sudo bash -s -- --verify
```

## ⚙️ 安装后配置

### 1. 检查安装状态

```bash
# 检查服务状态
sudo systemctl status clash-meta

# 检查端口监听
sudo netstat -tlnp | grep 9090

# 检查版本
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -c
```

### 2. 配置透明代理

```bash
# 运行透明代理配置脚本
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh
```

### 3. 添加订阅

1. 刷新 Proxmox Web UI 页面
2. 在数据中心菜单中点击 "Clash 控制"
3. 在 "订阅管理" 标签页中输入订阅 URL
4. 点击 "更新订阅" 按钮

## 🔧 安装验证

### 自动验证（v1.2.7 新功能）

```bash
# 运行完整验证脚本
sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh

# 快速功能测试
sudo /opt/proxmox-clash/scripts/utils/quick_test.sh
```

### 手动检查 Web UI 集成

1. 登录 Proxmox Web UI
2. 在左侧菜单中查找 "Clash 控制" 选项
3. 点击打开控制面板
4. 检查各个功能模块是否正常显示

### 检查 API 接口

```bash
# 测试 API 接口
curl -k -u root@pam:your_password \
  https://your-proxmox-ip:8006/api2/json/nodes/your-node/clash
```

### 检查服务日志

```bash
# 查看服务日志
sudo journalctl -u clash-meta -f

# 查看安装日志
sudo journalctl -u clash-meta --since "1 hour ago"
```

## 🆘 常见问题

### 安装后插件未显示

**解决方案**：
1. 运行验证脚本：`sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh`
2. 刷新浏览器页面或清除缓存
3. 检查 HTML 模板：`grep -n "pve-panel-clash.js" /usr/share/pve-manager/index.html.tpl`

### 权限错误

**解决方案**：
1. 确保使用 `sudo` 运行安装脚本
2. 运行验证脚本自动修复权限
3. 手动设置权限：`sudo chmod 644 /usr/share/pve-manager/js/pve-panel-clash.js`

### 服务启动失败

**解决方案**：
1. 检查配置文件语法
2. 查看详细日志：`sudo journalctl -u clash-meta -f`
3. 验证端口是否被占用

## 🔗 相关链接

- [📖 安装改进详情](installation-improvements.md) - v1.2.7 完整改进说明
- [⚡ 快速参考指南](quick-reference.md) - 常用命令和故障排除
- [🔍 故障排除指南](../troubleshooting/) - 详细问题解决方案
- [⚙️ 配置指南](../configuration/) - 插件配置说明
- [📚 开发文档](../development/) - 开发者资源

---

**快速安装**: `curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash -s -- -l --verify`
