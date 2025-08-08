# 版本标签管理

本文档说明如何为 Proxmox Clash 插件创建和管理版本标签。

## 🏷️ 创建版本标签

### 1. 创建带注释的标签

```bash
# 创建 v1.2.0 标签
git tag -a v1.2.0 -m "Release v1.2.0: Security Enhancement Release"

# 推送标签到远程仓库
git push origin v1.2.0

# 推送所有标签
git push origin --tags
```

### 2. 创建轻量级标签

```bash
# 创建轻量级标签
git tag v1.2.0

# 推送标签
git push origin v1.2.0
```

## 📋 版本标签列表

### 当前版本标签

| 版本 | 标签 | 发布日期 | 主要特性 |
|------|------|----------|----------|
| v1.2.0 | `v1.2.0` | 2024-12-19 | 安全改进，透明代理默认关闭 |
| v1.1.0 | `v1.1.0` | 2024-12-01 | 版本管理，订阅功能 |
| v1.0.0 | `v1.0.0` | 2024-11-15 | 首次发布 |

### 创建命令历史

```bash
# v1.2.0 - Security Enhancement Release
git tag -a v1.2.0 -m "Release v1.2.0: Security Enhancement Release
- 透明代理默认关闭，提高安全性
- 新增 Web UI 透明代理控制
- 改进故障转移机制
- 完善文档和故障排除指南"

# v1.1.0 - Version Management Release
git tag -a v1.1.0 -m "Release v1.1.0: Version Management Release
- 添加版本管理功能
- 支持自动检测和升级
- 新增订阅管理功能
- 添加日志查看工具"

# v1.0.0 - Initial Release
git tag -a v1.0.0 -m "Release v1.0.0: Initial Release
- 基础 Clash.Meta 集成
- Proxmox Web UI 插件
- 透明代理支持
- 基础配置管理"
```

## 🔧 标签管理命令

### 查看标签

```bash
# 查看所有标签
git tag

# 查看标签详细信息
git show v1.2.0

# 查看标签列表（按时间排序）
git tag --sort=-version:refname

# 查看标签列表（按创建时间排序）
git tag --sort=-creatordate
```

### 删除标签

```bash
# 删除本地标签
git tag -d v1.2.0

# 删除远程标签
git push origin --delete v1.2.0
```

### 检出标签

```bash
# 检出特定版本
git checkout v1.2.0

# 创建基于标签的分支
git checkout -b release-v1.2.0 v1.2.0
```

## 📦 发布流程

### 1. 准备发布

```bash
# 确保代码已提交
git status

# 更新版本号（如果需要）
# 编辑相关文件中的版本信息

# 提交版本更新
git add .
git commit -m "Bump version to v1.2.0"
```

### 2. 创建标签

```bash
# 创建带注释的标签
git tag -a v1.2.0 -m "Release v1.2.0: Security Enhancement Release"

# 推送标签
git push origin v1.2.0
```

### 3. 创建 GitHub Release

1. 访问 GitHub 仓库的 Releases 页面
2. 点击 "Create a new release"
3. 选择刚创建的标签 `v1.2.0`
4. 填写发布标题和描述
5. 上传发布文件（如果需要）
6. 发布

### 4. 发布后操作

```bash
# 更新主分支（如果需要）
git checkout main
git merge v1.2.0

# 推送更新
git push origin main
```

## 🏷️ 版本命名规范

### 语义化版本

遵循 [Semantic Versioning](https://semver.org/) 规范：

- **主版本号** (Major): 不兼容的 API 修改
- **次版本号** (Minor): 向下兼容的功能性新增
- **修订版本号** (Patch): 向下兼容的问题修正

### 版本号示例

- `v1.2.0` - 次版本更新，新功能
- `v1.2.1` - 修订版本，问题修复
- `v2.0.0` - 主版本更新，重大变更

### 预发布版本

- `v1.2.0-alpha.1` - Alpha 版本
- `v1.2.0-beta.1` - Beta 版本
- `v1.2.0-rc.1` - Release Candidate

## 📝 标签消息格式

### 标准格式

```
Release v1.2.0: Security Enhancement Release

主要改进：
- 透明代理默认关闭，提高安全性
- 新增 Web UI 透明代理控制
- 改进故障转移机制
- 完善文档和故障排除指南

详细更新请查看 [发布说明](../releases/)
```

### 简洁格式

```
Release v1.2.0: Security Enhancement Release
- 透明代理默认关闭
- 新增 Web UI 控制
- 改进故障转移
- 完善文档
```

## 🔗 相关链接

- [Git 标签文档](https://git-scm.com/book/en/v2/Git-Basics-Tagging)
- [语义化版本规范](https://semver.org/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [发布说明](../releases/)
- [发布说明](../releases/release-notes-v1.2.0.md)

---

**注意**: 创建标签前请确保代码已充分测试，并且文档已更新完成。
