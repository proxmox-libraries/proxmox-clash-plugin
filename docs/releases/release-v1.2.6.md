# Release v1.2.6

**发布日期**: 2025年1月28日  
**版本类型**: 兼容性修复  
**当前状态**: 当前版本

## 🎯 更新概述

本次更新主要修复了 ExtJS 兼容性问题，解决了 `Cannot read properties of undefined (reading '$isClass')` 错误，并进一步优化了 Proxmox Web UI 中 Clash 菜单的注入逻辑，提高了插件的稳定性和兼容性。

## ✨ 主要改进

### ExtJS 兼容性修复
- **解决 $isClass 错误**: 修复了因 ExtJS 版本兼容性导致的组件定义问题
- **改进组件定义方式**: 避免使用可能导致问题的 `Ext.define` 覆盖方式
- **增强错误处理**: 添加了完善的异常捕获和错误处理机制

### UI 注入逻辑重构
- **安全的菜单注入**: 改用原型扩展和 DOM 注入的混合方式
- **智能环境检测**: 自动等待 PVE 环境完全加载后再进行注入
- **多重注入策略**: 提供原型扩展和 DOM 注入两种备选方案

### 组件安全性增强
- **组件存在性检查**: 在所有组件操作前添加存在性验证
- **空值保护**: 防止因组件未找到导致的运行时错误
- **优雅降级**: 在组件不可用时提供备用方案

## 🔧 技术细节

### ExtJS 兼容性改进
```javascript
// 之前：直接覆盖可能导致问题的 Ext.define
Ext.define('PVE.dc.Menu', {
    override: 'PVE.dc.Menu',
    // ... 可能导致 $isClass 错误
});

// 现在：安全的原型扩展方式
if (PVE.dc.Menu.prototype) {
    var originalInitComponent = PVE.dc.Menu.prototype.initComponent;
    PVE.dc.Menu.prototype.initComponent = function() {
        // 安全地扩展功能
    };
}
```

### 组件安全操作
```javascript
// 之前：直接操作组件，可能导致错误
var statusField = me.down('displayfield[name=status]');
statusField.setValue('检查中...');

// 现在：添加存在性检查
var statusField = me.down('displayfield[name=status]');
if (statusField) {
    statusField.setValue('检查中...');
} else {
    console.warn('[Clash] 状态字段未找到，跳过状态刷新');
    return;
}
```

### 智能注入策略
1. **原型扩展注入** (优先): 通过扩展 PVE.dc.Menu 原型添加菜单项
2. **DOM 直接注入** (备选): 如果原型扩展失败，直接操作 DOM 元素
3. **环境等待机制**: 智能等待 PVE 环境完全加载后再执行注入

## 🐛 问题修复

- **ExtJS 兼容性**: 解决了 `$isClass` 属性读取错误
- **组件操作安全**: 防止因组件未找到导致的运行时崩溃
- **菜单注入稳定性**: 提高了菜单项注入的成功率和稳定性
- **错误处理完善**: 添加了详细的错误日志和异常处理

## 📋 兼容性

- **PVE 版本**: 完全兼容 PVE 7.x 和 PVE 8.x 系列
- **ExtJS 版本**: 兼容 Proxmox 使用的所有 ExtJS 版本
- **浏览器支持**: 支持所有现代浏览器
- **操作系统**: 兼容 Debian/Ubuntu 系列

## 🚀 升级说明

### 自动升级
```bash
sudo proxmox-clash-upgrade
```

### 手动升级
```bash
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash -s -- latest
```

### 升级后验证
```bash
# 检查插件状态
sudo systemctl status clash-meta

# 查看 Web UI 是否正常显示
# 在浏览器中刷新 Proxmox Web UI 页面
```

## 📖 使用说明

升级完成后：
1. 刷新 Proxmox Web UI 页面
2. 在左侧 Datacenter 导航中查找 "Clash 控制" 菜单项
3. 点击菜单项打开 Clash 控制面板
4. 如果遇到问题，使用调试命令排查

### 调试命令
```javascript
// 在浏览器控制台中执行
// 检查注入状态
window.clashDebugCommands.status()

// 手动触发菜单注入
window.clashDebugCommands.inject()

// 直接创建 Clash 窗口
window.clashDebugCommands.createWindow()
```

## 🔍 故障排除

### 常见问题

#### 1. 菜单项未显示
- 检查浏览器控制台是否有错误信息
- 使用 `window.clashDebugCommands.status()` 检查状态
- 尝试手动注入：`window.clashDebugCommands.inject()`

#### 2. ExtJS 相关错误
- 确认已升级到 v1.2.6 版本
- 清除浏览器缓存并刷新页面
- 检查 `/usr/share/pve-manager/js/pve-panel-clash.js` 文件

#### 3. 组件操作失败
- 查看控制台警告信息
- 确认相关组件已正确加载
- 使用调试命令重新注入菜单

### 日志查看
```bash
# 查看 Clash 服务日志
sudo journalctl -u clash-meta -f

# 查看 PVE 相关日志
sudo journalctl -u pveproxy -f
```

## 🔒 安全改进

- **组件验证**: 所有组件操作前都进行存在性验证
- **错误隔离**: 单个组件失败不会影响整体功能
- **安全降级**: 在异常情况下提供备用功能

## 📈 性能优化

- **延迟加载**: 智能等待 PVE 环境加载完成
- **注入优化**: 减少不必要的 DOM 操作和组件查找
- **错误恢复**: 快速失败和自动重试机制

## 📞 技术支持

如遇到问题，请：
1. 查看 [项目文档](https://proxmox-libraries.github.io/proxmox-clash-plugin/)
2. 提交 [GitHub Issue](https://github.com/proxmox-libraries/proxmox-clash-plugin/issues)
3. 查看 [故障排除指南](../troubleshooting/)
4. 使用内置调试命令进行问题排查

## 🔮 未来计划

- **UI 组件优化**: 进一步改进 Web UI 组件的稳定性
- **错误处理增强**: 提供更详细的错误信息和解决建议
- **兼容性扩展**: 支持更多 PVE 版本和浏览器环境

---

**下载地址**: [GitHub Releases](https://github.com/proxmox-libraries/proxmox-clash-plugin/releases)  
**文档地址**: [在线文档](https://proxmox-libraries.github.io/proxmox-clash-plugin/)  
**问题反馈**: [GitHub Issues](https://github.com/proxmox-libraries/proxmox-clash-plugin/issues)
