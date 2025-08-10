# 安装改进快速参考指南

## 🚀 快速开始

### 一键安装（推荐）
```bash
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash -s -- -l --verify
```

### 手动安装
```bash
# 下载并解压
git clone https://github.com/proxmox-libraries/proxmox-clash-plugin.git
cd proxmox-clash-plugin

# 安装并验证
sudo ./scripts/install/install.sh --verify
```

## 📋 安装选项

| 选项 | 说明 | 示例 |
|------|------|------|
| `--verify` | 安装完成后自动运行验证 | `--verify` |
| `--no-verify` | 跳过安装后验证 | `--no-verify` |
| `--kernel-variant` | 指定内核变体 | `--kernel-variant v2` |
| `-l, --latest` | 安装最新版本 | `-l` |
| `-v, --version` | 安装指定版本 | `-v v1.2.6` |

## 🔍 验证命令

### 完整验证
```bash
sudo /opt/proxmox-clash/scripts/utils/verify_installation.sh
```

### 快速测试
```bash
sudo /opt/proxmox-clash/scripts/utils/quick_test.sh
```

### HTML 修改测试
```bash
sudo /opt/proxmox-clash/scripts/utils/test_html_modification.sh
```

## 🛠️ 故障排除

### 常见问题速查

| 问题 | 症状 | 解决方案 |
|------|------|----------|
| 插件未显示 | Web UI 中无 Clash 菜单 | 运行验证脚本，刷新页面 |
| 权限错误 | 安装时权限相关错误 | 使用 sudo，运行验证脚本 |
| 服务启动失败 | clash-meta 服务无法启动 | 检查配置，查看日志 |

### 调试命令
```bash
# 检查服务状态
sudo systemctl status clash-meta

# 查看服务日志
sudo journalctl -u clash-meta -f

# 检查 HTML 模板
grep -n "pve-panel-clash.js" /usr/share/pve-manager/index.html.tpl

# 查看备份文件
ls -la /usr/share/pve-manager/index.html.tpl*

# 菜单滚动功能测试
sudo /opt/proxmox-clash/scripts/utils/test_menu_scroll.sh
```

### 浏览器控制台命令
```javascript
// 检查插件状态
window.clashDebugCommands.status()

// 手动修复菜单滚动
window.clashDebugCommands.fixScroll()

// 测试菜单滚动功能
window.clashDebugCommands.testScroll()

// 手动触发菜单注入
window.clashDebugCommands.inject()
```

## 📁 文件结构

### 关键文件位置
```
/opt/proxmox-clash/                    # 主安装目录
├── clash-meta                         # Clash 可执行文件
├── config/config.yaml                 # 配置文件
├── scripts/                           # 管理脚本
│   ├── install/install.sh     # 安装脚本
│   ├── management/                   # 管理脚本
│   └── utils/                        # 工具脚本
└── service/clash-meta.service        # 服务文件
```

### HTML 模板文件
```
/usr/share/pve-manager/
├── index.html.tpl                     # 当前模板文件
├── index.html.tpl.backup.*           # 备份文件
└── js/pve-panel-clash.js            # UI 插件文件
```

## 🔄 升级和卸载

### 升级
```bash
# 使用内置脚本
sudo proxmox-clash-upgrade

# 手动升级
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash -s -- latest
```

### 卸载
```bash
sudo /opt/proxmox-clash/scripts/management/uninstall.sh
```

## 📊 改进对比

| 功能 | v1.2.6 及之前 | v1.2.7 |
|------|----------------|---------|
| HTML 模板修改 | 手动修改 | 自动修改 |
| 文件权限设置 | 手动设置 | 自动设置 |
| 安装验证 | 无 | 完整验证 |
| 错误处理 | 基础 | 全面 |
| 回滚支持 | 无 | 完整支持 |
| 菜单滚动功能 | 固定位置 | 智能滚动 |

## 🎯 最佳实践

### 安装前准备
1. 确保系统是最新状态
2. 备份重要配置文件
3. 检查磁盘空间（至少 100MB）
4. 确认网络连接正常

### 安装后检查
1. 运行验证脚本确认安装成功
2. 检查 Web UI 是否显示插件
3. 验证服务状态和端口监听
4. 测试基本功能

### 日常维护
1. 定期检查服务状态
2. 监控日志文件
3. 及时更新到最新版本
4. 备份配置文件

## 🔗 相关链接

- [完整安装指南](index.md)
- [安装改进详情](installation-improvements.md)
- [故障排除指南](../troubleshooting/)
- [配置指南](../configuration/)
- [项目主页](https://github.com/proxmox-libraries/proxmox-clash-plugin)

---

**版本**: v1.2.7  
**更新日期**: 2024年12月19日  
**快速安装**: `curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/install.sh | sudo bash -s -- -l --verify`
