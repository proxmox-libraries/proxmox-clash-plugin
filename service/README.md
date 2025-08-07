# Service 目录

这个目录包含 systemd 服务配置文件。

## 📁 目录内容

- `clash-meta.service` - Clash.Meta systemd 服务文件

## 🔧 服务说明

`clash-meta.service` 是 Clash.Meta (mihomo) 的 systemd 服务配置文件，提供以下功能：

### 服务特性

- **自动启动** - 系统启动时自动启动服务
- **自动重启** - 服务异常时自动重启
- **权限控制** - 使用 root 用户运行
- **资源限制** - 设置文件描述符限制
- **安全设置** - 启用安全限制

### 配置参数

- **ExecStart**: `/opt/proxmox-clash/clash-meta -d /opt/proxmox-clash`
- **Restart**: `on-failure` (失败时重启)
- **User**: `root`
- **LimitNOFILE**: `infinity` (无限制文件描述符)

### 环境变量

- `CLASH_CONFIG_DIR=/opt/proxmox-clash/config`
- `CLASH_EXTERNAL_CONTROLLER=127.0.0.1:9090`

### 安全设置

- `NoNewPrivileges=true` - 禁止获取新权限
- `PrivateTmp=true` - 使用私有临时目录
- `ProtectSystem=strict` - 严格系统保护
- `ReadWritePaths=/opt/proxmox-clash` - 只允许访问指定路径

## 🔄 安装位置

安装时会被复制到：`/etc/systemd/system/clash-meta.service`

## 📝 管理命令

```bash
# 启用服务
sudo systemctl enable clash-meta

# 启动服务
sudo systemctl start clash-meta

# 停止服务
sudo systemctl stop clash-meta

# 重启服务
sudo systemctl restart clash-meta

# 查看状态
sudo systemctl status clash-meta

# 查看日志
sudo journalctl -u clash-meta -f
``` 