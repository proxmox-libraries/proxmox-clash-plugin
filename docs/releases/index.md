# 发布说明

本文档包含了 Proxmox Clash 插件的所有发布信息和版本更新记录。

## 📋 版本列表

### 当前版本

| 版本 | 发布日期 | 代号 | 主要特性 | 状态 |
|------|----------|------|----------|------|
| [v1.2.2](release-v1.2.2.md) | 2025-08-09 | Latest Kernel & Robust Downloader | 最新内核与稳健下载器 | ✅ 当前版本 |
| [v1.2.1](release-v1.2.1.md) | 2025-08-09 | Installer & Compatibility Fixes | 安装器与兼容性修复 | 🔄 维护中 |
| [v1.2.0](release-v1.2.0.md) | 2024-12-19 | Security Enhancement Release | 安全改进，透明代理默认关闭 | 🔄 维护中 |
| [v1.1.0](release-v1.1.0.md) | 2024-12-01 | Version Management Release | 版本管理，订阅功能 | 🔄 维护中 |
| [v1.0.0](release-v1.0.0.md) | 2024-11-15 | Initial Release | 首次发布，基础功能 | 🔄 维护中 |



## 📈 版本历史

### v1.2.0 - Security Enhancement Release
**发布日期**: 2024-12-19

- [发布说明](release-v1.2.0.md) - 完整的功能介绍和升级指南

主要改进：
- 🔒 透明代理默认关闭，提高安全性
- 🎨 新增 Web UI 透明代理控制
- 🛠️ 改进故障转移机制
- 📚 完善文档和故障排除指南

### v1.1.0 - Version Management Release
**发布日期**: 2024-12-01

- [发布说明](release-v1.1.0.md) - 功能介绍和变更记录

主要改进：
- 🚀 添加版本管理功能
- 🚀 新增订阅管理功能
- 🚀 添加日志查看工具
- 🔧 优化安装脚本和错误处理

### v1.0.0 - Initial Release
**发布日期**: 2024-11-15

- [发布说明](release-v1.0.0.md) - 功能介绍和变更记录

主要功能：
- 🎉 基础 Clash.Meta 集成
- 🎉 Proxmox Web UI 插件
- 🎉 透明代理支持
- 🎉 基础配置管理

## 🔄 升级指南

### 升级建议

#### v1.2.0 升级重点
1. **透明代理配置**：需要手动启用透明代理
2. **安全配置**：建议使用新的安全配置模板
3. **故障恢复**：了解网络中断恢复方法
4. **文档阅读**：查看透明代理配置指南

#### 升级步骤
```bash
# 1. 备份当前配置
sudo cp /opt/proxmox-clash/config/config.yaml /opt/proxmox-clash/config/config.yaml.backup

# 2. 升级插件
sudo /opt/proxmox-clash/scripts/upgrade.sh -l

# 3. 检查透明代理状态
sudo /opt/proxmox-clash/scripts/utils/setup_transparent_proxy.sh status

# 4. 根据需要启用透明代理
# 通过 Web UI 或命令行启用
```

## 📅 支持时间

- **v1.2.x**：当前版本，完全支持
- **v1.1.x**：安全更新支持，功能更新有限
- **v1.0.x**：仅安全修复，建议升级

## 🔗 相关链接

- [安装指南](../installation/)
- [配置指南](../configuration/)
- [故障排除](../troubleshooting/)
- [开发文档](../development/)

## 📞 反馈和支持

如果您在使用过程中遇到问题或有改进建议，请通过以下方式反馈：

- [GitHub Issues](https://github.com/proxmox-libraries/proxmox-clash-plugin/issues)
- [GitHub Discussions](https://github.com/proxmox-libraries/proxmox-clash-plugin/discussions)
- [文档反馈](https://github.com/proxmox-libraries/proxmox-clash-plugin/issues/new)

---

**注意**：本文档会随着项目更新而持续维护。建议定期查看最新版本信息。
