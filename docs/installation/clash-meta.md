# Clash-Meta 目录

这个目录用于存放 Clash.Meta (mihomo) 内核文件。

## 📁 目录用途

- 存放 mihomo 可执行文件
- 存放相关的内核文件
- 安装脚本会自动下载并放置 mihomo 内核到此目录

## 🔄 安装时的行为

当运行 `scripts/install.sh` 安装脚本时，会：

1. **下载 mihomo 内核**
   ```bash
   # 从 GitHub 下载最新的 mihomo 发布版本
   curl -L https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-amd64 \
     -o /opt/proxmox-clash/clash-meta/mihomo
   chmod +x /opt/proxmox-clash/clash-meta/mihomo
   ```

2. **配置服务**
   - systemd 服务会使用此目录中的 mihomo 内核
   - 配置文件指向此目录

## 📝 注意事项

- 此目录在安装前为空
- 安装脚本会自动下载并配置 mihomo 内核
- 不要手动删除此目录中的文件 