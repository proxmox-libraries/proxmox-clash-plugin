---
layout: page-with-sidebar
title: API 文档
---

# 🔌 API 文档

Proxmox Clash 插件提供了完整的 API 接口，用于管理和配置 Clash 服务。

## 📋 API 概览

### 基础信息
- **基础路径**: `/api2/json/nodes/{node}/clash`
- **认证方式**: Proxmox VE 标准认证
- **数据格式**: JSON
- **HTTP 方法**: GET, POST, PUT, DELETE

## 🔑 认证

所有 API 请求都需要通过 Proxmox VE 的认证系统：

```bash
# 使用 API Token
curl -H "Authorization: PVEAPIToken=user@pve!tokenid=tokenid" \
  https://your-pve-host:8006/api2/json/nodes/your-node/clash/status

# 使用用户名密码
curl -u username:password \
  https://your-pve-host:8006/api2/json/nodes/your-node/clash/status
```

## 📡 核心 API 接口

### 1. 服务状态

#### 获取服务状态
```http
GET /api2/json/nodes/{node}/clash/status
```

**响应示例：**
```json
{
  "data": {
    "status": "running",
    "uptime": "2h 30m 15s",
    "version": "1.18.0",
    "config_file": "/opt/proxmox-clash/config/config.yaml",
    "pid": 12345
  }
}
```

#### 启动服务
```http
POST /api2/json/nodes/{node}/clash/start
```

#### 停止服务
```http
POST /api2/json/nodes/{node}/clash/stop
```

#### 重启服务
```http
POST /api2/json/nodes/{node}/clash/restart
```

### 2. 配置管理

#### 获取当前配置
```http
GET /api2/json/nodes/{node}/clash/config
```

#### 更新配置
```http
POST /api2/json/nodes/{node}/clash/config
Content-Type: application/json

{
  "config": "base64_encoded_config_content"
}
```

#### 验证配置
```http
POST /api2/json/nodes/{node}/clash/config/validate
Content-Type: application/json

{
  "config": "base64_encoded_config_content"
}
```

### 3. 订阅管理

#### 获取订阅列表
```http
GET /api2/json/nodes/{node}/clash/subscriptions
```

#### 添加订阅
```http
POST /api2/json/nodes/{node}/clash/subscriptions
Content-Type: application/json

{
  "name": "my_subscription",
  "url": "https://example.com/subscription",
  "update_interval": 3600
}
```

#### 更新订阅
```http
POST /api2/json/nodes/{node}/clash/subscriptions/{id}/update
```

#### 删除订阅
```http
DELETE /api2/json/nodes/{node}/clash/subscriptions/{id}
```

### 4. 代理管理

#### 获取代理列表
```http
GET /api2/json/nodes/{node}/clash/proxies
```

#### 测试代理
```http
POST /api2/json/nodes/{node}/clash/proxies/test
Content-Type: application/json

{
  "proxy": "proxy_name",
  "url": "http://www.google.com/generate_204"
}
```

### 5. 规则管理

#### 获取规则列表
```http
GET /api2/json/nodes/{node}/clash/rules
```

#### 添加规则
```http
POST /api2/json/nodes/{node}/clash/rules
Content-Type: application/json

{
  "rule": "DOMAIN-SUFFIX,example.com,DIRECT"
}
```

## 📊 错误处理

### 错误响应格式
```json
{
  "errors": {
    "error": "错误描述",
    "code": 400
  }
}
```

### 常见错误码
- `400` - 请求参数错误
- `401` - 认证失败
- `403` - 权限不足
- `404` - 资源不存在
- `500` - 服务器内部错误

## 🔧 开发示例

### Python 示例
```python
import requests
import json

class ProxmoxClashAPI:
    def __init__(self, host, token):
        self.host = host
        self.headers = {'Authorization': f'PVEAPIToken={token}'}
    
    def get_status(self, node):
        url = f"{self.host}/api2/json/nodes/{node}/clash/status"
        response = requests.get(url, headers=self.headers, verify=False)
        return response.json()
    
    def start_service(self, node):
        url = f"{self.host}/api2/json/nodes/{node}/clash/start"
        response = requests.post(url, headers=self.headers, verify=False)
        return response.json()

# 使用示例
api = ProxmoxClashAPI('https://pve.example.com:8006', 'user@pve!tokenid=tokenid')
status = api.get_status('pve1')
print(status)
```

### JavaScript 示例
```javascript
class ProxmoxClashAPI {
    constructor(host, token) {
        this.host = host;
        this.headers = {
            'Authorization': `PVEAPIToken=${token}`,
            'Content-Type': 'application/json'
        };
    }
    
    async getStatus(node) {
        const response = await fetch(
            `${this.host}/api2/json/nodes/${node}/clash/status`,
            { headers: this.headers }
        );
        return await response.json();
    }
    
    async startService(node) {
        const response = await fetch(
            `${this.host}/api2/json/nodes/${node}/clash/start`,
            { 
                method: 'POST',
                headers: this.headers 
            }
        );
        return await response.json();
    }
}

// 使用示例
const api = new ProxmoxClashAPI('https://pve.example.com:8006', 'user@pve!tokenid=tokenid');
api.getStatus('pve1').then(status => console.log(status));
```

## 📝 最佳实践

1. **错误处理** - 始终检查响应状态和错误信息
2. **重试机制** - 对网络请求实现适当的重试逻辑
3. **缓存策略** - 缓存不经常变化的数据
4. **安全考虑** - 使用 HTTPS 和适当的认证方式
5. **日志记录** - 记录重要的 API 调用和错误信息

## 🔗 相关链接

- [Proxmox VE API 文档](https://pve.proxmox.com/pve-docs/api-viewer/)
- [Clash.Meta 文档](https://docs.metacubex.one/)
- [RESTful API 设计指南](https://restfulapi.net/)
