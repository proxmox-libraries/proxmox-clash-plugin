# API 目录

这个目录包含 Proxmox VE 的 API2 后端插件。

## 📁 目录内容

- `Clash.pm` - PVE API2 Clash 后端插件

## 🔧 功能说明

`Clash.pm` 是 Proxmox VE 的 API2 插件，提供以下功能：

### REST API 接口

- `GET /api2/json/nodes/{node}/clash` - 获取 Clash 状态
- `GET /api2/json/nodes/{node}/clash/proxies` - 获取代理列表
- `PUT /api2/json/nodes/{node}/clash/proxies/{name}` - 切换代理
- `GET /api2/json/nodes/{node}/clash/proxies/{name}/delay` - 测试延迟
- `PUT /api2/json/nodes/{node}/clash/configs/reload` - 重载配置
- `POST /api2/json/nodes/{node}/clash/subscription/update` - 更新订阅
- `POST /api2/json/nodes/{node}/clash/setup-transparent-proxy` - 配置透明代理
- `GET /api2/json/nodes/{node}/clash/traffic` - 获取流量统计
- `GET /api2/json/nodes/{node}/clash/logs` - 获取连接日志

## 📝 技术细节

- 使用 Perl 编写
- 继承自 `PVE::RESTHandler`
- 通过 HTTP 调用 Clash.Meta 的 REST API
- 支持权限控制和错误处理

## 🔄 安装位置

安装时会被复制到：`/usr/share/perl5/PVE/API2/Clash.pm` 