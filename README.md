# Proxmox Clash 原生插件

一个深度集成到 Proxmox VE Web UI 的 Clash.Meta (mihomo) 原生插件，提供透明代理和完整的控制功能。

## 🚀 功能特性

- ✅ **内置 Clash.Meta (mihomo)** - 使用最新的 mihomo 内核
- ✅ **原生 Web UI 集成** - 深度集成到 Proxmox Web 界面，使用 ExtJS 组件
- ✅ **自动透明代理** - CT/VM 自动使用代理，无需手动配置
- ✅ **订阅管理** - 支持订阅导入、更新、节点切换
- ✅ **REST API** - 提供完整的 API 接口
- ✅ **systemd 服务** - 自动启动和管理
- ✅ **详细日志系统** - 完整的日志记录，便于调试和错误排查
- ✅ **版本升级功能** - 自动检测更新、一键升级、备份恢复

## 📁 项目结构

```
proxmox-clash-plugin/
├── api/
│   └── Clash.pm                 # PVE API2 后端插件
├── ui/
│   └── pve-panel-clash.js       # ExtJS 前端界面
├── scripts/
│   ├── install.sh               # 安装脚本
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
└── VERSION                      # 版本文件
```

## 🛠️ 安装方法

### 方法一：一键安装（推荐）

```bash
# 克隆项目
git clone https://github.com/your-repo/proxmox-clash-plugin.git
cd proxmox-clash-plugin

# 运行安装脚本
sudo bash scripts/install.sh
```

### 方法二：手动安装

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
sudo cp ui/pve-panel-clash.js /usr/share/pve-manager/ext6/

# 5. 安装服务
sudo cp service/clash-meta.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable clash-meta
sudo systemctl start clash-meta
```

## 🌐 使用方法

### 1. 访问控制面板

安装完成后，刷新 Proxmox Web UI 页面，在数据中心菜单中会看到 "Clash 控制" 选项。点击后会打开一个完整的控制面板窗口。

### 2. 添加订阅

1. 点击 "Clash 控制" 菜单
2. 在 "订阅管理" 标签页中输入订阅 URL
3. 点击 "更新订阅" 按钮

### 3. 配置透明代理

```bash
# 运行透明代理配置脚本
sudo /opt/proxmox-clash/scripts/setup_transparent_proxy.sh
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

插件提供了完整的版本升级功能，支持自动检测更新、一键升级和备份恢复：

### 升级功能特性

- **自动版本检测** - 从 GitHub 自动获取最新版本信息
- **一键升级** - 支持升级到最新版本或指定版本
- **自动备份** - 升级前自动创建备份，确保数据安全
- **降级支持** - 支持降级到较低版本（需确认）
- **Web UI 集成** - 在控制面板中直接进行版本管理

### 升级方式

#### 1. Web UI 升级（推荐）
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
- 升级完成后需要刷新 Proxmox Web UI 页面
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
```

### 2. Web UI 无法访问

```bash
# 检查端口是否监听
sudo netstat -tlnp | grep 9090

# 检查防火墙
sudo ufw status
```

### 3. 透明代理不工作

```bash
# 检查 iptables 规则
sudo iptables -t nat -L PREROUTING

# 重新配置透明代理
sudo /opt/proxmox-clash/scripts/setup_transparent_proxy.sh
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

支持多个订阅配置文件，通过 Web UI 切换。

### 节点测速

在 Web UI 中可以测试各个节点的延迟。

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 支持

如有问题，请提交 Issue 或联系维护者。 