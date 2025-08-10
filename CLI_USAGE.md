# Proxmox Clash 插件命令行使用说明

## 概述

这是一个专为 Proxmox VE 设计的 Clash.Meta (mihomo) 命令行插件，提供安全透明代理和完整的命令行管理功能。

## 安装

```bash
# 一键安装
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash

# 或直接运行安装脚本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install_direct.sh | sudo bash
```

## 命令行管理

### 服务管理

```bash
# 启动服务
sudo systemctl start clash-meta

# 停止服务
sudo systemctl stop clash-meta

# 重启服务
sudo systemctl restart clash-meta

# 查看状态
sudo systemctl status clash-meta

# 查看日志
sudo journalctl -u clash-meta -f
```

### 版本管理

```bash
# 查看当前版本
/opt/proxmox-clash/scripts/management/version_manager.sh --current

# 查看可用版本
/opt/proxmox-clash/scripts/management/version_manager.sh --list

# 升级到最新版本
/opt/proxmox-clash/scripts/management/version_manager.sh --upgrade

# 升级到指定版本
/opt/proxmox-clash/scripts/management/version_manager.sh --upgrade v1.2.0
```

### 订阅管理

```bash
# 更新订阅
/opt/proxmox-clash/scripts/management/update_subscription.sh

# 查看订阅状态
/opt/proxmox-clash/scripts/management/update_subscription.sh --status
```

### 透明代理

```bash
# 启用透明代理
/opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh enable

# 禁用透明代理
/opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh disable

# 查看状态
/opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh status
```

### 其他工具

```bash
# 验证安装
/opt/proxmox-clash/scripts/utils/verify_installation.sh

# 设置 GitHub 镜像
/opt/proxmox-clash/scripts/utils/setup_github_mirror.sh -m ghproxy

# 查看日志
/opt/proxmox-clash/scripts/management/view_logs.sh
```

## 配置文件

- 主配置：`/opt/proxmox-clash/config/config.yaml`
- 安全配置：`/opt/proxmox-clash/config/safe-config.yaml`
- 日志配置：`/opt/proxmox-clash/config/logrotate.conf`

## 端口说明

- Clash API：127.0.0.1:9090
- HTTP 代理：127.0.0.1:7890
- SOCKS5 代理：127.0.0.1:7891

## 故障排除

### 常见问题

1. **服务无法启动**
   ```bash
   sudo journalctl -u clash-meta -n 50
   ```

2. **配置文件错误**
   ```bash
   /opt/proxmox-clash/clash-meta -t -d /opt/proxmox-clash
   ```

3. **权限问题**
   ```bash
   sudo chown -R root:root /opt/proxmox-clash
   sudo chmod -R 755 /opt/proxmox-clash
   ```

### 日志文件

- 系统日志：`/var/log/proxmox-clash.log`
- 服务日志：`sudo journalctl -u clash-meta`

## 卸载

```bash
# 运行卸载脚本
/opt/proxmox-clash/scripts/management/uninstall.sh
```

## 支持

如有问题，请查看脚本输出和日志文件，或提交 Issue 到 GitHub 仓库。
