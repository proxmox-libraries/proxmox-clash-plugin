---
layout: page
title: 安装脚本
---

# 安装脚本

这个目录包含 Proxmox Clash 插件的模块化安装脚本。

## 🆕 模块化架构

### 重构成果
- **代码行数**: 从 795 行减少到 218 行 (-72.6%)
- **模块数量**: 从 1 个增加到 11 个 (+1000%)
- **维护难度**: 从高降低到低（显著改善）

### 模块结构
```
scripts/install/
├── install.sh               # 主入口脚本（重构版）
├── functions/               # 功能模块目录
│   ├── dependency_checker.sh    # 依赖检查
│   ├── file_downloader.sh       # 文件下载
│   ├── api_installer.sh         # API 安装
│   ├── service_installer.sh     # 服务安装
│   ├── config_creator.sh        # 配置创建
│   ├── link_creator.sh          # 链接创建
│   └── result_display.sh        # 结果显示
├── utils/                   # 工具模块目录
│   ├── logger.sh                # 日志输出
│   ├── argument_parser.sh       # 参数解析
│   └── helpers.sh               # 辅助函数
├── test_modules.sh          # 模块测试脚本
└── README.md                # 模块说明文档
```

## 🚀 使用方法

### 基本安装
```bash
# 安装最新版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash

# 安装指定版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- v1.1.0
```

### 高级选项
```bash
# 跳过特定步骤
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- --skip dependencies,download

# 启用安装后验证
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- --verify

# 组合使用
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- v1.1.0 --skip dependencies --verify
```

## 🔧 新功能特性

### 选择性执行
支持跳过特定的安装步骤，提高安装灵活性：
- `--skip dependencies` - 跳过依赖检查
- `--skip download` - 跳过文件下载
- `--skip api` - 跳过 API 安装
- `--skip service` - 跳过服务安装
- `--skip config` - 跳过配置创建
- `--skip links` - 跳过链接创建

### 安装后验证
自动验证安装结果，确保安装完整性：
- 服务状态检查
- 文件权限验证
- API 接口测试
- 配置文件验证

### 服务验证
自动检测和修复服务安装问题：
- 服务文件检查
- 权限设置修复
- 依赖关系验证

## 🧪 模块测试

### 测试模块加载
```bash
# 运行模块测试脚本
sudo /opt/proxmox-clash/scripts/install/test_modules.sh

# 测试特定模块
sudo /opt/proxmox-clash/scripts/install/test_modules.sh dependency_checker
```

### 测试结果
- 模块加载状态
- 函数可用性检查
- 依赖关系验证
- 错误处理测试

## 📋 安装流程

1. **依赖检查** - 验证系统环境和依赖包
2. **文件下载** - 下载指定版本的源码包
3. **文件解压** - 解压并准备安装文件
4. **API 安装** - 安装 PVE API 插件
5. **服务安装** - 安装 systemd 服务
6. **配置创建** - 创建默认配置文件
7. **链接创建** - 创建管理脚本链接
8. **内核下载** - 下载 Clash.Meta (mihomo) 内核
9. **结果验证** - 验证安装结果（可选）

## 🔍 故障排除

### 常见问题
```bash
# 模块加载失败
sudo /opt/proxmox-clash/scripts/install/test_modules.sh

# 安装验证失败
sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh

# 服务安装问题
sudo /opt/proxmox-clash/scripts/utils/fix_service_installation.sh
```

### 调试模式
```bash
# 启用详细日志
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- --debug

# 查看安装日志
sudo tail -f /var/log/proxmox-clash.log
```

## 📚 相关文档

- **[模块化重构指南](../migration-guide.md)** - 从单文件脚本迁移到模块化架构
- **[重构完成总结](../refactoring-summary.md)** - 重构完成状态和成果总结
- **[模块结构说明](README.md)** - 详细的模块化架构说明

---

*最后更新: 2024-12-19*
