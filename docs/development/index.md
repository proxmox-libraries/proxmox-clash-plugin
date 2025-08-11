# 开发文档

欢迎使用 Proxmox Clash 插件开发文档！本指南将帮助开发者了解插件的架构和开发流程。

## 📚 开发文档

### 🏗️ 架构设计
- **[系统架构](architecture.md)** - 插件整体架构和设计说明
- **[API 接口](api.md)** - PVE API 接口设计和实现
- **[前端界面](ui.md)** - Web UI 界面开发说明

### 🔧 开发工具
- **[脚本工具](../scripts/)** - 脚本使用说明和工具文档
- **[模块化架构](../scripts/install/)** - 安装脚本模块化设计

## 🏗️ 系统架构

### 整体架构
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Proxmox VE   │    │   Clash.Meta    │    │   Management    │
│   Web UI       │◄──►│   (mihomo)      │◄──►│   Scripts       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PVE API      │    │   Network       │    │   Configuration │
│   Backend      │    │   Interface     │    │   Files         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 核心组件
- **PVE API 后端** - Perl 模块，提供 REST API 接口
- **Web UI 前端** - JavaScript 界面，集成到 Proxmox VE
- **Clash.Meta 内核** - mihomo 可执行文件，处理代理逻辑
- **管理脚本** - Bash 脚本，提供命令行管理功能
- **配置文件** - YAML 配置文件，定义代理规则和设置

## 🔧 开发环境

### 系统要求
- **操作系统**: Debian 11+ 或 Ubuntu 20.04+
- **Proxmox VE**: 7.0 或更高版本
- **开发工具**: Git, Make, Perl, Node.js
- **依赖包**: 见 `requirements.txt` 或 `Gemfile`

### 环境搭建
```bash
# 克隆仓库
git clone https://github.com/proxmox-libraries/proxmox-clash-plugin.git
cd proxmox-clash-plugin

# 安装依赖
sudo apt update
sudo apt install -y perl-modules libpve-common-perl

# 开发模式安装
sudo ./scripts/install/install.sh --dev
```

## 📝 代码结构

### 目录结构
```
proxmox-clash-plugin/
├── api/                    # PVE API 后端
│   └── Clash.pm          # 主要 API 模块
├── scripts/               # 管理脚本
│   ├── install/          # 安装脚本（模块化）
│   ├── management/       # 管理脚本
│   └── utils/            # 工具脚本
├── service/               # 服务配置
│   └── clash-meta.service
├── config/                # 配置文件
├── web-ui/                # Web 界面源码
└── docs/                  # 文档
```

### 模块化架构
安装脚本采用模块化设计，包含以下模块：
- **dependency_checker.sh** - 依赖检查
- **file_downloader.sh** - 文件下载
- **api_installer.sh** - API 安装
- **service_installer.sh** - 服务安装
- **config_creator.sh** - 配置创建
- **link_creator.sh** - 链接创建
- **result_display.sh** - 结果显示

## 🔌 API 开发

### PVE API 接口
插件提供以下 REST API 接口：

- `GET /api2/json/nodes/{node}/clash` - 获取状态
- `GET /api2/json/nodes/{node}/clash/proxies` - 获取代理列表
- `PUT /api2/json/nodes/{node}/clash/proxies/{name}` - 切换代理
- `POST /api2/json/nodes/{node}/clash/subscription/update` - 更新订阅
- `POST /api2/json/nodes/{node}/clash/setup-transparent-proxy` - 配置透明代理

### 开发指南
```perl
# 示例：添加新的 API 端点
sub handle_clash_status {
    my ($param) = @_;
    
    # 获取 Clash 状态
    my $status = get_clash_status();
    
    # 返回 JSON 响应
    return $status;
}
```

## 🎨 前端开发

### Web UI 组件
- **主控制面板** - 代理管理和状态监控
- **订阅管理** - 订阅更新和配置
- **透明代理** - 透明代理配置界面
- **日志查看** - 实时日志监控
- **版本管理** - 插件版本升级

### 技术栈
- **框架**: React + TypeScript
- **样式**: SCSS 模块化样式
- **状态管理**: Zustand
- **构建工具**: Vite
- **包管理**: npm/yarn

### 开发命令
```bash
# 进入前端目录
cd web-ui

# 安装依赖
npm install

# 开发模式
npm run dev

# 构建生产版本
npm run build

# 代码检查
npm run lint
```

## 🧪 测试

### 测试框架
- **单元测试**: Jest
- **集成测试**: 自定义测试脚本
- **模块测试**: `test_modules.sh`

### 运行测试
```bash
# 运行模块测试
sudo ./scripts/install/test_modules.sh

# 运行安装验证
sudo ./scripts/utils/verify_installation.sh

# 运行服务验证
sudo ./scripts/utils/service_validator.sh
```

## 📦 构建和发布

### 构建流程
```bash
# 构建前端
cd web-ui && npm run build

# 打包插件
make package

# 创建发布版本
make release
```

### 版本管理
- 使用语义化版本号 (SemVer)
- 自动生成 CHANGELOG
- GitHub Releases 集成
- 版本标签管理

## 🤝 贡献指南

### 开发流程
1. Fork 项目仓库
2. 创建功能分支
3. 提交代码变更
4. 创建 Pull Request
5. 代码审查和合并

### 代码规范
- **Perl**: 遵循 PVE 编码规范
- **JavaScript**: 使用 ESLint 和 Prettier
- **Bash**: 遵循 ShellCheck 建议
- **文档**: 使用 Markdown 格式

### 提交规范
```
feat: 添加新功能
fix: 修复 bug
docs: 更新文档
style: 代码格式调整
refactor: 代码重构
test: 添加测试
chore: 构建过程或辅助工具的变动
```

## 📚 相关文档

- **[使用方法](../usage.md)** - 详细的使用说明和操作指南
- **[API 接口](api.md)** - API 接口设计和实现
- **[系统架构](architecture.md)** - 插件整体架构说明
- **[前端界面](ui.md)** - Web UI 界面开发说明
- **[脚本工具](../scripts/)** - 脚本使用说明和工具文档

## 🔗 外部资源

- [Proxmox VE 开发文档](https://pve.proxmox.com/wiki/Developer_Documentation)
- [Clash.Meta 文档](https://docs.metacubex.one/)
- [React 官方文档](https://react.dev/)
- [TypeScript 官方文档](https://www.typescriptlang.org/)

---

*最后更新: 2024-12-19*
