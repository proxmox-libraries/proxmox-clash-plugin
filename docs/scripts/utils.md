---
layout: page
title: 工具脚本
---

# 工具脚本

这个目录包含 Proxmox Clash 插件的辅助工具脚本。

## 📋 脚本概览

### 核心工具脚本
- **[setup_github_mirror.sh](setup_github_mirror.sh)** - 配置 GitHub 镜像源
- **[setup_transparent_proxy.sh](setup_transparent_proxy.sh)** - 配置透明代理
- **[service_validator.sh](service_validator.sh)** - 服务安装验证
- **[fix_service_installation.sh](fix_service_installation.sh)** - 服务安装修复
- **[verify_installation.sh](verify_installation.sh)** - 安装完整性验证

## 🚀 使用方法

### GitHub 镜像配置
```bash
# 检查网络连接
bash scripts/utils/setup_github_mirror.sh -c

# 设置 ghproxy 镜像（推荐）
bash scripts/utils/setup_github_mirror.sh -m ghproxy

# 设置其他镜像源
bash scripts/utils/setup_github_mirror.sh -m fastgit
bash scripts/utils/setup_github_mirror.sh -m cnpmjs

# 查看当前配置
bash scripts/utils/setup_github_mirror.sh -s

# 重置为默认配置
bash scripts/utils/setup_github_mirror.sh -r
```

### 透明代理配置
```bash
# 启用透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh enable

# 禁用透明代理
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh disable

# 查看状态
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh status

# 重新配置
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh reconfigure

# 清除规则
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh clear
```

### 服务验证工具
```bash
# 验证服务安装
sudo /opt/proxmox-clash/scripts/utils/service_validator.sh

# 修复服务安装问题
sudo /opt/proxmox-clash/scripts/utils/fix_service_installation.sh

# 验证安装完整性
sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh

# 快速测试
sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh --quick
```

## 🔧 脚本特性

### GitHub 镜像配置
- **多镜像源支持** - 支持 ghproxy、fastgit、cnpmjs 等镜像源
- **智能检测** - 自动检测网络连接和镜像源可用性
- **配置持久化** - 配置信息保存到环境变量
- **快速切换** - 支持快速切换不同的镜像源

### 透明代理配置
- **安全启用** - 默认关闭，用户手动开启，避免网络中断风险
- **iptables 集成** - 自动配置 iptables 规则
- **TUN 接口管理** - 自动创建和管理 TUN 接口
- **状态监控** - 实时监控透明代理状态

### 服务验证工具
- **完整性检查** - 验证所有组件的安装状态
- **权限修复** - 自动修复文件权限问题
- **服务状态检查** - 验证 systemd 服务状态
- **API 接口测试** - 测试 PVE API 集成

## 📊 使用场景

### GitHub 镜像配置
当遇到以下情况时，建议使用 `setup_github_mirror.sh`：
- GitHub 下载速度慢
- 安装脚本下载失败
- 需要频繁访问 GitHub 资源
- 中国大陆网络环境

### 透明代理配置
当需要以下功能时，建议使用 `setup_transparent_proxy.sh`：
- 实现全局代理
- 让所有流量通过 Clash
- 配置 iptables 规则
- 管理 TUN 接口

### 服务验证工具
当遇到以下情况时，建议使用服务验证工具：
- 安装后插件未显示
- 服务启动失败
- 权限错误
- API 接口异常

## 🔍 故障排除

### 常见问题
```bash
# 镜像源配置失败
bash scripts/utils/setup_github_mirror.sh -c
bash scripts/utils/setup_github_mirror.sh --debug

# 透明代理启用失败
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh status
sudo iptables -t nat -L PREROUTING

# 服务验证失败
sudo /opt/proxmox-clash/scripts/utils/service_validator.sh --debug
sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh --verbose
```

### 调试模式
```bash
# 启用详细日志
bash scripts/utils/setup_github_mirror.sh --debug
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh --debug
sudo /opt/proxmox-clash/scripts/utils/service_validator.sh --debug

# 查看脚本帮助
bash scripts/utils/setup_github_mirror.sh --help
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh --help
```

## 🛡️ 安全注意事项

### 透明代理安全
- **⚠️ 重要提醒**：透明代理功能强大但有一定风险
- **启用前检查**：确保网络环境稳定
- **逐步启用**：先测试代理连接，再启用透明代理
- **故障恢复**：准备快速禁用透明代理的方法

### 权限管理
- **最小权限原则**：只给必要的权限
- **用户隔离**：限制非管理员用户访问
- **日志记录**：记录所有配置变更操作

## 📚 相关文档

- **[安全配置](../security.md)** - 安全最佳实践和配置模板
- **[使用方法](../usage.md)** - 详细的使用说明和操作指南
- **[快速参考](../quick-reference.md)** - 常用命令和快速操作
- **[故障排除](../troubleshooting/)** - 常见问题和解决方案

---

*最后更新: 2024-12-19*
