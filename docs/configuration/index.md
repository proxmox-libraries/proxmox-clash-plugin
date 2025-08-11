# 配置管理

欢迎使用 Proxmox Clash 插件配置管理指南！本指南将帮助您配置和管理插件的各种设置。

## 📚 配置文档

### 🚀 基础配置
- **[透明代理配置](transparent-proxy.md)** - 安全透明代理配置指南

### 🔒 安全配置
- **[安全配置](../security.md)** - 安全最佳实践和配置模板

## 📝 配置文件

### 主要配置文件
- **主配置**: `/opt/proxmox-clash/config/config.yaml` - Clash 主配置文件
- **安全配置**: `/opt/proxmox-clash/config/safe-config.yaml` - 安全配置模板
- **日志配置**: `/opt/proxmox-clash/config/logrotate.conf` - 日志轮转配置

### 配置文件位置
```bash
/opt/proxmox-clash/
├── config/
│   ├── config.yaml              # 主配置文件
│   ├── safe-config.yaml         # 安全配置模板
│   └── logrotate.conf           # 日志轮转配置
├── service/
│   └── clash-meta.service       # systemd 服务文件
└── clash-meta/                  # mihomo 内核目录
```

## 🔧 基础配置

### 网络配置
```yaml
# 基础网络配置
mixed-port: 7890                    # 混合端口
external-controller: 127.0.0.1:9090 # 外部控制器
allow-lan: false                     # 不允许局域网访问
bind-address: 127.0.0.1             # 绑定地址
mode: rule                           # 运行模式
log-level: info                      # 日志级别
```

### DNS 配置
```yaml
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
```

### 代理组配置
```yaml
# 代理组配置
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
```

### 规则配置
```yaml
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

## 🔒 安全配置

### 访问控制
```bash
# 设置配置文件权限
sudo chmod 600 /opt/proxmox-clash/config/config.yaml
sudo chown root:root /opt/proxmox-clash/config/config.yaml

# 限制日志文件访问
sudo chmod 644 /var/log/proxmox-clash.log
sudo chown root:adm /var/log/proxmox-clash.log
```

### 防火墙配置
```bash
# 配置防火墙规则
sudo ufw allow 7890/tcp  # 代理端口
sudo ufw allow 9090/tcp  # 控制端口
sudo ufw deny 7890/udp   # 拒绝 UDP 代理

# 限制访问来源
sudo ufw allow from 192.168.1.0/24 to any port 9090
```

## 📊 配置管理

### 配置文件操作
```bash
# 备份配置
sudo cp /opt/proxmox-clash/config/config.yaml /opt/proxmox-clash/config/config.yaml.backup

# 恢复配置
sudo cp /opt/proxmox-clash/config/config.yaml.backup /opt/proxmox-clash/config/config.yaml

# 编辑配置
sudo nano /opt/proxmox-clash/config/config.yaml

# 重载配置
curl -X PUT http://127.0.0.1:9090/configs/reload
```

### 配置验证
```bash
# 检查配置文件语法
sudo /opt/proxmox-clash/clash-meta -t -c /opt/proxmox-clash/config/config.yaml

# 验证配置
sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh
```

## 🚀 高级配置

### 自定义规则
编辑配置文件添加自定义规则：

```yaml
rules:
  - DOMAIN-SUFFIX,example.com,Proxy
  - IP-CIDR,192.168.1.0/24,DIRECT
  - DOMAIN-KEYWORD,google,Proxy
  - MATCH,Proxy
```

### 多订阅管理
支持多个订阅配置文件，通过命令行脚本切换：

```bash
# 更新订阅
sudo /opt/proxmox-clash/scripts/management/update_subscription.sh

# 查看订阅状态
curl http://127.0.0.1:9090/proxies
```

### 性能优化
```yaml
# 性能优化配置
tun:
  enable: true
  stack: system
  dns-hijack:
    - any:53
  auto-route: true
  auto-detect-interface: true

# 缓存配置
cache:
  enable: true
  max-size: 100
  max-age: 3600
```

## 🔍 配置故障排除

### 常见配置问题
```bash
# 配置文件语法错误
sudo /opt/proxmox-clash/clash-meta -t -c /opt/proxmox-clash/config/config.yaml

# 权限问题
sudo chown -R root:root /opt/proxmox-clash/
sudo chmod 644 /opt/proxmox-clash/config/config.yaml

# 配置重载失败
curl -X PUT http://127.0.0.1:9090/configs/reload
```

### 配置验证
```bash
# 运行配置验证
sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh

# 检查服务状态
sudo systemctl status clash-meta

# 查看配置日志
sudo tail -f /var/log/proxmox-clash.log
```

## 📚 相关文档

- **[使用方法](../usage.md)** - 详细的使用说明和操作指南
- **[安全配置](../security.md)** - 安全最佳实践和配置模板
- **[快速参考](../quick-reference.md)** - 常用命令和快速操作
- **[故障排除](../troubleshooting/)** - 常见问题和解决方案

## 🔗 外部资源

- [Clash.Meta 文档](https://docs.metacubex.one/) - 官方配置文档
- [Clash 规则配置](https://github.com/Dreamacro/clash/wiki/configuration) - 规则配置说明
- [iptables 配置](https://netfilter.org/documentation/) - 防火墙规则配置

---

*最后更新: 2024-12-19*
