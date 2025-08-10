# Release v1.2.5

**发布日期**: 2025年1月27日  
**版本类型**: 功能优化  
**当前状态**: 当前版本

## 🎯 更新概述

本次更新主要优化了 Proxmox Web UI 中 Clash 菜单的注入逻辑，简化了侧边导航的插入策略，提高了界面集成的稳定性。

## ✨ 主要改进

### UI 注入逻辑优化
- **简化侧边导航注入**: 移除了复杂的 Ceph 位置查找逻辑，改为直接追加到导航树末尾
- **提高注入成功率**: 减少了因目标位置查找失败导致的注入失败情况
- **保持功能完整性**: 菜单项仍然正确显示在 Datacenter 左侧导航中

### 代码结构优化
- **减少复杂条件判断**: 简化了 `tryAttachSideNav()` 函数中的位置计算逻辑
- **统一注入策略**: 无论是否存在 Ceph 菜单项，都采用一致的追加方式
- **提高代码可维护性**: 减少了嵌套的条件分支和异常处理

## 🔧 技术细节

### 侧边导航注入简化
```javascript
// 之前：尝试插入到 Ceph 之后
var cephNode = root.findChild ? root.findChild('text', 'Ceph', true) : null;
if (cephNode && cephNode.parentNode && Ext.isFunction(cephNode.parentNode.insertChild)) {
    node = cephNode.parentNode.insertChild(cephNode.getIndex() + 1, newData);
}

// 现在：直接追加到末尾
var node = root.appendChild({ text: 'Clash 控制', iconCls: 'fa fa-cloud', leaf: true });
```

### 注入优先级
1. **侧边导航注入** (优先): 查找 `x-treelist-pve-nav` 类的 treelist 组件
2. **顶部工具栏注入** (备选): 如果侧边导航注入失败，则注入到顶部工具栏
3. **自动重试机制**: 使用 `Ext.TaskManager` 定期重试，确保在动态加载的组件中找到目标

## 🐛 问题修复

- **菜单位置稳定性**: 解决了因 Ceph 菜单项不存在或位置变化导致的注入失败
- **注入成功率提升**: 简化逻辑后，菜单项能够更可靠地出现在预期位置
- **用户体验改善**: 减少了因 UI 注入失败导致的用户困惑

## 📋 兼容性

- **PVE 版本**: 完全兼容 PVE 7.x 和 PVE 8.x 系列
- **浏览器支持**: 支持所有现代浏览器
- **ExtJS 版本**: 兼容 Proxmox 使用的 ExtJS 版本

## 🚀 升级说明

### 自动升级
```bash
sudo proxmox-clash-upgrade
```

### 手动升级
```bash
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash -s -- latest
```

## 📖 使用说明

升级完成后：
1. 刷新 Proxmox Web UI 页面
2. 在左侧 Datacenter 导航中查找 "Clash 控制" 菜单项
3. 点击菜单项打开 Clash 控制面板

## 🔍 故障排除

如果升级后仍然看不到 Clash 菜单：
1. 使用浏览器开发者工具检查 Console 是否有错误信息
2. 确认 `/usr/share/pve-manager/js/pve-panel-clash.js` 文件已正确安装
3. 尝试强制刷新页面或清除浏览器缓存

## 📞 技术支持

如遇到问题，请：
1. 查看 [项目文档](https://proxmox-libraries.github.io/proxmox-clash-plugin/)
2. 提交 [GitHub Issue](https://github.com/proxmox-libraries/proxmox-clash-plugin/issues)
3. 查看 [故障排除指南](../troubleshooting/)

---

**下载地址**: [GitHub Releases](https://github.com/proxmox-libraries/proxmox-clash-plugin/releases)  
**文档地址**: [在线文档](https://proxmox-libraries.github.io/proxmox-clash-plugin/)
