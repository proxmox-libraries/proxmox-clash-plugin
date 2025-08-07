---
layout: default
title: 快速配置指南
---

# 快速配置指南

本指南将帮助您快速配置 Proxmox Clash 插件，让您能够在几分钟内开始使用。

## 🚀 快速开始

### 1. 基础配置

安装完成后，您需要进行以下基础配置：

#### 检查服务状态

```bash
# 检查 clash-meta 服务状态
sudo systemctl status clash-meta

# 如果服务未启动，启动服务
sudo systemctl start clash-meta
sudo systemctl enable clash-meta
```

#### 访问 Web UI

1. 打开浏览器，访问您的 Proxmox Web UI
2. 在左侧菜单中找到 "Clash 控制" 选项
3. 点击打开控制面板

### 2. 添加订阅

#### 方法一：通过 Web UI

1. 在 "Clash 控制" 面板中，点击 "订阅管理" 标签
2. 在订阅 URL 输入框中输入您的订阅地址
3. 点击 "更新订阅" 按钮
4. 等待订阅更新完成

#### 方法二：通过命令行

```bash
# 更新订阅
sudo /opt/proxmox-clash/scripts/update_subscription.sh "您的订阅URL"
```

### 3. 配置透明代理

```bash
# 运行透明代理配置脚本
sudo /opt/proxmox-clash/scripts/setup_transparent_proxy.sh
```

### 4. 测试连接

#### 在 CT/VM 中测试

```bash
# 测试网络连接
curl -I https://www.google.com

# 测试 IP 信息
curl ipinfo.io

# 测试 DNS 解析
nslookup google.com
```

## ⚙️ 基础配置选项

### 端口配置

默认端口配置：
- **混合端口**: 7890
- **外部控制器**: 127.0.0.1:9090
- **DNS 端口**: 53

如需修改端口，编辑配置文件：

```bash
sudo nano /opt/proxmox-clash/config/config.yaml
```

### DNS 配置

```yaml
dns:
  enable: true
  listen: 0.0.0.0:53
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
```

### 代理配置

```yaml
proxies:
  - name: "代理服务器"
    type: http
    server: your-proxy-server.com
    port: 8080
    username: your-username
    password: your-password
```

## 🔧 常用配置

### 1. 规则配置

```yaml
rules:
  # 直连规则
  - DOMAIN-SUFFIX,cn,DIRECT
  - DOMAIN-SUFFIX,local,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT
  - IP-CIDR,10.0.0.0/8,DIRECT
  
  # 代理规则
  - DOMAIN-SUFFIX,google.com,Proxy
  - DOMAIN-SUFFIX,github.com,Proxy
  - DOMAIN-SUFFIX,youtube.com,Proxy
  
  # 默认规则
  - MATCH,Proxy
```

### 2. 策略组配置

```yaml
proxy-groups:
  - name: Proxy
    type: select
    proxies:
      - 自动选择
      - 故障转移
      - 负载均衡
    use:
      - proxy-providers
```

### 3. 自动选择配置

```yaml
proxy-groups:
  - name: 自动选择
    type: url-test
    proxies:
      - 代理1
      - 代理2
    url: http://www.gstatic.com/generate_204
    interval: 300
    tolerance: 50
```

## 🚨 常见问题

### 1. 服务无法启动

```bash
# 检查配置文件语法
sudo /opt/proxmox-clash/clash-meta -t -d /opt/proxmox-clash/config

# 查看详细日志
sudo journalctl -u clash-meta -f
```

### 2. Web UI 无法访问

```bash
# 检查端口监听
sudo netstat -tlnp | grep 9090

# 检查防火墙
sudo ufw status
sudo ufw allow 9090
```

### 3. 透明代理不工作

```bash
# 检查 iptables 规则
sudo iptables -t nat -L PREROUTING

# 重新配置透明代理
sudo /opt/proxmox-clash/scripts/setup_transparent_proxy.sh
```

## 📚 下一步

完成基础配置后，建议您：

1. 阅读 [配置管理](README.md) 了解高级配置选项
2. 查看 [Web UI 使用](../ui/README.md) 学习界面操作
3. 学习 [脚本工具](../scripts/README.md) 进行日常管理
4. 遇到问题时参考 [故障排除](../troubleshooting/README.md)

## 🔗 相关链接

- [安装指南](../installation/README.md) - 完整安装流程
- [配置管理](README.md) - 详细配置说明
- [API 文档](../api/README.md) - API 接口文档
- [故障排除](../troubleshooting/README.md) - 问题解决方案
