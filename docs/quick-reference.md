# 快速参考

## 🔧 常用命令

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

# 启用自启动
sudo systemctl enable clash-meta

# 禁用自启动
sudo systemctl disable clash-meta
```

### 配置管理
```bash
# 重载配置
curl -X PUT http://127.0.0.1:9090/configs/reload

# 备份配置
sudo cp /opt/proxmox-clash/config/config.yaml /opt/proxmox-clash/config/config.yaml.backup

# 恢复配置
sudo cp /opt/proxmox-clash/config/config.yaml.backup /opt/proxmox-clash/config/config.yaml

# 编辑配置
sudo nano /opt/proxmox-clash/config/config.yaml
```

### 订阅管理
```bash
# 更新订阅
sudo /opt/proxmox-clash/scripts/management/update_subscription.sh

# 查看订阅状态
curl http://127.0.0.1:9090/proxies

# 切换代理
curl -X PUT http://127.0.0.1:9090/proxies/Proxy -d '{"name":"Auto"}'
```

### 透明代理
```bash
# 启用透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh enable

# 禁用透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh disable

# 查看状态
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh status
```

### 版本管理
```bash
# 检查更新
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -u

# 升级到最新版本
sudo /opt/proxmox-clash/scripts/upgrade.sh -l

# 查看当前版本
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -c
```

### 日志查看
```bash
# 查看插件日志
sudo /opt/proxmox-clash/scripts/management/view_logs.sh

# 实时跟踪日志
sudo /opt/proxmox-clash/scripts/management/view_logs.sh -f

# 查看服务日志
sudo journalctl -u clash-meta -f
```

## 🌐 网络测试

### 代理测试
```bash
# 测试 HTTP 代理
curl -x http://127.0.0.1:7890 https://www.google.com

# 测试 SOCKS5 代理
curl --socks5 127.0.0.1:7890 https://www.google.com

# 测试透明代理
curl https://www.google.com
```

### 连接测试
```bash
# 测试端口监听
netstat -tlnp | grep -E ':(7890|9090)'

# 测试 API 接口
curl http://127.0.0.1:9090/version

# 测试代理延迟
curl http://127.0.0.1:9090/proxies/Auto/delay
```

## 📊 状态检查

### 系统状态
```bash
# 检查服务状态
sudo systemctl is-active clash-meta

# 检查端口占用
sudo ss -tlnp | grep clash

# 检查进程
ps aux | grep clash
```

### 网络状态
```bash
# 检查 TUN 接口
ip link show clash-tun

# 检查 iptables 规则
sudo iptables -t nat -L PREROUTING

# 检查路由表
ip route show
```

## 🔍 故障诊断

### 快速诊断
```bash
# 一键诊断脚本
sudo /opt/proxmox-clash/scripts/management/view_logs.sh -a

# 检查配置文件语法
sudo /opt/proxmox-clash/clash-meta -t -c /opt/proxmox-clash/config/config.yaml

# 检查文件权限
ls -la /opt/proxmox-clash/
```

### 网络诊断
```bash
# 检查 DNS 解析
nslookup www.google.com 127.0.0.1

# 检查网络连通性
ping -c 3 8.8.8.8

# 检查代理连接
curl -I --connect-timeout 5 http://127.0.0.1:7890
```

## 📝 配置文件位置

| 文件类型 | 路径 | 说明 |
|---------|------|------|
| 主配置 | `/opt/proxmox-clash/config/config.yaml` | Clash 主配置文件 |
| 安全配置 | `/opt/proxmox-clash/config/safe-config.yaml` | 安全配置模板 |
| 日志配置 | `/opt/proxmox-clash/config/logrotate.conf` | 日志轮转配置 |
| 服务文件 | `/etc/systemd/system/clash-meta.service` | systemd 服务文件 |
| API 插件 | `/usr/share/perl5/PVE/API2/Clash.pm` | PVE API 插件 |
| 日志文件 | `/var/log/proxmox-clash.log` | 插件日志文件 |

## 🔗 常用 URL

| 功能 | URL | 说明 |
|------|-----|------|
| Clash API | `http://127.0.0.1:9090` | Clash 控制 API |
| 代理端口 | `http://127.0.0.1:7890` | HTTP/SOCKS5 代理 |
| 订阅更新 | `http://127.0.0.1:9090/configs/reload` | 重载配置 |

## 🚀 快速安装

### 一键安装
```bash
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash
```

### 模块化安装
```bash
# 安装最新版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash

# 安装指定版本
curl -sSL https://raw.githubusercontent.com/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- v1.1.0
```

### GitHub 镜像配置
```bash
# 检查网络连接
bash scripts/utils/setup_github_mirror.sh -c

# 设置 ghproxy 镜像（推荐）
bash scripts/utils/setup_github_mirror.sh -m ghproxy
```

## 📋 常用脚本

### 管理脚本
```bash
# 版本管理
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -l

# 订阅更新
sudo /opt/proxmox-clash/scripts/management/update_subscription.sh

# 服务升级
sudo /opt/proxmox-clash/scripts/upgrade.sh -l
```

### 工具脚本
```bash
# 服务验证
sudo /opt/proxmox-clash/scripts/utils/service_validator.sh

# 透明代理配置
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh enable

# 安装验证
sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh
```

## 🔧 故障排除

### 常见问题
```bash
# 服务无法启动
sudo systemctl status clash-meta
sudo journalctl -u clash-meta -f

# 网络中断
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh disable

# 权限问题
sudo chown -R root:root /opt/proxmox-clash/
sudo chmod +x /opt/proxmox-clash/clash-meta
```

### 完全重置
```bash
# 停止服务
sudo systemctl stop clash-meta
sudo systemctl disable clash-meta

# 卸载插件
sudo /opt/proxmox-clash/scripts/management/uninstall.sh

# 重新安装
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash
```
