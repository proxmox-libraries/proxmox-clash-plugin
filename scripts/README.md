# Scripts 目录

这个目录包含各种管理和配置脚本。

## 📁 目录内容

- `install.sh` - 一键安装脚本
- `uninstall.sh` - 卸载脚本
- `update_subscription.sh` - 订阅更新脚本
- `setup_transparent_proxy.sh` - 透明代理配置脚本
- `view_logs.sh` - 日志查看工具
- `upgrade.sh` - 版本升级脚本

## 🔧 脚本说明

### install.sh
**一键安装脚本**
- 自动下载 mihomo 内核
- 安装 API 和 UI 插件
- 配置 systemd 服务
- 设置网络转发
- 创建基础配置文件

### uninstall.sh
**卸载脚本**
- 停止并禁用 clash-meta 服务
- 删除所有插件文件
- 清理 iptables 规则
- 删除主目录

### update_subscription.sh
**订阅更新脚本**
- 支持 HTTP/HTTPS 订阅 URL
- 自动解析 base64 编码订阅
- 支持明文订阅格式
- 自动重启 clash-meta 服务

### setup_transparent_proxy.sh
**透明代理配置脚本**
- 配置 iptables 规则
- 支持 TCP/UDP 透明代理
- 自动保存 iptables 规则
- 适用于 vmbr0/vmbr1 网桥

### view_logs.sh
**日志查看工具**
- 查看插件运行日志
- 支持实时跟踪日志
- 过滤错误和警告信息
- 查看 clash-meta 服务日志
- 提供日志文件管理功能

### upgrade.sh
**版本升级脚本**
- 检查 GitHub 最新版本
- 支持升级到最新版本或指定版本
- 自动创建升级前备份
- 支持从备份恢复
- 版本比较和降级确认

## 📝 使用说明

### 安装
```bash
sudo bash scripts/install.sh
```

### 卸载
```bash
sudo bash scripts/uninstall.sh
```

### 更新订阅
```bash
sudo /opt/proxmox-clash/scripts/update_subscription.sh <订阅URL> [配置名称]
```

### 配置透明代理
```bash
sudo /opt/proxmox-clash/scripts/setup_transparent_proxy.sh
```

### 查看日志
```bash
# 基本查看
sudo /opt/proxmox-clash/scripts/view_logs.sh

# 实时跟踪
sudo /opt/proxmox-clash/scripts/view_logs.sh -f

# 只显示错误
sudo /opt/proxmox-clash/scripts/view_logs.sh -e

# 显示服务日志
sudo /opt/proxmox-clash/scripts/view_logs.sh -s

# 显示所有日志
sudo /opt/proxmox-clash/scripts/view_logs.sh -a
```

### 版本升级
```bash
# 检查更新
sudo /opt/proxmox-clash/scripts/upgrade.sh -c

# 升级到最新版本
sudo /opt/proxmox-clash/scripts/upgrade.sh -l

# 升级到指定版本
sudo /opt/proxmox-clash/scripts/upgrade.sh -v 1.1.0

# 创建备份
sudo /opt/proxmox-clash/scripts/upgrade.sh -b

# 从备份恢复
sudo /opt/proxmox-clash/scripts/upgrade.sh -r backup_20231201_143022
```

## 🔒 权限要求

所有脚本都需要 root 权限运行，因为它们需要：
- 修改系统文件
- 配置网络规则
- 管理 systemd 服务 