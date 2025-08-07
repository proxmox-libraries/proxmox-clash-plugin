# GitHub 镜像配置指南

本指南将帮助中国大陆用户解决 GitHub 访问慢的问题，通过配置镜像源来加速代码下载和依赖安装。

## 🌐 问题背景

在中国大陆使用 GitHub 时，经常会遇到以下问题：
- 代码克隆速度慢
- 依赖下载超时
- 版本管理脚本无法获取最新版本
- 安装过程中断

## 🛠️ 解决方案

### 1. 自动检测网络状态

```bash
# 检查当前网络连接状态
bash scripts/setup_github_mirror.sh -c
```

### 2. 配置镜像源

#### 推荐方案：ghproxy

```bash
# 设置 ghproxy 镜像（推荐）
bash scripts/setup_github_mirror.sh -m ghproxy
```

#### 备选方案

```bash
# 设置 fastgit 镜像
bash scripts/setup_github_mirror.sh -m fastgit

# 设置 cnpmjs 镜像
bash scripts/setup_github_mirror.sh -m cnpmjs
```

### 3. 重置配置

```bash
# 重置为原始 GitHub 地址
bash scripts/setup_github_mirror.sh -r
```

## 📋 支持的镜像源

| 镜像源 | 地址 | 特点 | 推荐度 |
|--------|------|------|--------|
| ghproxy | https://ghproxy.com/ | 稳定、速度快 | ⭐⭐⭐⭐⭐ |
| fastgit | https://download.fastgit.org/ | 速度快、支持大文件 | ⭐⭐⭐⭐ |
| cnpmjs | https://github.com.cnpmjs.org/ | 稳定、支持完整镜像 | ⭐⭐⭐ |

## 🔧 配置内容

脚本会自动配置以下内容：

### Git 配置
- 设置 Git 全局镜像地址
- 支持 `git clone` 和 `git pull` 加速

### npm 配置
- 设置 npm 镜像源为淘宝镜像
- 加速 Node.js 依赖下载

### pip 配置
- 设置 pip 镜像源为清华镜像
- 加速 Python 依赖下载

### gem 配置
- 设置 gem 镜像源为 Ruby China
- 加速 Ruby 依赖下载

## 📝 使用示例

### 完整安装流程

```bash
# 1. 检查网络状态
bash scripts/setup_github_mirror.sh -c

# 2. 配置镜像源
bash scripts/setup_github_mirror.sh -m ghproxy

# 3. 安装插件
sudo bash scripts/install.sh

# 4. 或使用版本管理安装
sudo bash scripts/install_with_version.sh -l
```

### 版本管理使用

```bash
# 配置镜像后，版本管理脚本会自动使用镜像
sudo /opt/proxmox-clash/scripts/version_manager.sh -l
sudo /opt/proxmox-clash/scripts/version_manager.sh -u
```

## ⚠️ 注意事项

1. **权限要求**：脚本需要修改全局 Git 配置，建议使用普通用户运行
2. **网络环境**：不同网络环境下镜像源效果可能不同，建议先测试
3. **安全性**：使用第三方镜像源时，请确保来源可信
4. **兼容性**：某些高级 Git 功能可能在镜像源下不可用

## 🔍 故障排除

### 镜像源无法访问

```bash
# 检查镜像源状态
curl -I https://ghproxy.com/
curl -I https://download.fastgit.org/

# 尝试其他镜像源
bash scripts/setup_github_mirror.sh -m fastgit
```

### Git 配置冲突

```bash
# 查看当前 Git 配置
git config --global --list | grep url

# 重置配置
bash scripts/setup_github_mirror.sh -r
```

### 依赖下载失败

```bash
# 检查 npm 配置
npm config list

# 检查 pip 配置
pip config list

# 手动设置镜像
npm config set registry https://registry.npmmirror.com/
```

## 📚 相关链接

- [ghproxy 官方文档](https://ghproxy.com/)
- [fastgit 项目](https://github.com/fastgh/fastgit)
- [cnpmjs 镜像](https://github.com/cnpm/cnpmjs.org)
- [淘宝 npm 镜像](https://npmmirror.com/)
- [清华 pip 镜像](https://pypi.tuna.tsinghua.edu.cn/)
- [Ruby China gems 镜像](https://gems.ruby-china.com/)

## 🤝 贡献

如果您发现更好的镜像源或有改进建议，欢迎提交 Issue 或 Pull Request。
