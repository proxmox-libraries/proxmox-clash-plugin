# 使用方法

## 🌐 基本使用

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

## 📝 日志系统

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

### 版本管理特性

- **GitHub 集成** - 直接从 GitHub Releases 获取版本信息
- **智能缓存** - 本地缓存版本信息，减少 API 调用
- **版本比较** - 自动比较版本号，智能提示更新
- **多版本支持** - 支持安装、升级到任意可用版本
- **版本详情** - 显示版本发布时间、下载次数、更新说明
- **自动备份** - 升级前自动创建备份，确保数据安全
- **降级支持** - 支持降级到较低版本（需确认）
- **命令行管理** - 通过命令行脚本进行版本管理

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
