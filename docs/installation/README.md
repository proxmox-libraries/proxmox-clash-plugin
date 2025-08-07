---
layout: page-with-sidebar
title: 安装指南
---

# 安装指南

本指南将帮助您在 Proxmox VE 上安装和配置 Clash 插件。

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
```

### 方法二：直接脚本安装

```bash
# 安装最新版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install_direct.sh | sudo bash

# 安装指定版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install_direct.sh | sudo bash -s -- v1.1.0
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

### 检查 Web UI 集成

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

# 查看插件日志
sudo /opt/proxmox-clash/scripts/management/view_logs.sh
```

## 🚨 常见安装问题

### 1. 权限问题

```bash
# 确保脚本有执行权限
chmod +x scripts/*/*.sh

# 检查目录权限
sudo chown -R root:root /opt/proxmox-clash
sudo chmod -R 755 /opt/proxmox-clash
```

### 2. 依赖缺失

```bash
# 安装必要依赖
sudo apt-get update
sudo apt-get install -y curl wget jq tar
```

### 3. 端口冲突

```bash
# 检查端口占用
sudo netstat -tlnp | grep :9090
sudo netstat -tlnp | grep :7890

# 如果端口被占用，修改配置文件
sudo nano /opt/proxmox-clash/config/config.yaml
```

## 📚 相关文档

- [版本管理](version-management.md) - 版本管理功能详解
- [服务配置](service.md) - systemd 服务配置
- [快速配置](../configuration/quick-start.md) - 快速上手指南

## 🔗 下一步

安装完成后，建议您：

1. 阅读 [快速配置](../configuration/quick-start.md) 进行基础设置
2. 查看 [Web UI 使用](../ui/README.md) 了解界面操作
3. 学习 [脚本工具](../scripts/) 进行日常管理
4. 遇到问题时参考 [故障排除](../troubleshooting/README.md)
