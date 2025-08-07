# 管理脚本

这个目录包含 Proxmox Clash 插件的管理和维护脚本。

## 脚本说明

### upgrade.sh
- **功能**: 升级插件到最新版本或指定版本
- **用法**: 
  ```bash
  sudo bash scripts/management/upgrade.sh -l  # 升级到最新版本
  sudo bash scripts/management/upgrade.sh -v v1.1.0  # 升级到指定版本
  ```

### version_manager.sh
- **功能**: 版本管理核心脚本，提供版本查询和比较功能
- **用法**: 
  ```bash
  bash scripts/management/version_manager.sh --latest  # 获取最新版本
  bash scripts/management/version_manager.sh --all     # 获取所有版本
  ```

### uninstall.sh
- **功能**: 完全卸载插件
- **用法**: 
  ```bash
  sudo bash scripts/management/uninstall.sh
  ```

### update_subscription.sh
- **功能**: 更新 Clash 订阅配置
- **用法**: 
  ```bash
  sudo bash scripts/management/update_subscription.sh <订阅URL>
  ```

### view_logs.sh
- **功能**: 查看和管理插件日志
- **用法**: 
  ```bash
  sudo bash scripts/management/view_logs.sh  # 查看实时日志
  sudo bash scripts/management/view_logs.sh -f  # 查看完整日志
  ```

## 快捷命令

安装后，以下命令会被创建到 `/usr/local/bin/`：
- `proxmox-clash-install` - 安装脚本
- `proxmox-clash-upgrade` - 升级脚本  
- `proxmox-clash-uninstall` - 卸载脚本
