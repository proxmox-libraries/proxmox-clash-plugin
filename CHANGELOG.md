# 变更日志

## [v2.0.0] - 2024-12-19

### 🗑️ 重大变更：移除Web UI功能

#### 移除的文件和目录
- `ui/` - 整个Web UI目录
- `ui/pve-panel-clash.js` - ExtJS前端界面文件
- `docs/ui/` - Web UI相关文档
- `docs/development/ui.md` - UI开发文档
- `docs/_layouts/default.html` - Jekyll布局文件
- `docs/installation/menu-scroll-fix.md` - 菜单滚动修复文档

#### 修改的文件

##### `install.sh`
- 更新功能列表，移除Web UI相关描述
- 修改文档URL

##### `scripts/install/install.sh`
- 修改`detect_pve_ui_dir`函数，始终返回空字符串
- 修改`install_ui`函数，跳过UI安装
- 删除`modify_html_template`函数
- 更新安装步骤说明
- 修改后安装提示信息

##### `scripts/utils/verify_installation.sh`
- 修改`detect_pve_ui_dir`函数
- 跳过UI文件检查
- 更新下一步操作说明

##### `scripts/management/uninstall.sh`
- 修改`detect_pve_ui_dir`函数
- 跳过前端插件删除
- 移除Web UI刷新提示

##### `scripts/management/upgrade.sh`
- 修改`detect_pve_ui_dir`函数
- 跳过UI插件备份、恢复和安装
- 更新升级后操作说明

##### `service/clash-meta.service`
- 移除`CLASH_EXTERNAL_UI`环境变量

##### `README.md`
- 更新项目描述，强调命令行功能
- 移除Web UI相关功能描述
- 更新文件结构说明
- 移除文档链接
- 更新使用说明
- 更新安装步骤
- 更新故障排除说明

#### 新增文件
- `CLI_USAGE.md` - 完整的命令行使用说明
- `docs/README.md` - 简化的文档结构

#### 功能变更
- **从**: 深度集成到Proxmox VE Web UI的Clash.Meta插件
- **到**: 专为Proxmox VE设计的命令行Clash.Meta插件

#### 使用方式变更
- **之前**: 通过Proxmox Web UI界面操作
- **现在**: 完全通过命令行脚本管理

#### 保留的核心功能
- ✅ Clash.Meta (mihomo) 内核
- ✅ 安全透明代理
- ✅ 订阅管理
- ✅ 版本管理
- ✅ 服务管理
- ✅ 配置文件管理
- ✅ 所有命令行脚本

#### 技术架构变更
- 移除ExtJS前端组件
- 移除HTML模板修改
- 移除Web UI集成代码
- 保留完整的后端API和命令行工具

#### 兼容性说明
- 此版本与之前版本不兼容
- 需要重新安装
- 配置文件格式保持不变
- 服务管理方式保持不变

#### 升级建议
- 建议全新安装v2.0.0
- 备份现有配置文件
- 使用新的命令行管理方式
- 参考CLI_USAGE.md了解使用方法
