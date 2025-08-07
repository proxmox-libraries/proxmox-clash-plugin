# 版本管理

Proxmox Clash 插件提供了完整的版本管理功能，结合 GitHub 进行智能版本控制。

## 🚀 版本管理特性

- **GitHub 集成** - 直接从 GitHub Releases 获取版本信息
- **智能缓存** - 本地缓存版本信息，减少 API 调用
- **版本比较** - 自动比较版本号，智能提示更新
- **多版本支持** - 支持安装、升级到任意可用版本
- **版本详情** - 显示版本发布时间、下载次数、更新说明
- **自动备份** - 升级前自动创建备份，确保数据安全
- **降级支持** - 支持降级到较低版本（需确认）
- **Web UI 集成** - 在控制面板中直接进行版本管理

## 📋 版本管理工具

### 1. 版本管理脚本

`version_manager.sh` 是核心版本管理工具，提供完整的版本控制功能。

#### 基本用法

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

#### 高级用法

```bash
# 获取版本详细信息（JSON 格式）
sudo /opt/proxmox-clash/scripts/version_manager.sh -i v1.1.0 | jq '.'

# 检查特定版本是否可用
sudo /opt/proxmox-clash/scripts/version_manager.sh -a | grep v1.1.0

# 比较两个版本
version1=$(sudo /opt/proxmox-clash/scripts/version_manager.sh -c)
version2=$(sudo /opt/proxmox-clash/scripts/version_manager.sh -l)
echo "当前版本: $version1, 最新版本: $version2"
```

### 2. 智能安装脚本

`install_with_version.sh` 结合版本管理功能的安装脚本。

#### 使用方法

```bash
# 安装最新版本
sudo /opt/proxmox-clash/scripts/install_with_version.sh -l

# 安装指定版本
sudo /opt/proxmox-clash/scripts/install_with_version.sh -v v1.1.0

# 查看可用版本
sudo /opt/proxmox-clash/scripts/install_with_version.sh -c

# 检查依赖
sudo /opt/proxmox-clash/scripts/install_with_version.sh --check-deps
```

## 🔄 升级流程

### 1. 检查更新

```bash
# 检查是否有可用更新
sudo /opt/proxmox-clash/scripts/upgrade.sh -c
```

### 2. 创建备份

```bash
# 升级前创建备份
sudo /opt/proxmox-clash/scripts/upgrade.sh -b
```

### 3. 执行升级

```bash
# 升级到最新版本
sudo /opt/proxmox-clash/scripts/upgrade.sh -l

# 升级到指定版本
sudo /opt/proxmox-clash/scripts/upgrade.sh -v v1.1.0
```

### 4. 验证升级

```bash
# 检查版本
sudo /opt/proxmox-clash/scripts/version_manager.sh -c

# 检查服务状态
sudo systemctl status clash-meta

# 检查 Web UI
# 刷新 Proxmox Web UI 页面，检查功能是否正常
```

## 📁 缓存管理

### 缓存位置

版本信息缓存保存在：`/opt/proxmox-clash/cache/github_versions.json`

### 缓存内容

```json
{
    "latest": {
        "tag_name": "v1.1.0",
        "published_at": "2024-01-01T00:00:00Z",
        "body": "更新说明...",
        "assets": [...]
    },
    "releases": [...],
    "fetched_at": "2024-01-01T12:00:00Z"
}
```

### 缓存管理命令

```bash
# 清理缓存
sudo /opt/proxmox-clash/scripts/version_manager.sh --clear-cache

# 强制刷新
sudo /opt/proxmox-clash/scripts/version_manager.sh --refresh

# 查看缓存状态
ls -la /opt/proxmox-clash/cache/
```

## 🔧 配置选项

### 缓存过期时间

默认缓存过期时间为 1 小时，可在脚本中修改：

```bash
# 编辑版本管理脚本
sudo nano /opt/proxmox-clash/scripts/version_manager.sh

# 修改缓存过期时间（秒）
CACHE_EXPIRY=3600  # 1小时
```

### GitHub API 配置

```bash
# 设置 GitHub 仓库
GITHUB_REPO="proxmox-libraries/proxmox-clash-plugin"

# 设置 API 地址
GITHUB_API="https://api.github.com/repos/$GITHUB_REPO"
```

## 🚨 故障排除

### 1. 无法获取版本信息

```bash
# 检查网络连接
curl -s https://api.github.com/repos/proxmox-libraries/proxmox-clash-plugin/releases/latest

# 检查依赖工具
which curl jq

# 清理缓存重试
sudo /opt/proxmox-clash/scripts/version_manager.sh --clear-cache
sudo /opt/proxmox-clash/scripts/version_manager.sh --refresh
```

### 2. 版本比较错误

```bash
# 检查版本格式
sudo /opt/proxmox-clash/scripts/version_manager.sh -c
sudo /opt/proxmox-clash/scripts/version_manager.sh -l

# 手动比较版本
echo "1.0.0" | sort -V
echo "1.1.0" | sort -V
```

### 3. 升级失败

```bash
# 检查备份
ls -la /opt/proxmox-clash/backup/

# 从备份恢复
sudo /opt/proxmox-clash/scripts/upgrade.sh -r backup_name

# 查看升级日志
sudo journalctl -u clash-meta -f
```

## 📚 最佳实践

### 1. 定期检查更新

```bash
# 添加到 crontab
echo "0 2 * * * /opt/proxmox-clash/scripts/version_manager.sh -u" | sudo crontab -
```

### 2. 升级前备份

```bash
# 升级前总是创建备份
sudo /opt/proxmox-clash/scripts/upgrade.sh -b
sudo /opt/proxmox-clash/scripts/upgrade.sh -l
```

### 3. 测试环境验证

```bash
# 在测试环境先验证新版本
sudo /opt/proxmox-clash/scripts/install_with_version.sh -v v1.1.0
# 测试功能正常后再在生产环境升级
```

## 🔗 相关文档

- [安装指南](README.md) - 完整安装流程
- [升级指南](upgrade.md) - 详细升级说明
- [故障排除](../troubleshooting/README.md) - 常见问题解决
- [脚本工具](../scripts/README.md) - 管理脚本使用
