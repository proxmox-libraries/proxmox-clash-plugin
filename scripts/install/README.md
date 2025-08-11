# Proxmox Clash 插件模块化安装脚本

## 概述

本项目已将原来的单一 `install.sh` 脚本重构为模块化结构，提高了代码的可维护性、可读性和可重用性。

## 目录结构

```
scripts/install/
├── install.sh              # 原始安装脚本（保留兼容性）
├── install_new.sh          # 新的模块化安装脚本
├── README.md               # 本说明文件
├── utils/                  # 工具函数模块
│   ├── logger.sh          # 日志输出工具
│   ├── argument_parser.sh # 参数解析工具
│   └── helpers.sh         # 辅助函数工具
└── functions/              # 功能函数模块
    ├── dependency_checker.sh    # 依赖检查
    ├── file_downloader.sh       # 文件下载
    ├── api_installer.sh         # API安装
    ├── service_installer.sh     # 服务安装
    ├── config_creator.sh        # 配置创建
    ├── link_creator.sh          # 链接创建
    └── result_display.sh        # 结果显示
```

## 模块说明

### 工具模块 (utils/)

#### `logger.sh`
- 提供统一的日志输出格式
- 支持颜色输出和不同日志级别
- 包含进度显示功能

#### `argument_parser.sh`
- 处理命令行参数和选项
- 支持跳过特定安装步骤
- 提供详细的帮助信息

#### `helpers.sh`
- 系统检测和验证函数
- 文件操作辅助函数
- 服务管理辅助函数

### 功能模块 (functions/)

#### `dependency_checker.sh`
- 检查系统依赖
- 验证 PVE 环境
- 检查现有安装

#### `file_downloader.sh`
- 下载项目文件
- 下载 mihomo 可执行文件
- 支持版本和分支选择

#### `api_installer.sh`
- 安装 Proxmox API 模块
- 验证 API 安装
- 支持备份和恢复

#### `service_installer.sh`
- 安装和配置 systemd 服务
- 服务状态管理
- 集成服务验证

#### `config_creator.sh`
- 创建默认 Clash 配置
- 配置文件权限管理
- 支持配置备份

#### `link_creator.sh`
- 创建命令行工具链接
- 管理符号链接
- 支持链接备份

#### `result_display.sh`
- 显示安装结果
- 提供使用说明
- 显示管理命令

## 使用方法

### 基本安装
```bash
sudo ./install_new.sh
```

### 指定版本安装
```bash
sudo ./install_new.sh v1.2.0
```

### 跳过特定步骤
```bash
sudo ./install_new.sh --skip-step dependencies --skip-step download
```

### 启用调试模式
```bash
sudo ./install_new.sh --debug
```

### 显示帮助
```bash
./install_new.sh --help
```

## 优势

### 1. 模块化设计
- 每个功能独立成模块
- 便于单独测试和维护
- 支持选择性加载

### 2. 可重用性
- 工具函数可在其他脚本中使用
- 功能模块可独立调用
- 减少代码重复

### 3. 可维护性
- 代码结构清晰
- 职责分离明确
- 便于定位和修复问题

### 4. 可扩展性
- 易于添加新功能
- 支持插件式架构
- 模块间依赖关系清晰

### 5. 错误处理
- 统一的错误处理机制
- 详细的日志输出
- 支持跳过失败步骤

## 兼容性

- 新的模块化脚本完全兼容原有功能
- 支持所有原有的命令行参数
- 保持相同的安装流程和结果

## 迁移说明

### 从旧脚本迁移
1. 新脚本完全兼容，无需修改使用方式
2. 可以逐步迁移到新脚本
3. 旧脚本保留以确保向后兼容

### 开发新功能
1. 在相应的功能模块中添加新函数
2. 在主脚本中调用新功能
3. 遵循模块化设计原则

## 测试

### 单元测试
- 每个模块都可以独立测试
- 使用 `source` 命令加载模块进行测试

### 集成测试
- 运行完整的安装流程
- 验证所有模块的协同工作

## 贡献指南

1. 遵循现有的模块化结构
2. 在相应的模块中添加新功能
3. 保持模块间的低耦合
4. 添加适当的错误处理和日志
5. 更新相关文档

## 故障排除

### 常见问题
1. **模块加载失败**: 检查文件路径和权限
2. **函数未定义**: 确保模块已正确加载
3. **参数解析错误**: 检查参数格式和顺序

### 调试模式
使用 `--debug` 参数启用详细日志输出，帮助诊断问题。
