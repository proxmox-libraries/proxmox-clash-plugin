# Config 目录

这个目录包含 Clash.Meta 的配置文件。

## 📁 目录内容

- `config.yaml` - Clash.Meta 基础配置文件
- `logrotate.conf` - 日志轮转配置文件

## 🔧 配置说明

`config.yaml` 是 Clash.Meta 的基础配置文件，包含以下配置：

### 基础设置

- **mixed-port**: `7890` - 混合代理端口
- **allow-lan**: `true` - 允许局域网访问
- **bind-address**: `'*'` - 绑定所有地址
- **mode**: `rule` - 规则模式
- **log-level**: `info` - 日志级别
- **external-controller**: `127.0.0.1:9090` - 外部控制器地址

### DNS 配置

```yaml
dns:
  enable: true
  listen: 0.0.0.0:53
  enhanced-mode: redir-host
  nameserver:
    - 223.5.5.5
    - 119.29.29.29
  fallback:
    - 8.8.8.8
    - 1.1.1.1
```

### 透明代理配置

```yaml
tun:
  enable: true
  stack: system
  dns-hijack:
    - any:53
  auto-route: true
  auto-detect-interface: true
```

### 规则配置

包含常用的代理规则：
- 国外网站走代理
- 国内网站直连
- 默认规则

## 🔄 安装位置

- `config.yaml` 安装时会被复制到：`/opt/proxmox-clash/config/config.yaml`
- `logrotate.conf` 安装时会被复制到：`/etc/logrotate.d/proxmox-clash`

## 📝 注意事项

- 此文件会被订阅更新脚本自动替换
- 代理配置和代理组由订阅自动填充
- 可以根据需要自定义规则
- 修改后需要重启 clash-meta 服务

## 🛠️ 自定义配置

可以编辑此文件添加自定义规则：

```yaml
rules:
  - DOMAIN-SUFFIX,example.com,Proxy
  - IP-CIDR,192.168.1.0/24,DIRECT
  - MATCH,Proxy
```

## 📝 日志轮转配置

`logrotate.conf` 配置了日志文件的自动轮转：

- **轮转频率**: 每日轮转
- **保留数量**: 保留 7 个备份文件
- **压缩**: 自动压缩旧日志文件
- **权限**: 644 (root:root) 