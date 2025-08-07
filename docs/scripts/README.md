# 脚本目录

本目录包含 Proxmox Clash 插件的所有管理脚本。

## 📁 脚本列表

### 🔧 核心管理脚本

- **`install.sh`** - 传统安装脚本
- **`install_with_version.sh`** - 智能版本管理安装脚本（推荐）
- **`uninstall.sh`** - 卸载脚本
- **`upgrade.sh`** - 版本升级脚本
- **`version_manager.sh`** - 版本管理脚本（新增）

### 🔄 功能脚本

- **`update_subscription.sh`** - 订阅更新脚本
- **`setup_transparent_proxy.sh`** - 透明代理配置脚本
- **`view_logs.sh`** - 日志查看工具

### 📂 子目录

- **`upgrade/`** - 升级相关文档和工具

## 🚀 版本管理脚本

### `version_manager.sh` - 版本管理工具

这是一个全新的版本管理脚本，结合 GitHub 进行智能版本控制：

#### 主要功能

- **GitHub 集成** - 直接从 GitHub Releases 获取版本信息
- **智能缓存** - 本地缓存版本信息，减少 API 调用
- **版本比较** - 自动比较版本号，智能提示更新
- **多版本支持** - 支持查看、安装任意可用版本
- **版本详情** - 显示版本发布时间、下载次数、更新说明

#### 使用方法

```bash
# 显示最新版本
sudo ./version_manager.sh -l

# 显示当前版本
sudo ./version_manager.sh -c

# 列出所有可用版本
sudo ./version_manager.sh -a

# 显示版本详细信息
sudo ./version_manager.sh -i v1.1.0

# 检查更新
sudo ./version_manager.sh -u

# 设置当前版本
sudo ./version_manager.sh -s v1.1.0

# 清理版本缓存
sudo ./version_manager.sh --clear-cache

# 强制刷新版本信息
sudo ./version_manager.sh --refresh
```

### `install_with_version.sh` - 智能安装脚本

结合版本管理功能的安装脚本：

#### 使用方法

```bash
# 安装最新版本
sudo ./install_with_version.sh -l

# 安装指定版本
sudo ./install_with_version.sh -v v1.1.0

# 查看可用版本
sudo ./install_with_version.sh -c
```

## 🔄 升级脚本

### `upgrade.sh` - 版本升级脚本

支持自动检测更新、一键升级和备份恢复：

#### 使用方法

```bash
# 检查更新
sudo ./upgrade.sh -c

# 升级到最新版本
sudo ./upgrade.sh -l

# 升级到指定版本
sudo ./upgrade.sh -v 1.1.0

# 创建备份
sudo ./upgrade.sh -b

# 从备份恢复
sudo ./upgrade.sh -r backup_name
```

## 📋 其他脚本

### `install.sh` - 传统安装脚本

基础安装功能，适合快速部署：

```bash
sudo ./install.sh
```

### `uninstall.sh` - 卸载脚本

完全移除插件：

```bash
sudo ./uninstall.sh
```

### `update_subscription.sh` - 订阅更新脚本

更新 Clash 订阅：

```bash
sudo ./update_subscription.sh [订阅URL]
```

### `setup_transparent_proxy.sh` - 透明代理配置脚本

配置透明代理：

```bash
sudo ./setup_transparent_proxy.sh
```

### `view_logs.sh` - 日志查看工具

查看 Clash 日志：

```bash
sudo ./view_logs.sh
```

## 🔧 脚本权限

所有脚本都需要执行权限：

```bash
chmod +x *.sh
```

## 📝 注意事项

1. **版本管理脚本** 需要 `curl`、`jq` 等依赖工具
2. **升级脚本** 会自动创建备份，备份保存在 `/opt/proxmox-clash/backup/`
3. **安装脚本** 会检查系统依赖并自动安装缺失的包
4. 所有脚本都会记录详细日志到 `/var/log/proxmox-clash.log`

## 🆕 新功能

### 版本管理改进

- ✅ 结合 GitHub Releases 进行版本管理
- ✅ 智能缓存机制，减少 API 调用
- ✅ 支持查看版本详细信息和更新说明
- ✅ 支持安装任意可用版本
- ✅ 自动版本比较和更新提示 