# 脚本目录

这个目录包含 Proxmox Clash 插件的所有脚本文件，按功能分类组织。

## 📁 目录结构

```
scripts/
├── install/           # 安装相关脚本
│   ├── install_direct.sh
│   └── README.md
├── management/        # 管理和维护脚本
│   ├── upgrade.sh
│   ├── version_manager.sh
│   ├── uninstall.sh
│   ├── update_subscription.sh
│   ├── view_logs.sh
│   └── README.md
├── utils/            # 工具脚本
│   ├── setup_github_mirror.sh
│   ├── setup_transparent_proxy.sh
│   └── README.md
└── README.md         # 本文件
```

## 🚀 快速开始

### 一键安装（推荐）
```bash
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash
```

### 直接脚本安装
```bash
# 安装最新版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install_direct.sh | sudo bash

# 安装指定版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install_direct.sh | sudo bash -s -- v1.1.0
```

## 📋 脚本分类

### 🔧 安装脚本 (`install/`)
- **install_direct.sh**: 直接脚本安装，支持版本选择

### 🔄 管理脚本 (`management/`)
- **upgrade.sh**: 升级插件
- **version_manager.sh**: 版本管理
- **uninstall.sh**: 卸载插件
- **update_subscription.sh**: 更新订阅
- **view_logs.sh**: 查看日志

### 🛠️ 工具脚本 (`utils/`)
- **setup_github_mirror.sh**: GitHub 镜像配置
- **setup_transparent_proxy.sh**: 透明代理配置

## 🌐 GitHub 访问优化

如果遇到 GitHub 下载慢的问题：

```bash
# 检查网络连接
bash scripts/utils/setup_github_mirror.sh -c

# 设置镜像源
bash scripts/utils/setup_github_mirror.sh -m ghproxy
```

## 📖 详细文档

- [安装脚本说明](install/README.md)
- [管理脚本说明](management/README.md)
- [工具脚本说明](utils/README.md)

## 🔗 快捷命令

安装后，以下命令会被创建到 `/usr/local/bin/`：
- `proxmox-clash-install` - 安装脚本
- `proxmox-clash-upgrade` - 升级脚本
- `proxmox-clash-uninstall` - 卸载脚本
