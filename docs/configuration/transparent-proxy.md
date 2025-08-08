# 透明代理配置指南

## 🔒 安全设计理念

为了确保 Proxmox 主机的网络安全性，透明代理默认设置为**关闭状态**，用户需要手动开启。这样可以避免因代理不可用而导致的网络中断问题。

## ⚙️ 配置方式

### 1. Web UI 配置（推荐）

1. 登录 Proxmox Web UI
2. 在左侧菜单中找到 "Clash 控制"
3. 在 "网络设置" 面板中找到 "透明代理设置"
4. 勾选 "启用透明代理" 复选框
5. 点击 "配置 iptables 规则" 按钮

### 2. 命令行配置

```bash
# 启用透明代理
curl -X POST "https://your-pve-host:8006/api2/json/nodes/your-node/clash/toggle-transparent-proxy" \
  -H "Authorization: PVEAPIToken=user@pve!tokenid=tokenid" \
  -d '{"enable": true}'

# 禁用透明代理
curl -X POST "https://your-pve-host:8006/api2/json/nodes/your-node/clash/toggle-transparent-proxy" \
  -H "Authorization: PVEAPIToken=user@pve!tokenid=tokenid" \
  -d '{"enable": false}'
```

### 3. 手动配置文件

编辑 `/opt/proxmox-clash/config/config.yaml`：

```yaml
# 透明代理配置
tun:
  enable: true   # 启用透明代理
  stack: system
  dns-hijack:
    - any:53
  auto-route: true
  auto-detect-interface: true
```

然后重启服务：

```bash
sudo systemctl restart clash-meta
```

## 🔧 配置选项

### TUN 模式配置

```yaml
tun:
  enable: true              # 是否启用 TUN 模式
  stack: system             # 网络栈类型 (system/gvisor)
  dns-hijack:               # DNS 劫持配置
    - any:53
  auto-route: true          # 自动配置路由
  auto-detect-interface: true # 自动检测网络接口
  strict-route: false       # 严格路由模式
```

### iptables 透明代理

除了 TUN 模式，还可以使用 iptables 规则实现透明代理：

```bash
# 配置 iptables 透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh
```

## 🛡️ 安全建议

### 1. 故障转移配置

确保代理组包含直连作为备选：

```yaml
proxy-groups:
  - name: "Proxy"
    type: fallback
    proxies:
      - "auto-select"
      - "DIRECT"  # 关键：包含直连作为备选
    url: 'http://www.gstatic.com/generate_204'
    interval: 300
```

### 2. 默认规则配置

确保最后的兜底规则是直连：

```yaml
rules:
  # 本地网络直连
  - IP-CIDR,127.0.0.0/8,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT
  
  # 管理端口直连
  - DST-PORT,8006,DIRECT  # Proxmox Web UI
  - DST-PORT,22,DIRECT    # SSH
  
  # 需要代理的网站
  - DOMAIN-SUFFIX,google.com,Proxy
  - DOMAIN-SUFFIX,github.com,Proxy
  
  # 关键：最后的兜底规则
  - MATCH,DIRECT
```

### 3. DNS 配置

使用多个 DNS 服务器确保解析可用：

```yaml
dns:
  enable: true
  listen: 0.0.0.0:53
  nameserver:
    - 223.5.5.5      # 阿里 DNS
    - 119.29.29.29   # 腾讯 DNS
  fallback:
    - 8.8.8.8        # Google DNS
    - 1.1.1.1        # Cloudflare DNS
```

## 🚨 故障排除

### 1. 透明代理不工作

```bash
# 检查 TUN 接口
ip link show clash-tun

# 检查 iptables 规则
sudo iptables -t nat -L PREROUTING

# 检查服务状态
sudo systemctl status clash-meta

# 查看日志
sudo journalctl -u clash-meta -f
```

### 2. 网络中断恢复

如果启用透明代理后网络中断：

```bash
# 方法1：停止 Clash 服务
sudo systemctl stop clash-meta

# 方法2：禁用 TUN 接口
sudo ip link set dev clash-tun down

# 方法3：清除 iptables 规则
sudo iptables -t nat -F PREROUTING
sudo iptables -t mangle -F PREROUTING
```

### 3. 配置文件错误

```bash
# 验证配置文件语法
sudo /opt/proxmox-clash/clash-meta -t -d /opt/proxmox-clash/config

# 备份并重置配置
sudo cp /opt/proxmox-clash/config/config.yaml /opt/proxmox-clash/config/config.yaml.backup
sudo cp /opt/proxmox-clash/config/safe-config.yaml /opt/proxmox-clash/config/config.yaml
sudo systemctl restart clash-meta
```

## 📋 最佳实践

1. **测试环境验证**：在生产环境使用前，先在测试环境验证配置
2. **监控服务状态**：定期检查 Clash 服务状态和网络连接
3. **备份配置**：重要配置修改前先备份
4. **渐进式启用**：先启用部分代理，确认稳定后再启用透明代理
5. **故障演练**：定期测试故障恢复流程

## 🔗 相关链接

- [快速配置指南](quick-start.md)
- [故障排除指南](../troubleshooting/README.md)
- [API 文档](../development/api.md)
