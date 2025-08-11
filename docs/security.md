# 安全配置

## 🔒 安全最佳实践

### 1. 透明代理安全使用

**⚠️ 重要提醒**：透明代理功能强大但有一定风险，请谨慎使用。

```bash
# 启用前检查网络环境
ping -c 3 8.8.8.8
ping -c 3 www.google.com

# 逐步启用透明代理
# 1. 先测试代理连接
curl -x http://127.0.0.1:7890 https://www.google.com

# 2. 启用透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh enable

# 3. 测试网络连接
ping -c 3 8.8.8.8
```

### 2. 网络安全配置

```bash
# 配置防火墙规则
sudo ufw allow 7890/tcp  # 代理端口
sudo ufw allow 9090/tcp  # 控制端口
sudo ufw deny 7890/udp   # 拒绝 UDP 代理

# 限制访问来源
sudo ufw allow from 192.168.1.0/24 to any port 9090
```

### 3. 配置文件安全

使用安全配置模板：

```bash
# 备份当前配置
sudo cp /opt/proxmox-clash/config/config.yaml /opt/proxmox-clash/config/config.yaml.backup

# 使用安全配置
sudo cp /opt/proxmox-clash/config/safe-config.yaml /opt/proxmox-clash/config/config.yaml

# 重启服务
sudo systemctl restart clash-meta
```

### 4. 访问控制

```bash
# 设置配置文件权限
sudo chmod 600 /opt/proxmox-clash/config/config.yaml
sudo chown root:root /opt/proxmox-clash/config/config.yaml

# 限制日志文件访问
sudo chmod 644 /var/log/proxmox-clash.log
sudo chown root:adm /var/log/proxmox-clash.log
```

### 5. 监控和审计

```bash
# 设置日志轮转
sudo cp /opt/proxmox-clash/config/logrotate.conf /etc/logrotate.d/proxmox-clash

# 监控服务状态
sudo systemctl status clash-meta --no-pager

# 检查异常连接
sudo netstat -tlnp | grep clash
```

## 🛡️ 安全配置模板

安全配置模板包含以下特性：

- **故障转移机制**：确保包含直连作为备选
- **本地网络直连**：管理网络和本地服务不走代理
- **DNS 安全配置**：多层备用 DNS 服务器
- **访问控制**：限制控制端口访问
- **日志记录**：详细的操作日志

```yaml
# 安全配置示例
mixed-port: 7890
external-controller: 127.0.0.1:9090
allow-lan: false
bind-address: 127.0.0.1
mode: rule
log-level: info

# DNS 配置
dns:
  enable: true
  listen: 0.0.0.0:53
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
  fallback:
    - https://dns.google/dns-query
    - https://cloudflare-dns.com/dns-query
  fallback-filter:
    geoip: true
    ipcidr:
      - 240.0.0.0/4
      - 0.0.0.0/32

# 代理组配置（包含故障转移）
proxy-groups:
  - name: Proxy
    type: select
    proxies:
      - Auto
      - DIRECT
  - name: Auto
    type: url-test
    proxies:
      - Proxy1
      - Proxy2
      - DIRECT
    url: http://www.gstatic.com/generate_204
    interval: 300

# 规则配置
rules:
  - DOMAIN-SUFFIX,local,DIRECT
  - DOMAIN-SUFFIX,localhost,DIRECT
  - IP-CIDR,127.0.0.0/8,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT
  - IP-CIDR,10.0.0.0/8,DIRECT
  - IP-CIDR,172.16.0.0/12,DIRECT
  - MATCH,Proxy
```

## 🔐 权限管理

### 文件权限设置

```bash
# 主目录权限
sudo chown -R root:root /opt/proxmox-clash/
sudo chmod 755 /opt/proxmox-clash/

# 可执行文件权限
sudo chmod +x /opt/proxmox-clash/clash-meta
sudo chmod +x /opt/proxmox-clash/scripts/*.sh

# 配置文件权限
sudo chmod 600 /opt/proxmox-clash/config/config.yaml
sudo chmod 644 /opt/proxmox-clash/config/safe-config.yaml

# 日志文件权限
sudo chmod 644 /var/log/proxmox-clash.log
```

### 用户权限控制

```bash
# 检查用户权限
whoami
groups

# 确保用户有 sudo 权限
sudo -l

# 限制特定用户访问
sudo usermod -a -G adm username
```

## 🚨 安全监控

### 日志监控

```bash
# 实时监控日志
sudo tail -f /var/log/proxmox-clash.log

# 监控异常访问
sudo grep -i "error\|warning\|failed" /var/log/proxmox-clash.log

# 监控网络连接
sudo netstat -tlnp | grep clash
```

### 服务监控

```bash
# 检查服务状态
sudo systemctl is-active clash-meta

# 监控资源使用
sudo systemctl status clash-meta --no-pager

# 检查端口监听
sudo ss -tlnp | grep clash
```

### 网络监控

```bash
# 检查 TUN 接口状态
ip link show clash-tun

# 检查 iptables 规则
sudo iptables -t nat -L PREROUTING

# 检查路由表
ip route show
```

## 🔧 安全工具

### 服务验证工具

```bash
# 验证服务安装
sudo /opt/proxmox-clash/scripts/utils/service_validator.sh

# 修复服务安装问题
sudo /opt/proxmox-clash/scripts/utils/fix_service_installation.sh

# 验证安装完整性
sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh
```

### 网络诊断工具

```bash
# 检查网络连通性
ping -c 3 8.8.8.8

# 测试代理连接
curl -x http://127.0.0.1:7890 https://www.google.com

# 检查 DNS 解析
nslookup www.google.com 127.0.0.1
```

## 📋 安全检查清单

### 安装后检查

- [ ] 服务状态正常
- [ ] 端口监听正确
- [ ] 文件权限设置正确
- [ ] 日志记录正常
- [ ] 网络连接正常

### 定期检查

- [ ] 服务状态监控
- [ ] 日志文件检查
- [ ] 网络连接测试
- [ ] 配置文件备份
- [ ] 权限设置验证

### 安全更新

- [ ] 定期检查版本更新
- [ ] 及时应用安全补丁
- [ ] 备份重要配置
- [ ] 测试更新后功能
- [ ] 记录更新日志
