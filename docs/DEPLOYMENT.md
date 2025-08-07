# 文档部署说明

本文档说明如何部署 Proxmox Clash 插件文档到 GitHub Pages。

## 🚀 自动部署

### GitHub Actions 自动部署

项目配置了 GitHub Actions 工作流，会自动构建和部署文档：

1. **触发条件**：
   - 推送到 `main` 或 `master` 分支
   - 修改 `docs/` 目录下的文件
   - 修改 `.github/workflows/docs.yml`

2. **部署流程**：
   - 自动构建 Jekyll 站点
   - 部署到 GitHub Pages
   - 在 PR 中自动评论预览链接

### 手动部署

如果需要手动部署，可以按以下步骤操作：

```bash
# 1. 安装依赖
cd docs
bundle install

# 2. 本地构建
bundle exec jekyll build

# 3. 本地预览
bundle exec jekyll serve
```

## 📋 部署配置

### GitHub Pages 设置

1. 进入仓库设置：`Settings` > `Pages`
2. 选择部署源：`Deploy from a branch`
3. 选择分支：`gh-pages`
4. 选择文件夹：`/(root)`
5. 点击 `Save`

### 自定义域名（可选）

如果需要使用自定义域名：

1. 在 `Settings` > `Pages` 中设置自定义域名
2. 在 `docs/CNAME` 文件中添加域名
3. 配置 DNS 记录指向 GitHub Pages

## 🔧 本地开发

### 环境要求

- Ruby 3.0+
- Bundler
- Jekyll 4.3+

### 本地开发步骤

```bash
# 1. 克隆仓库
git clone https://github.com/proxmox-libraries/proxmox-clash-plugin.git
cd proxmox-clash-plugin

# 2. 安装依赖
cd docs
bundle install

# 3. 启动本地服务器
bundle exec jekyll serve --livereload

# 4. 访问本地站点
# http://localhost:4000
```

### 开发工具

```bash
# 检查 Jekyll 配置
bundle exec jekyll doctor

# 构建站点
bundle exec jekyll build

# 清理构建文件
bundle exec jekyll clean
```

## 📁 文档结构

```
docs/
├── _config.yml              # Jekyll 配置
├── Gemfile                   # Ruby 依赖
├── README.md                 # 文档首页
├── installation/             # 安装指南
│   ├── README.md
│   ├── version-management.md
│   ├── upgrade.md
│   ├── service.md
│   └── clash-meta.md
├── configuration/            # 配置管理
│   ├── README.md
│   └── quick-start.md
├── api/                      # API 文档
│   └── README.md
├── ui/                       # Web UI 文档
│   └── README.md
├── scripts/                  # 脚本工具文档
│   └── README.md
├── development/              # 开发文档
│   └── README.md
└── troubleshooting/          # 故障排除
    └── README.md
```

## 🎨 主题定制

### 使用默认主题

项目使用 `jekyll-theme-cayman` 主题，配置在 `_config.yml` 中：

```yaml
theme: jekyll-theme-cayman
```

### 自定义主题

如需自定义主题：

1. 创建 `_layouts/` 目录
2. 创建 `_includes/` 目录
3. 创建 `assets/` 目录
4. 修改 `_config.yml` 中的主题设置

### 样式定制

```css
/* 在 assets/css/style.scss 中添加自定义样式 */
---
---

@import "{{ site.theme }}";

/* 自定义样式 */
.custom-class {
    color: #0366d6;
}
```

## 📝 内容管理

### 添加新页面

1. 在相应目录下创建 `.md` 文件
2. 添加 YAML 前置数据：

```yaml
---
layout: page
title: 页面标题
description: 页面描述
---

# 页面内容
```

### 更新导航

在 `_config.yml` 中更新导航配置：

```yaml
nav:
  - title: 新页面
    url: /new-page/
```

### 添加图片

1. 将图片放在 `assets/images/` 目录
2. 在 Markdown 中引用：

```markdown
![图片描述](/assets/images/image.png)
```

## 🔍 SEO 优化

### 元数据配置

在 `_config.yml` 中配置 SEO 信息：

```yaml
seo:
  title: Proxmox Clash 插件文档
  description: 深度集成到 Proxmox VE Web UI 的 Clash.Meta 原生插件
  author: Proxmox Libraries
  image: /images/logo.png
```

### 页面 SEO

在每个页面中添加 SEO 标签：

```yaml
---
layout: page
title: 页面标题
description: 页面描述
keywords: [关键词1, 关键词2]
---
```

## 🚨 故障排除

### 构建失败

```bash
# 检查 Jekyll 配置
bundle exec jekyll doctor

# 查看详细错误
bundle exec jekyll build --verbose

# 清理缓存
bundle exec jekyll clean
```

### 依赖问题

```bash
# 更新依赖
bundle update

# 重新安装依赖
bundle install --path vendor/bundle
```

### 本地服务器问题

```bash
# 指定端口
bundle exec jekyll serve --port 4001

# 绑定到所有接口
bundle exec jekyll serve --host 0.0.0.0
```

## 📚 相关资源

- [Jekyll 文档](https://jekyllrb.com/docs/)
- [GitHub Pages 文档](https://pages.github.com/)
- [Jekyll 主题](https://jekyllthemes.io/)
- [Markdown 语法](https://www.markdownguide.org/)

## 🔗 部署链接

- **生产环境**: https://proxmox-libraries.github.io/proxmox-clash-plugin/
- **GitHub 仓库**: https://github.com/proxmox-libraries/proxmox-clash-plugin
- **文档源码**: https://github.com/proxmox-libraries/proxmox-clash-plugin/tree/main/docs
