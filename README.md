# Proxmox Clash 原生插件

[![Version](https://img.shields.io/badge/version-v1.2.0-blue.svg)](https://github.com/proxmox-libraries/proxmox-clash-plugin/releases/tag/v1.2.0)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Proxmox%20VE-orange.svg)](https://proxmox.com)

一个专为 Proxmox VE 设计的 Clash.Meta (mihomo) 命令行插件，提供安全透明代理和完整的命令行管理功能。

**🎉 最新版本 v1.2.0 现已发布！** - [查看发布说明](docs/releases/)

## 🚀 功能特性

- ✅ **内置 Clash.Meta (mihomo)** - 使用最新的 mihomo 内核
- ✅ **命令行管理** - 完整的命令行管理工具，支持所有功能
- ✅ **安全透明代理** - 默认关闭，用户手动开启，避免网络中断风险
- ✅ **订阅管理** - 支持订阅导入、更新、节点切换
- ✅ **REST API** - 提供完整的 API 接口
- ✅ **systemd 服务** - 自动启动和管理
- ✅ **详细日志系统** - 完整的日志记录，便于调试和错误排查
- ✅ **版本升级功能** - 自动检测更新、一键升级、备份恢复
- 🆕 **模块化架构** - 重构后的安装脚本，支持选择性执行和更好的维护性

## 📁 项目结构

```
proxmox-clash-plugin/
├── api/
│   └── Clash.pm                 # PVE API2 后端插件

├── scripts/
│   ├── install.sh               # 🆕 模块化安装脚本（重构版）
│   ├── install_old.sh           # 原始安装脚本备份
│   ├── install/
│   │   ├── functions/           # 🔧 功能模块目录
│   │   │   ├── dependency_checker.sh    # 依赖检查
│   │   │   ├── file_downloader.sh       # 文件下载
│   │   │   ├── api_installer.sh         # API 安装
│   │   │   ├── service_installer.sh     # 服务安装
│   │   │   ├── config_creator.sh        # 配置创建
│   │   │   ├── link_creator.sh          # 链接创建
│   │   │   └── result_display.sh        # 结果显示
│   │   ├── utils/               # 🛠️ 工具模块目录
│   │   │   ├── logger.sh                # 日志输出
│   │   │   ├── argument_parser.sh       # 参数解析
│   │   │   └── helpers.sh               # 辅助函数
│   │   └── README.md            # 模块说明文档
│   ├── install_with_version.sh  # 智能版本管理安装脚本
│   ├── version_manager.sh       # 版本管理脚本
│   ├── setup_github_mirror.sh   # GitHub 镜像配置脚本
│   ├── uninstall.sh             # 卸载脚本
│   ├── update_subscription.sh   # 订阅更新脚本
│   ├── setup_transparent_proxy.sh # 透明代理配置
│   ├── view_logs.sh             # 日志查看工具
│   └── upgrade.sh               # 版本升级脚本
├── service/
│   └── clash-meta.service       # systemd 服务文件
├── config/
│   └── config.yaml              # 基础配置文件
├── clash-meta/                  # mihomo 内核目录
└── docs/                        # 📚 完整文档目录
    ├── installation/            # 安装指南
    ├── configuration/           # 配置管理
    ├── api/                     # API 文档
    
    ├── scripts/                 # 脚本工具文档
    ├── development/             # 开发文档
    └── troubleshooting/         # 故障排除
```

## 📚 文档

📖 **使用说明**: [CLI_USAGE.md](CLI_USAGE.md) - 完整的命令行使用说明 | [文档](docs/README.md) - 详细使用指南

🔄 **模块化重构**: [迁移指南](docs/migration-guide.md) - 从单文件脚本迁移到模块化架构的详细说明

### 快速导航
- 🚀 运行 install.sh 进行安装
- ⚙️ 查看 config/ 目录下的配置文件
- 🔧 使用 scripts/management/ 下的管理脚本

- 📋 使用 scripts/management/ 下的管理脚本
- 🔄 使用 scripts/management/version_manager.sh 进行版本管理
- 🛠️ 查看脚本输出和日志文件

## 🛠️ 安装方法

### 🚀 一键安装（推荐）

最简单的安装方式，自动下载并安装最新版本：

```bash
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash
```

### 🔧 直接脚本安装

支持版本选择的轻量级安装方式：

```bash
# 安装最新版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash

# 安装指定版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- v1.1.0
```

### 🌐 GitHub 访问优化（中国大陆用户）

如果遇到 GitHub 下载慢的问题，可以先配置镜像源：

```bash
# 检查网络连接
bash scripts/utils/setup_github_mirror.sh -c

# 设置 ghproxy 镜像（推荐）
bash scripts/utils/setup_github_mirror.sh -m ghproxy

# 或设置其他镜像源
bash scripts/utils/setup_github_mirror.sh -m fastgit
bash scripts/utils/setup_github_mirror.sh -m cnpmjs
```

```bash
# 1. 创建目录
sudo mkdir -p /opt/proxmox-clash/{config,scripts,clash-meta}

# 2. 下载 mihomo
curl -L https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-amd64 \
  -o /opt/proxmox-clash/clash-meta
chmod +x /opt/proxmox-clash/clash-meta

# 3. 安装 API 插件
sudo cp api/Clash.pm /usr/share/perl5/PVE/API2/

# 4. 安装前端插件


# 5. 安装服务
sudo cp service/clash-meta.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable clash-meta
sudo systemctl start clash-meta
```

## 🌐 使用方法

### 1. 访问控制面板

安装完成后，使用命令行脚本管理 Clash 服务。所有功能都通过命令行提供，无需Web界面。

### 2. 添加订阅

1. 点击 "Clash 控制" 菜单
2. 在 "订阅管理" 标签页中输入订阅 URL
3. 点击 "更新订阅" 按钮

### 3. 配置透明代理

**⚠️ 安全提示**：透明代理默认关闭，需要手动开启以避免网络中断风险。

#### 方法一：命令行配置（推荐）

1. 在 "Clash 控制" 面板中找到 "透明代理设置"
2. 勾选 "启用透明代理" 复选框
3. 点击 "配置 iptables 规则" 按钮

#### 方法二：命令行配置

```bash
# 启用透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh enable

# 禁用透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh disable

# 查看状态
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh status
```

### 4. 测试代理

在任意 CT/VM 中测试网络连接：

```bash
# 测试是否走代理
curl -I https://www.google.com
```

### 5. 查看日志

```bash
# 查看插件日志
sudo /opt/proxmox-clash/scripts/view_logs.sh

# 实时跟踪日志
sudo /opt/proxmox-clash/scripts/view_logs.sh -f

# 只显示错误日志
sudo /opt/proxmox-clash/scripts/view_logs.sh -e

# 显示服务日志
sudo /opt/proxmox-clash/scripts/view_logs.sh -s

# 显示所有相关日志
sudo /opt/proxmox-clash/scripts/view_logs.sh -a
```

### 6. 版本升级

```bash
# 检查可用更新
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

## 📝 日志系统

插件提供了完整的日志记录系统，便于调试和错误排查：

### 日志文件

- **插件日志**: `/var/log/proxmox-clash.log`
- **服务日志**: `journalctl -u clash-meta`

### 日志级别

- **DEBUG** - 详细的调试信息
- **INFO** - 一般信息
- **WARN** - 警告信息
- **ERROR** - 错误信息

### 日志内容

- API 请求和响应
- 代理切换操作
- 订阅更新过程
- 透明代理配置
- 错误和异常信息

### 日志查看工具

使用内置的日志查看工具：

```bash
# 基本用法
sudo /opt/proxmox-clash/scripts/view_logs.sh

# 常用选项
sudo /opt/proxmox-clash/scripts/view_logs.sh -f    # 实时跟踪
sudo /opt/proxmox-clash/scripts/view_logs.sh -e    # 只显示错误
sudo /opt/proxmox-clash/scripts/view_logs.sh -s    # 显示服务日志
sudo /opt/proxmox-clash/scripts/view_logs.sh -a    # 显示所有日志
sudo /opt/proxmox-clash/scripts/view_logs.sh -c    # 清空日志
```

## 🔄 版本升级系统

## 🔄 版本管理

插件提供了完整的版本管理功能，结合 GitHub 进行智能版本控制：

### 版本管理特性

- **GitHub 集成** - 直接从 GitHub Releases 获取版本信息
- **智能缓存** - 本地缓存版本信息，减少 API 调用
- **版本比较** - 自动比较版本号，智能提示更新
- **多版本支持** - 支持安装、升级到任意可用版本
- **版本详情** - 显示版本发布时间、下载次数、更新说明
- **自动备份** - 升级前自动创建备份，确保数据安全
- **降级支持** - 支持降级到较低版本（需确认）
- **命令行管理** - 通过命令行脚本进行版本管理

### 版本管理工具

#### 1. 版本管理脚本
```bash
# 显示最新版本
sudo /opt/proxmox-clash/scripts/version_manager.sh -l

# 显示当前版本
sudo /opt/proxmox-clash/scripts/version_manager.sh -c

# 列出所有可用版本
sudo /opt/proxmox-clash/scripts/version_manager.sh -a

# 显示版本详细信息
sudo /opt/proxmox-clash/scripts/version_manager.sh -i v1.1.0

# 检查更新
sudo /opt/proxmox-clash/scripts/version_manager.sh -u

# 设置当前版本
sudo /opt/proxmox-clash/scripts/version_manager.sh -s v1.1.0

# 清理版本缓存
sudo /opt/proxmox-clash/scripts/version_manager.sh --clear-cache

# 强制刷新版本信息
sudo /opt/proxmox-clash/scripts/version_manager.sh --refresh
```

#### 2. 智能安装脚本
```bash
# 安装最新版本
sudo /opt/proxmox-clash/scripts/install_with_version.sh -l

# 安装指定版本
sudo /opt/proxmox-clash/scripts/install_with_version.sh -v v1.1.0

# 查看可用版本
sudo /opt/proxmox-clash/scripts/install_with_version.sh -c
```

### 升级方式

#### 1. 命令行升级（推荐）
1. 打开 "Clash 控制" 面板
2. 点击 "网络设置" 标签页中的 "版本管理" 按钮
3. 在版本管理窗口中查看当前版本和最新版本
4. 点击 "升级到最新版本" 进行升级

#### 2. 命令行升级
```bash
# 检查更新
sudo /opt/proxmox-clash/scripts/upgrade.sh -c

# 升级到最新版本
sudo /opt/proxmox-clash/scripts/upgrade.sh -l

# 升级到指定版本
sudo /opt/proxmox-clash/scripts/upgrade.sh -v 1.1.0
```

### 备份和恢复

```bash
# 创建备份
sudo /opt/proxmox-clash/scripts/upgrade.sh -b

# 查看可用备份
ls -la /opt/proxmox-clash/backup/

# 从备份恢复
sudo /opt/proxmox-clash/scripts/upgrade.sh -r backup_20231201_143022
```

### 升级注意事项

- 升级过程中 clash-meta 服务会短暂停止
- 升级前会自动创建备份，备份保存在 `/opt/proxmox-clash/backup/`
- 升级完成后服务会自动重启
- 配置文件不会被覆盖，用户自定义配置会保留

## 🔧 API 接口

插件提供以下 REST API 接口：

- `GET /api2/json/nodes/{node}/clash` - 获取状态
- `GET /api2/json/nodes/{node}/clash/proxies` - 获取代理列表
- `PUT /api2/json/nodes/{node}/clash/proxies/{name}` - 切换代理
- `GET /api2/json/nodes/{node}/clash/proxies/{name}/delay` - 测试延迟
- `PUT /api2/json/nodes/{node}/clash/configs/reload` - 重载配置
- `POST /api2/json/nodes/{node}/clash/subscription/update` - 更新订阅
- `POST /api2/json/nodes/{node}/clash/setup-transparent-proxy` - 配置透明代理
- `POST /api2/json/nodes/{node}/clash/toggle-transparent-proxy` - 切换透明代理状态
- `GET /api2/json/nodes/{node}/clash/traffic` - 获取流量统计
- `GET /api2/json/nodes/{node}/clash/logs` - 获取连接日志
- `GET /api2/json/nodes/{node}/clash/version` - 获取版本信息
- `GET /api2/json/nodes/{node}/clash/version/check` - 检查可用更新
- `POST /api2/json/nodes/{node}/clash/version/upgrade` - 执行插件升级

## 📝 配置文件

配置文件位置：`/opt/proxmox-clash/config/config.yaml`

基础配置包含：
- 混合端口：7890
- 外部控制器：127.0.0.1:9090
- DNS 设置
- 基础规则

## 🔍 故障排除

### 1. 服务无法启动

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
ls -la /opt/proxmox-clash/clash-meta
ls -la /opt/proxmox-clash/config/
```

### 2. 命令行功能异常

```bash
# 检查端口是否监听
sudo netstat -tlnp | grep 9090

# 检查防火墙
sudo ufw status

# 检查 PVE API 插件
ls -la /usr/share/perl5/PVE/API2/Clash.pm

# 检查前端插件
ls -la /usr/share/pve-manager/ext6/pve-panel-clash.js

# 重启 PVE 服务
sudo systemctl restart pveproxy
```

### 3. 透明代理不工作

```bash
# 检查 TUN 接口
ip link show clash-tun

# 检查 iptables 规则
sudo iptables -t nat -L PREROUTING

# 检查透明代理状态
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh status

# 重新配置透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh enable

# 检查内核模块
lsmod | grep tun
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

## 🔒 安全配置

### 安全最佳实践

#### 1. 透明代理安全使用

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

#### 2. 网络安全配置

```bash
# 配置防火墙规则
sudo ufw allow 7890/tcp  # 代理端口
sudo ufw allow 9090/tcp  # 控制端口
sudo ufw deny 7890/udp   # 拒绝 UDP 代理

# 限制访问来源
sudo ufw allow from 192.168.1.0/24 to any port 9090
```

#### 3. 配置文件安全

使用安全配置模板：

```bash
# 备份当前配置
sudo cp /opt/proxmox-clash/config/config.yaml /opt/proxmox-clash/config/config.yaml.backup

# 使用安全配置
sudo cp /opt/proxmox-clash/config/safe-config.yaml /opt/proxmox-clash/config/config.yaml

# 重启服务
sudo systemctl restart clash-meta
```

#### 4. 访问控制

```bash
# 设置配置文件权限
sudo chmod 600 /opt/proxmox-clash/config/config.yaml
sudo chown root:root /opt/proxmox-clash/config/config.yaml

# 限制日志文件访问
sudo chmod 644 /var/log/proxmox-clash.log
sudo chown root:adm /var/log/proxmox-clash.log
```

#### 5. 监控和审计

```bash
# 设置日志轮转
sudo cp /opt/proxmox-clash/config/logrotate.conf /etc/logrotate.d/proxmox-clash

# 监控服务状态
sudo systemctl status clash-meta --no-pager

# 检查异常连接
sudo netstat -tlnp | grep clash
```

### 安全配置模板

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

## 🚀 高级功能

### 自定义规则

编辑 `/opt/proxmox-clash/config/config.yaml` 添加自定义规则：

```yaml
rules:
  - DOMAIN-SUFFIX,example.com,Proxy
  - IP-CIDR,192.168.1.0/24,DIRECT
  - MATCH,Proxy
```

### 多订阅管理

支持多个订阅配置文件，通过命令行脚本切换。

### 节点测速

通过命令行脚本可以测试各个节点的延迟。

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 支持

如有问题，请提交 Issue 或联系维护者。

## 📋 快速参考

### 🔧 常用命令

#### 服务管理
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

#### 配置管理
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

#### 订阅管理
```bash
# 更新订阅
sudo /opt/proxmox-clash/scripts/management/update_subscription.sh

# 查看订阅状态
curl http://127.0.0.1:9090/proxies

# 切换代理
curl -X PUT http://127.0.0.1:9090/proxies/Proxy -d '{"name":"Auto"}'
```

#### 透明代理
```bash
# 启用透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh enable

# 禁用透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh disable

# 查看状态
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh status
```

#### 版本管理
```bash
# 检查更新
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -u

# 升级到最新版本
sudo /opt/proxmox-clash/scripts/upgrade.sh -l

# 查看当前版本
sudo /opt/proxmox-clash/scripts/management/version_manager.sh -c
```

#### 日志查看
```bash
# 查看插件日志
sudo /opt/proxmox-clash/scripts/management/view_logs.sh

# 实时跟踪日志
sudo /opt/proxmox-clash/scripts/management/view_logs.sh -f

# 查看服务日志
sudo journalctl -u clash-meta -f
```

### 🌐 网络测试

#### 代理测试
```bash
# 测试 HTTP 代理
curl -x http://127.0.0.1:7890 https://www.google.com

# 测试 SOCKS5 代理
curl --socks5 127.0.0.1:7890 https://www.google.com

# 测试透明代理
curl https://www.google.com
```

#### 连接测试
```bash
# 测试端口监听
netstat -tlnp | grep -E ':(7890|9090)'

# 测试 API 接口
curl http://127.0.0.1:9090/version

# 测试代理延迟
curl http://127.0.0.1:9090/proxies/Auto/delay
```

### 📊 状态检查

#### 系统状态
```bash
# 检查服务状态
sudo systemctl is-active clash-meta

# 检查端口占用
sudo ss -tlnp | grep clash

# 检查进程
ps aux | grep clash
```

#### 网络状态
```bash
# 检查 TUN 接口
ip link show clash-tun

# 检查 iptables 规则
sudo iptables -t nat -L PREROUTING

# 检查路由表
ip route show
```

### 🔍 故障诊断

#### 快速诊断
```bash
# 一键诊断脚本
sudo /opt/proxmox-clash/scripts/management/view_logs.sh -a

# 检查配置文件语法
sudo /opt/proxmox-clash/clash-meta -t -c /opt/proxmox-clash/config/config.yaml

# 检查文件权限
ls -la /opt/proxmox-clash/
```

#### 网络诊断
```bash
# 检查 DNS 解析
nslookup www.google.com 127.0.0.1

# 检查网络连通性
ping -c 3 8.8.8.8

# 检查代理连接
curl -I --connect-timeout 5 http://127.0.0.1:7890
```

### 📝 配置文件位置

| 文件类型 | 路径 | 说明 |
|---------|------|------|
| 主配置 | `/opt/proxmox-clash/config/config.yaml` | Clash 主配置文件 |
| 安全配置 | `/opt/proxmox-clash/config/safe-config.yaml` | 安全配置模板 |
| 日志配置 | `/opt/proxmox-clash/config/logrotate.conf` | 日志轮转配置 |
| 服务文件 | `/etc/systemd/system/clash-meta.service` | systemd 服务文件 |
| API 插件 | `/usr/share/perl5/PVE/API2/Clash.pm` | PVE API 插件 |

| 日志文件 | `/var/log/proxmox-clash.log` | 插件日志文件 |

### 🔗 常用 URL

| 功能 | URL | 说明 |
|------|-----|------|

| Clash API | `http://127.0.0.1:9090` | Clash 控制 API |
| 代理端口 | `http://127.0.0.1:7890` | HTTP/SOCKS5 代理 |
| 订阅更新 | `http://127.0.0.1:9090/configs/reload` | 重载配置 |

## 📋 版本历史

- **v1.2.0** (2024-12-19) - 安全改进版本，透明代理默认关闭
- **v1.1.0** (2024-12-01) - 版本管理和订阅功能
- **v1.0.0** (2024-11-15) - 首次发布

详细更新日志请查看 [发布说明](docs/releases/) 