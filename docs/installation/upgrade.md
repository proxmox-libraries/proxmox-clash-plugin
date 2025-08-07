# 版本升级脚本说明

## 📋 概述

`upgrade.sh` 是 Proxmox Clash 插件的版本升级工具，提供完整的版本管理功能。

## 🔧 功能特性

- **自动版本检测** - 从 GitHub API 获取最新版本信息
- **智能版本比较** - 支持语义化版本号比较
- **自动备份** - 升级前自动创建完整备份
- **降级支持** - 支持降级到较低版本（需用户确认）
- **错误恢复** - 升级失败时可从备份恢复
- **详细日志** - 完整的升级过程日志记录

## 📝 使用方法

### 基本语法
```bash
sudo /opt/proxmox-clash/scripts/upgrade.sh [选项]
```

### 选项说明

| 选项 | 长选项 | 说明 |
|------|--------|------|
| `-v VERSION` | `--version VERSION` | 升级到指定版本 |
| `-l` | `--latest` | 升级到最新版本 |
| `-c` | `--check` | 检查可用更新 |
| `-b` | `--backup` | 创建备份 |
| `-r BACKUP` | `--restore BACKUP` | 从备份恢复 |
| `-h` | `--help` | 显示帮助信息 |

## 🚀 使用示例

### 检查更新
```bash
sudo /opt/proxmox-clash/scripts/upgrade.sh -c
```

**输出示例：**
```
🔄 发现新版本: v1.1.0
   当前版本: v1.0.0
```

### 升级到最新版本
```bash
sudo /opt/proxmox-clash/scripts/upgrade.sh -l
```

**升级过程：**
1. 检查当前版本
2. 获取最新版本信息
3. 创建自动备份
4. 下载新版本文件
5. 停止 clash-meta 服务
6. 更新插件文件
7. 启动 clash-meta 服务
8. 清理临时文件

### 升级到指定版本
```bash
sudo /opt/proxmox-clash/scripts/upgrade.sh -v 1.1.0
```

### 创建备份
```bash
sudo /opt/proxmox-clash/scripts/upgrade.sh -b
```

**备份内容：**
- API 插件文件 (`Clash.pm`)
- UI 插件文件 (`pve-panel-clash.js`)
- 配置文件目录 (`config/`)
- 脚本文件目录 (`scripts/`)
- 版本信息文件 (`version`)

### 从备份恢复
```bash
sudo /opt/proxmox-clash/scripts/upgrade.sh -r backup_20231201_143022
```

## 📁 文件结构

### 备份目录
```
/opt/proxmox-clash/backup/
├── backup_20231201_143022/
│   ├── Clash.pm
│   ├── pve-panel-clash.js
│   ├── config/
│   ├── scripts/
│   └── backup_info.txt
└── backup_20231201_150000/
    └── ...
```

### 版本文件
```
/opt/proxmox-clash/version
```

## 🔍 版本比较逻辑

脚本使用语义化版本号比较：

- **主版本号.次版本号.修订号** (如: 1.2.3)
- 支持 `v` 前缀 (如: v1.2.3)
- 从左到右逐级比较
- 支持降级操作（需用户确认）

## ⚠️ 注意事项

### 升级前准备
- 确保有足够的磁盘空间
- 确保网络连接正常
- 建议在低峰期进行升级

### 升级过程
- clash-meta 服务会短暂停止
- 升级过程中请勿手动操作
- 升级完成后需要刷新 Web UI

### 备份管理
- 备份文件会占用磁盘空间
- 建议定期清理旧备份
- 重要升级前建议手动创建备份

### 错误处理
- 升级失败时会保留原版本
- 可以从备份恢复
- 查看日志文件排查问题

## 🐛 故障排除

### 常见问题

1. **版本检查失败**
   ```bash
   # 检查网络连接
   curl -s https://api.github.com
   
   # 查看详细日志
   sudo /opt/proxmox-clash/scripts/view_logs.sh -e
   ```

2. **升级下载失败**
   ```bash
   # 检查 GitHub 连接
   curl -L https://github.com/proxmox-libraries/proxmox-clash-plugin/archive/refs/tags/v1.1.0.tar.gz
   
   # 手动下载并解压
   ```

3. **服务启动失败**
   ```bash
   # 检查服务状态
   sudo systemctl status clash-meta
   
   # 查看服务日志
   sudo journalctl -u clash-meta -f
   ```

### 恢复操作

1. **从备份恢复**
   ```bash
   sudo /opt/proxmox-clash/scripts/upgrade.sh -r backup_20231201_143022
   ```

2. **重新安装**
   ```bash
   sudo /opt/proxmox-clash/scripts/uninstall.sh
   sudo bash scripts/install.sh
   ```

## 📞 技术支持

如遇到问题，请：
1. 查看日志文件：`/var/log/proxmox-clash.log`
2. 检查服务状态：`sudo systemctl status clash-meta`
3. 提交 Issue 到项目仓库 