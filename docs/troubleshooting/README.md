# 故障排除

本指南将帮助您解决 Proxmox Clash 插件使用过程中遇到的常见问题。

## 🔍 问题诊断

### 1. 服务状态检查

```bash
# 检查 clash-meta 服务状态
sudo systemctl status clash-meta

# 检查服务是否启用
sudo systemctl is-enabled clash-meta

# 查看服务日志
sudo journalctl -u clash-meta -f
```

### 2. 端口检查

```bash
# 检查端口监听状态
sudo netstat -tlnp | grep clash
sudo netstat -tlnp | grep 9090
sudo netstat -tlnp | grep 7890

# 检查防火墙规则
sudo iptables -t nat -L PREROUTING
sudo iptables -L INPUT
```

### 3. 配置文件检查

```bash
# 检查配置文件语法
sudo /opt/proxmox-clash/clash-meta -t -d /opt/proxmox-clash/config

# 查看配置文件
sudo cat /opt/proxmox-clash/config/config.yaml

# 检查配置文件权限
ls -la /opt/proxmox-clash/config/
```

## 🚨 常见问题

### 1. 服务无法启动

#### 问题描述
clash-meta 服务启动失败，状态显示为 failed。

#### 解决方案

```bash
# 1. 检查配置文件语法
sudo /opt/proxmox-clash/clash-meta -t -d /opt/proxmox-clash/config

# 2. 查看详细错误日志
sudo journalctl -u clash-meta -n 50

# 3. 检查端口占用
sudo netstat -tlnp | grep :9090
sudo netstat -tlnp | grep :7890

# 4. 检查文件权限
sudo chown -R root:root /opt/proxmox-clash
sudo chmod -R 755 /opt/proxmox-clash

# 5. 重新启动服务
sudo systemctl restart clash-meta
```

#### 常见原因
- 配置文件语法错误
- 端口被其他程序占用
- 文件权限问题
- 依赖库缺失

### 2. Web UI 无法访问

#### 问题描述
在 Proxmox Web UI 中看不到 "Clash 控制" 菜单，或点击后无法打开。

#### 解决方案

```bash
# 1. 检查 API 插件是否正确安装
ls -la /usr/share/perl5/PVE/API2/Clash.pm

# 2. 检查前端插件是否正确安装
ls -la /usr/share/pve-manager/ext6/pve-panel-clash.js

# 3. 重启 Proxmox 服务
sudo systemctl restart pveproxy
sudo systemctl restart pvedaemon

# 4. 清除浏览器缓存
# 在浏览器中按 Ctrl+Shift+R 强制刷新

# 5. 检查浏览器控制台错误
# 按 F12 打开开发者工具，查看 Console 标签页
```

#### 常见原因
- 插件文件未正确安装
- Proxmox 服务未重启
- 浏览器缓存问题
- JavaScript 错误

### 3. 透明代理不工作

#### 问题描述
CT/VM 中的网络流量没有通过代理，直连访问。

#### 解决方案

```bash
# 1. 检查 iptables 规则
sudo iptables -t nat -L PREROUTING

# 2. 重新配置透明代理
sudo /opt/proxmox-clash/scripts/setup_transparent_proxy.sh

# 3. 检查网桥配置
sudo ip link show vmbr0
sudo ip link show vmbr1

# 4. 测试代理连接
curl -x http://127.0.0.1:7890 http://www.google.com

# 5. 检查 DNS 配置
nslookup google.com 127.0.0.1
```

#### 常见原因
- iptables 规则未正确配置
- 网桥配置问题
- DNS 解析问题
- 代理服务未正常运行

### 4. 订阅更新失败

#### 问题描述
订阅更新时出现错误，无法获取代理节点。

#### 解决方案

```bash
# 1. 检查网络连接
curl -I https://www.google.com

# 2. 测试订阅 URL
curl -L "您的订阅URL"

# 3. 手动更新订阅
sudo /opt/proxmox-clash/scripts/update_subscription.sh "订阅URL"

# 4. 检查订阅文件
ls -la /opt/proxmox-clash/config/
cat /opt/proxmox-clash/config/config.yaml | head -20

# 5. 重启服务
sudo systemctl restart clash-meta
```

#### 常见原因
- 网络连接问题
- 订阅 URL 无效
- 订阅格式不支持
- 配置文件权限问题

### 5. 性能问题

#### 问题描述
代理速度慢，延迟高，或 CPU/内存使用率过高。

#### 解决方案

```bash
# 1. 检查系统资源使用
htop
free -h
df -h

# 2. 检查代理节点延迟
# 在 Web UI 中测试节点延迟

# 3. 优化配置文件
sudo nano /opt/proxmox-clash/config/config.yaml

# 4. 调整 DNS 配置
# 使用更快的 DNS 服务器

# 5. 检查日志中的错误
sudo /opt/proxmox-clash/scripts/view_logs.sh -e
```

#### 常见原因
- 代理节点质量差
- DNS 解析慢
- 系统资源不足
- 配置不当

## 🔧 高级故障排除

### 1. 日志分析

```bash
# 查看实时日志
sudo /opt/proxmox-clash/scripts/view_logs.sh -f

# 查看错误日志
sudo /opt/proxmox-clash/scripts/view_logs.sh -e

# 查看服务日志
sudo journalctl -u clash-meta -f

# 查看系统日志
sudo dmesg | tail -50
```

### 2. 网络诊断

```bash
# 检查网络接口
ip addr show

# 检查路由表
ip route show

# 检查 DNS 解析
nslookup google.com
dig google.com

# 检查网络连接
ping -c 4 8.8.8.8
traceroute google.com
```

### 3. 性能监控

```bash
# 监控系统资源
htop
iotop
nethogs

# 监控网络连接
ss -tuln
netstat -i

# 监控代理流量
# 在 Web UI 中查看流量统计
```

## 📞 获取帮助

### 1. 收集诊断信息

```bash
# 生成诊断报告
sudo /opt/proxmox-clash/scripts/diagnostic.sh

# 收集系统信息
uname -a
cat /etc/os-release
systemctl status clash-meta
```

### 2. 提交问题报告

在提交问题报告时，请包含以下信息：

- 系统版本和架构
- Proxmox VE 版本
- 插件版本
- 错误日志
- 复现步骤
- 期望行为

### 3. 社区支持

- [GitHub Issues](https://github.com/proxmox-libraries/proxmox-clash-plugin/issues)
- [GitHub Discussions](https://github.com/proxmox-libraries/proxmox-clash-plugin/discussions)
- [文档反馈](https://github.com/proxmox-libraries/proxmox-clash-plugin/issues/new)

## 📚 相关文档

- [日志分析](logs.md) - 详细的日志分析指南
- [性能优化](performance.md) - 性能调优指南
- [配置管理](../configuration/README.md) - 配置问题解决
- [安装指南](../installation/README.md) - 安装问题解决

## 🔗 外部资源

- [Clash.Meta 文档](https://docs.metacubex.one/)
- [Proxmox VE 文档](https://pve.proxmox.com/wiki/Main_Page)
- [iptables 文档](https://netfilter.org/documentation/)
- [systemd 文档](https://systemd.io/)
