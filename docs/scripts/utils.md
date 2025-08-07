---
layout: page
title: 工具脚本
---

# 工具脚本

这个目录包含 Proxmox Clash 插件的辅助工具脚本。

## 脚本说明

### setup_github_mirror.sh
- **功能**: 配置 GitHub 镜像源，解决中国大陆用户访问 GitHub 慢的问题
- **用法**: 
  ```bash
  # 检查网络连接
  bash scripts/utils/setup_github_mirror.sh -c
  
  # 设置 ghproxy 镜像（推荐）
  bash scripts/utils/setup_github_mirror.sh -m ghproxy
  
  # 设置其他镜像源
  bash scripts/utils/setup_github_mirror.sh -m fastgit
  bash scripts/utils/setup_github_mirror.sh -m cnpmjs
  ```

### setup_transparent_proxy.sh
- **功能**: 配置透明代理，实现全局代理
- **用法**: 
  ```bash
  # 启用透明代理
  sudo bash scripts/utils/setup_transparent_proxy.sh enable
  
  # 禁用透明代理
  sudo bash scripts/utils/setup_transparent_proxy.sh disable
  
  # 查看状态
  sudo bash scripts/utils/setup_transparent_proxy.sh status
  ```

## 使用场景

### GitHub 镜像配置
当遇到以下情况时，建议使用 `setup_github_mirror.sh`：
- GitHub 下载速度慢
- 安装脚本下载失败
- 需要频繁访问 GitHub 资源

### 透明代理配置
当需要以下功能时，建议使用 `setup_transparent_proxy.sh`：
- 实现全局代理
- 让所有流量通过 Clash
- 配置 iptables 规则
