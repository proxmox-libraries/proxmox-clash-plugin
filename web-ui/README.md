# Proxmox Clash Plugin Web UI

这是Proxmox VE Clash插件的Web用户界面。

## 功能特性

- 强制使用本机地址：所有Clash API请求都会指向本机（127.0.0.1）而不是当前浏览器的主机
- 支持多种代理协议
- 实时连接监控
- 规则管理
- 配置管理

## 配置说明

### 强制使用本机地址

默认情况下，Web UI会强制所有API请求指向本机地址（127.0.0.1）。这确保了无论从哪个主机访问Web UI，都会连接到部署机器上的Clash服务。

#### 环境变量配置

你可以通过以下环境变量来自定义配置：

```bash
# 是否强制使用本机地址 (127.0.0.1)
# 设置为 true 时，所有API请求都会指向本机
VITE_FORCE_LOCALHOST=true

# 默认的Clash API端口
VITE_DEFAULT_CLASH_PORT=9090

# 默认的Clash API协议
VITE_DEFAULT_CLASH_PROTOCOL=http
```

#### 运行时配置

在Web UI中，你可以：

1. 在API配置页面选择"强制使用本机地址"选项
2. 手动输入API地址（会自动转换为127.0.0.1）
3. 配置Secret密钥

## 开发

### 安装依赖

```bash
npm install
```

### 开发模式

```bash
npm run dev
```

### 构建

```bash
npm run build
```

## 部署

构建完成后，`public` 目录包含所有静态文件，可以部署到任何Web服务器。

## 注意事项

- 强制使用本机地址功能确保安全性，防止API请求被重定向到其他主机
- 如果需要在不同网络环境下访问，请确保防火墙配置正确
- 建议在生产环境中使用HTTPS协议
