# 发布说明

欢迎查看 Proxmox Clash 插件的发布说明！这里记录了每个版本的重要更新和改进。

## 🆕 最新版本

### [v1.2.7](release-v1.2.7.md) - 安装脚本重大改进
**发布日期**: 2024-12-19

**主要特性**:
- 🚀 **自动 HTML 模板修改** - 无需手动修改配置文件
- 📋 **内置安装验证系统** - 确保安装完整性
- 🛡️ **UI 文件权限优化** - 自动设置正确的权限
- 🔄 **完整卸载清理** - 支持安全回滚和恢复

**快速安装**:
```bash
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash -s -- -l --verify
```

### [v1.2.6](release-v1.2.6.md) - 模块化重构完成
**发布日期**: 2024-12-19

**主要特性**:
- 🏗️ **模块化架构** - 安装脚本重构为11个模块
- 🔧 **选择性执行** - 支持跳过特定安装步骤
- 🧪 **模块测试** - 内置模块加载测试
- 📊 **质量提升** - 代码行数减少72.6%

### [v1.2.5](release-v1.2.5.md) - 服务安装优化
**发布日期**: 2024-12-18

**主要特性**:
- 🔧 **服务验证工具** - 自动检测和修复服务安装问题
- 🛠️ **安装修复脚本** - 解决常见的安装问题
- 📋 **安装验证** - 确保安装完整性

## 📋 版本历史

### 主要版本
- **v1.2.7** (2024-12-19) - 安装脚本重大改进
- **v1.2.6** (2024-12-19) - 模块化重构完成
- **v1.2.5** (2024-12-18) - 服务安装优化
- **v1.2.4** (2024-12-17) - 透明代理安全改进
- **v1.2.3** (2024-12-16) - 版本管理功能
- **v1.2.2** (2024-12-15) - 订阅管理优化
- **v1.2.1** (2024-12-14) - 日志系统改进
- **v1.2.0** (2024-12-13) - 安全改进版本
- **v1.1.0** (2024-12-01) - 版本管理和订阅功能
- **v1.0.0** (2024-11-15) - 首次发布

## 🔄 升级指南

### 自动升级
```bash
# 检查可用更新
sudo /opt/proxmox-clash/scripts/upgrade.sh -c

# 升级到最新版本
sudo /opt/proxmox-clash/scripts/upgrade.sh -l

# 升级到指定版本
sudo /opt/proxmox-clash/scripts/upgrade.sh -v v1.2.7
```

### 手动升级
```bash
# 下载最新版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash

# 或下载指定版本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash -s -- v1.2.7
```

## 📊 版本特性对比

| 版本 | 模块化架构 | 安装验证 | 服务验证 | 透明代理安全 |
|------|------------|----------|----------|--------------|
| v1.2.7 | ✅ | ✅ | ✅ | ✅ |
| v1.2.6 | ✅ | ✅ | ✅ | ✅ |
| v1.2.5 | ✅ | ✅ | ✅ | ✅ |
| v1.2.4 | ✅ | ✅ | ✅ | ✅ |
| v1.2.3 | ✅ | ✅ | ✅ | ✅ |
| v1.2.2 | ✅ | ✅ | ✅ | ✅ |
| v1.2.1 | ✅ | ✅ | ✅ | ✅ |
| v1.2.0 | ✅ | ✅ | ✅ | ✅ |
| v1.1.0 | ❌ | ❌ | ❌ | ❌ |
| v1.0.0 | ❌ | ❌ | ❌ | ❌ |

## 🔗 相关链接

- **[GitHub Releases](https://github.com/proxmox-libraries/proxmox-clash-plugin/releases)** - 查看所有发布版本
- **[安装指南](../installation/)** - 详细的安装说明
- **[使用方法](../usage.md)** - 使用说明和操作指南
- **[模块化重构](../migration-guide.md)** - 重构指南和说明

## 📝 更新日志

每个版本的详细更新日志请查看对应的发布说明文档。如果您发现文档有误或需要补充，欢迎提交 Issue 或 Pull Request。

---

*最后更新: 2024-12-19*
