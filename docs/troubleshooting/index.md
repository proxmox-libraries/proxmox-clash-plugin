---
layout: page-with-sidebar
title: 故障排除
---

# 故障排除

本指南将帮助您解决 Proxmox Clash 插件使用过程中遇到的常见问题。

## 🔍 快速诊断

### 一键诊断
```bash
# 运行完整诊断脚本
sudo /opt/proxmox-clash/scripts/management/view_logs.sh -a

# 验证安装完整性
sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh

# 检查服务状态
sudo systemctl status clash-meta --no-pager
```

### 基础检查
```bash
# 检查服务状态
sudo systemctl status clash-meta

# 检查端口监听
sudo netstat -tlnp | grep -E ':(7890|9090)'

# 检查配置文件语法
sudo /opt/proxmox-clash/clash-meta -t -c /opt/proxmox-clash/config/config.yaml

# 检查文件权限
ls -la /opt/proxmox-clash/
```

## 🚨 常见问题

### 1. 服务无法启动

#### 快速解决
```bash
# 检查服务状态
sudo systemctl status clash-meta

# 查看日志
sudo journalctl -u clash-meta -f

# 检查配置文件语法
sudo /opt/proxmox-clash/clash-meta -t -c /opt/proxmox-clash/config/config.yaml

# 检查端口占用
sudo netstat -tlnp | grep -E ':(7890|9090)'

# 检查文件权限
sudo chown -R root:root /opt/proxmox-clash/
sudo chmod +x /opt/proxmox-clash/clash-meta
```

#### 详细解决方案
请参考 [服务安装修复指南](service-installation-fix.md)

### 2. Web UI 无法访问

#### 快速解决
```bash
# 检查 API 插件
ls -la /usr/share/perl5/PVE/API2/Clash.pm

# 检查前端插件
ls -la /usr/share/pve-manager/ext6/pve-panel-clash.js

# 重启 PVE 服务
sudo systemctl restart pveproxy
```

### 3. 透明代理不工作

#### 快速解决
```bash
# 检查 TUN 接口
ip link show clash-tun

# 检查 iptables 规则
sudo iptables -t nat -L PREROUTING

# 检查透明代理状态
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh status

# 重新配置透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh enable
```

### 4. 网络中断恢复

如果启用透明代理后网络中断：

```bash
# 方法1：停止 Clash 服务
sudo systemctl stop clash-meta

# 方法2：禁用透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh disable

# 方法3：清除 iptables 规则
sudo iptables -t nat -F PREROUTING
sudo iptables -t mangle -F PREROUTING

# 方法4：重启网络服务
sudo systemctl restart networking
```

### 5. 权限问题

```bash
# 检查用户权限
whoami
groups

# 确保用户有 sudo 权限
sudo -l

# 修复文件权限
sudo chown -R root:root /opt/proxmox-clash/
sudo chmod +x /opt/proxmox-clash/clash-meta
sudo chmod 644 /opt/proxmox-clash/config/config.yaml
```

### 6. 订阅更新失败

```bash
# 检查网络连接
curl -I https://www.google.com

# 测试订阅 URL
curl -I "YOUR_SUBSCRIPTION_URL"

# 手动更新订阅
sudo /opt/proxmox-clash/scripts/management/update_subscription.sh

# 检查订阅文件
ls -la /opt/proxmox-clash/config/
```

### 7. 版本管理问题

```bash
# 检查版本信息
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -c

# 检查可用更新
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -u

# 清理版本缓存
sudo /opt/proxmox-clash/scripts/management/version_manager.sh --clear-cache

# 强制刷新版本信息
sudo /opt/proxmox-clash/scripts/management/version_manager.sh --refresh
```

### 8. 日志查看问题

```bash
# 查看插件日志
sudo /opt/proxmox-clash/scripts/management/view_logs.sh

# 查看服务日志
sudo journalctl -u clash-meta -f

# 查看系统日志
sudo dmesg | grep -i clash

# 清空日志文件
sudo /opt/proxmox-clash/scripts/management/view_logs.sh -c
```

### 9. 性能问题

```bash
# 检查系统资源使用
top
htop

# 检查内存使用
free -h

# 检查磁盘空间
df -h

# 检查网络连接数
ss -tuln | wc -l
```

### 10. 完全重置

如果遇到严重问题需要完全重置：

```bash
# 停止服务
sudo systemctl stop clash-meta
sudo systemctl disable clash-meta

# 卸载插件
sudo /opt/proxmox-clash/scripts/management/uninstall.sh

# 清理残留文件
sudo rm -rf /opt/proxmox-clash
sudo rm -f /usr/share/perl5/PVE/API2/Clash.pm
sudo rm -f /usr/share/pve-manager/ext6/pve-panel-clash.js
sudo rm -f /etc/systemd/system/clash-meta.service

# 重新加载 systemd
sudo systemctl daemon-reload

# 重新安装
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash
```

## 🔧 诊断工具

### 内置工具
- **[服务验证工具](../../scripts/utils/service_validator.sh)** - 验证服务安装状态
- **[安装验证工具](../../scripts/utils/verify_installation.sh)** - 验证安装完整性
- **[服务修复工具](../../scripts/utils/fix_service_installation.sh)** - 修复服务安装问题

### 日志工具
- **[日志查看工具](../../scripts/management/view_logs.sh)** - 查看和管理插件日志
- **systemd 日志** - `journalctl -u clash-meta -f`
- **插件日志** - `/var/log/proxmox-clash.log`

## 📚 相关文档

- **[使用方法](../usage.md)** - 详细的使用说明和操作指南
- **[安全配置](../security.md)** - 安全最佳实践和配置模板
- **[快速参考](../quick-reference.md)** - 常用命令和快速操作
- **[脚本工具](../scripts/)** - 脚本使用说明和工具文档

## 📞 获取帮助

如果以上解决方案无法解决问题，请：

1. 查看详细的错误日志
2. 提交 GitHub Issue，包含：
   - 错误描述
   - 系统信息
   - 错误日志
   - 复现步骤
3. 联系维护者

---

*最后更新: 2024-12-19*
