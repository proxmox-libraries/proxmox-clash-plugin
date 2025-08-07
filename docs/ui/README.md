# UI 目录

这个目录包含 Proxmox VE Web UI 的前端插件。

## 📁 目录内容

- `pve-panel-clash.js` - ExtJS 前端界面插件

## 🎨 功能说明

`pve-panel-clash.js` 是 Proxmox VE 的 ExtJS 前端插件，提供以下功能：

### 界面组件

- **状态监控面板** - 显示 Clash 运行状态、配置信息、内存使用等
- **订阅管理面板** - 订阅 URL 输入、配置名称、更新订阅功能
- **网络设置面板** - 端口信息、透明代理配置、连接测试
- **代理节点管理** - 网格显示代理列表、节点测速、一键切换

### 技术特性

- 使用 ExtJS 6.x 框架
- 深度集成到 Proxmox Web UI
- 原生窗口体验（支持最大化、调整大小）
- 响应式布局设计

## 🔧 集成方式

- 注册到数据中心菜单
- 通过 `PVE.dc.Menu` 添加菜单项
- 使用 `Ext.window.Window` 创建独立窗口

## 🔄 安装位置

安装时会被复制到：`/usr/share/pve-manager/ext6/pve-panel-clash.js`

## 📝 使用说明

安装后，用户可以在 Proxmox Web UI 的数据中心菜单中看到 "Clash 控制" 选项，点击后会打开完整的控制面板。 