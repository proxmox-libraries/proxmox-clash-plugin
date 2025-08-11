# Proxmox Clash 原生插件

[![Version](https://img.shields.io/badge/version-v1.2.0+-blue.svg)](https://github.com/proxmox-libraries/proxmox-clash-plugin/releases/tag/v1.2.0)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Proxmox%20VE-orange.svg)](https://proxmox.com)

一个专为 Proxmox VE 设计的 Clash.Meta (mihomo) 命令行插件，提供安全透明代理和完整的命令行管理功能。

**🎉 最新版本 v1.2.0+ 现已发布！** - [查看发布说明](docs/releases/)

## 🚀 功能特性

- ✅ **内置 Clash.Meta (mihomo)** - 使用最新的 mihomo 内核
- ✅ **命令行管理** - 完整的命令行管理工具，支持所有功能
- ✅ **安全透明代理** - 默认关闭，用户手动开启，避免网络中断风险
- ✅ **订阅管理** - 支持订阅导入、更新、节点切换
- ✅ **REST API** - 提供完整的 API 接口
- ✅ **systemd 服务** - 自动启动和管理
- ✅ **详细日志系统** - 完整的日志记录，便于调试和错误排查
- ✅ **版本升级功能** - 自动检测更新、一键升级、备份恢复
- 🆕 **模块化架构** - 重构后的安装脚本，支持选择性执行和更好的维护性
- 🧪 **模块测试** - 内置模块加载测试，确保重构质量
- 🔧 **服务验证** - 自动服务安装验证，解决安装问题

## 📁 项目结构

```
proxmox-clash-plugin/
├── api/
│   └── Clash.pm                 # PVE API2 后端插件
├── scripts/
│   ├── install.sh               # 🆕 模块化安装脚本（重构版）
│   ├── install/                 # 🔧 功能模块目录
│   ├── management/              # 📋 管理脚本目录
│   └── utils/                   # 🛠️ 工具脚本目录
├── service/
│   └── clash-meta.service       # systemd 服务文件
├── config/                      # 配置文件目录
├── clash-meta/                  # mihomo 内核目录
└── docs/                        # 📚 完整文档目录
```

## 📚 文档

📖 **完整文档**: [docs/](docs/) - 详细使用指南和配置说明

### 快速导航
- 🚀 [功能特性](docs/features.md) - 插件功能和技术特性
- 📖 [使用方法](docs/usage.md) - 详细使用说明和操作指南
- 🔒 [安全配置](docs/security.md) - 安全最佳实践和配置模板
- 🔧 [快速参考](docs/quick-reference.md) - 常用命令和快速操作
- 🚀 [安装指南](docs/installation/) - 详细的安装说明和配置
- 🔧 [脚本工具](docs/scripts/) - 脚本使用说明和工具文档
- 🛠️ [故障排除](docs/troubleshooting/) - 常见问题和解决方案

## 🛠️ 安装方法

### 🚀 一键安装（推荐）

最简单的安装方式，自动下载并安装最新版本：

```bash
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash
```

### 🔧 模块化脚本安装

支持选择性执行和版本选择的模块化安装方式：

```bash
# 安装最新版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash

# 安装指定版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- v1.1.0

# 跳过特定步骤（如依赖检查）
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- --skip dependencies,download

# 启用安装后验证
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | sudo bash -s -- --verify
```

### 🌐 GitHub 访问优化（中国大陆用户）

如果遇到 GitHub 下载慢的问题，可以先配置镜像源：

```bash
# 检查网络连接
bash scripts/utils/setup_github_mirror.sh -c

# 设置 ghproxy 镜像（推荐）
bash scripts/utils/setup_github_mirror.sh -m ghproxy
```

## 🆕 模块化架构优势

### 🎯 重构成果
- **代码行数**: 从 795 行减少到 218 行 (-72.6%)
- **模块数量**: 从 1 个增加到 11 个 (+1000%)
- **维护难度**: 从高降低到低（显著改善）

### 🔧 新功能特性
- **选择性执行**: 支持跳过特定安装步骤
- **安装后验证**: 自动验证安装结果
- **模块化设计**: 11个独立模块，便于维护和扩展
- **服务验证**: 自动检测和修复服务安装问题

### 🧪 质量保证
- **模块测试**: 内置 `test_modules.sh` 测试脚本
- **向后兼容**: 保持与原始脚本相同的功能
- **错误处理**: 更完善的错误处理和日志输出

## 🌐 快速使用

### 1. 访问控制面板

安装完成后，使用命令行脚本管理 Clash 服务。所有功能都通过命令行提供，无需Web界面。

### 2. 添加订阅

1. 点击 "Clash 控制" 菜单
2. 在 "订阅管理" 标签页中输入订阅 URL
3. 点击 "更新订阅" 按钮

### 3. 配置透明代理

**⚠️ 安全提示**：透明代理默认关闭，需要手动开启以避免网络中断风险。

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

### 5. 查看日志

```bash
# 查看插件日志
sudo /opt/proxmox-clash/scripts/view_logs.sh

# 实时跟踪日志
sudo /opt/proxmox-clash/scripts/view_logs.sh -f
```

### 6. 版本升级

```bash
# 检查可用更新
sudo /opt/proxmox-clash/scripts/upgrade.sh -c

# 升级到最新版本
sudo /opt/proxmox-clash/scripts/upgrade.sh -l
```

## 🔧 API 接口

插件提供完整的 REST API 接口，包括代理管理、配置重载、订阅更新、透明代理配置等。详细 API 文档请查看 [使用方法](docs/usage.md#api-接口)。

## 📝 配置文件

配置文件位置：`/opt/proxmox-clash/config/config.yaml`

基础配置包含：
- 混合端口：7890
- 外部控制器：127.0.0.1:9090
- DNS 设置
- 基础规则

## 🔍 故障排除

详细的故障排除指南请查看 [故障排除文档](docs/troubleshooting/)。

常见问题快速解决：

```bash
# 服务无法启动
sudo systemctl status clash-meta
sudo journalctl -u clash-meta -f

# 网络中断恢复
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh disable

# 权限问题
sudo chown -R root:root /opt/proxmox-clash/
sudo chmod +x /opt/proxmox-clash/clash-meta
```

## 🔒 安全配置

安全配置最佳实践和配置模板请查看 [安全配置文档](docs/security.md)。

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 支持

如有问题，请提交 Issue 或联系维护者。

## 📋 快速参考

常用命令和快速操作请查看 [快速参考文档](docs/quick-reference.md)。

## 📋 版本历史

- **v1.2.0+** (2024-12-19) - 🆕 模块化重构版本，安装脚本重构为11个模块
- **v1.2.0** (2024-12-19) - 安全改进版本，透明代理默认关闭
- **v1.1.0** (2024-12-01) - 版本管理和订阅功能
- **v1.0.0** (2024-11-15) - 首次发布

详细更新日志请查看 [发布说明](docs/releases/)

### 🔄 最新更新
- **模块化重构**: 安装脚本从795行重构为11个模块，提升可维护性
- **新功能**: 支持选择性执行、安装后验证、服务自动验证
- **质量提升**: 代码行数减少72.6%，维护难度显著降低

### 📚 相关文档
- [模块化重构指南](docs/migration-guide.md) - 详细的迁移说明
- [重构完成总结](docs/refactoring-summary.md) - 重构成果和状态
- [模块结构说明](scripts/install/README.md) - 模块化架构详解 