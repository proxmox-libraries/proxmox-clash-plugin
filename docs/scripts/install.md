---
layout: page
title: 安装脚本
---

# 安装脚本

这个目录包含 Proxmox Clash 插件的安装相关脚本。

## 脚本说明

### install.sh
- **功能**: 直接脚本安装，支持版本选择
- **用法**: 
  ```bash
  # 安装最新版本
  curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash
  
  # 安装指定版本
  curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- v1.1.0
  ```

## 安装流程

1. 下载指定版本的源码包
2. 解压并复制文件到 `/opt/proxmox-clash`
3. 安装 API 模块到 Proxmox VE
4. 安装 UI 组件到 Proxmox VE
5. 安装 systemd 服务
6. 下载 Clash.Meta (mihomo) 内核
7. 创建默认配置文件
8. 创建管理脚本链接
