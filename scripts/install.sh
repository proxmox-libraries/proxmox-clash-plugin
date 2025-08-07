#!/bin/bash

# Proxmox Clash 插件安装脚本
set -e

# 日志函数
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a /var/log/proxmox-clash.log
}

CLASH_DIR="/opt/proxmox-clash"
API_DIR="/usr/share/perl5/PVE/API2"
UI_DIR="/usr/share/pve-manager/ext6"

log_message "INFO" "开始安装 Proxmox Clash 插件..."
echo "🚀 开始安装 Proxmox Clash 插件..."

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    log_message "ERROR" "非root用户运行安装脚本"
    echo "❌ 请使用 root 用户运行此脚本"
    exit 1
fi

# 创建目录结构
echo "📁 创建目录结构..."
mkdir -p "$CLASH_DIR"/{config,scripts,clash-meta}
mkdir -p "$API_DIR"
mkdir -p "$UI_DIR"

# 创建日志文件
echo "📝 创建日志文件..."
touch /var/log/proxmox-clash.log
chmod 644 /var/log/proxmox-clash.log

# 检查网络连接并建议镜像配置
echo "🌐 检查网络连接..."
if ! curl -s --connect-timeout 5 https://github.com > /dev/null 2>&1; then
    echo "⚠️  检测到 GitHub 访问较慢，建议配置镜像源："
    echo "   运行: bash scripts/setup_github_mirror.sh -m ghproxy"
    echo "   或者: bash scripts/setup_github_mirror.sh -c 检查可用镜像"
    echo ""
fi

# 下载 mihomo 内核
echo "⬇️ 下载 mihomo 内核..."
MIHOMO_URL="https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-amd64"
curl -L "$MIHOMO_URL" -o "$CLASH_DIR/clash-meta"
chmod +x "$CLASH_DIR/clash-meta"

# 创建必要的目录
echo "📁 创建必要目录..."
mkdir -p "$CLASH_DIR/config"
mkdir -p "$CLASH_DIR/scripts"
mkdir -p "$CLASH_DIR/clash-meta"

# 安装 API 插件
echo "🔌 安装 API 插件..."
cp api/Clash.pm "$API_DIR/"

# 安装前端插件
echo "🖥️ 安装前端插件..."
cp ui/pve-panel-clash.js "$UI_DIR/"

# 安装脚本
echo "📜 安装脚本..."
cp scripts/update_subscription.sh "$CLASH_DIR/scripts/"
cp scripts/view_logs.sh "$CLASH_DIR/scripts/"
cp scripts/upgrade.sh "$CLASH_DIR/scripts/"
chmod +x "$CLASH_DIR/scripts/update_subscription.sh"
chmod +x "$CLASH_DIR/scripts/view_logs.sh"
chmod +x "$CLASH_DIR/scripts/upgrade.sh"

# 安装 systemd 服务
echo "⚙️ 安装 systemd 服务..."
cp service/clash-meta.service /etc/systemd/system/
systemctl daemon-reload

# 安装 logrotate 配置
echo "📝 安装日志轮转配置..."
cp config/logrotate.conf /etc/logrotate.d/proxmox-clash

# 启用 IP 转发
echo "🌐 配置网络转发..."
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# 创建基础配置文件
echo "📝 创建基础配置..."
cat > "$CLASH_DIR/config/config.yaml" << 'EOF'
mixed-port: 7890
allow-lan: true
bind-address: '*'
mode: rule
log-level: info
external-controller: 127.0.0.1:9090
secret: ""
dns:
  enable: true
  listen: 0.0.0.0:53
  enhanced-mode: redir-host
  nameserver:
    - 223.5.5.5
    - 119.29.29.29
proxies: []
proxy-groups: []
rules:
  - DOMAIN-SUFFIX,google.com,Proxy
  - DOMAIN-SUFFIX,facebook.com,Proxy
  - DOMAIN-SUFFIX,youtube.com,Proxy
  - DOMAIN-SUFFIX,twitter.com,Proxy
  - DOMAIN-SUFFIX,github.com,Proxy
  - DOMAIN-SUFFIX,githubusercontent.com,Proxy
  - MATCH,DIRECT
EOF

# 设置权限
echo "🔐 设置权限..."
chown -R root:root "$CLASH_DIR"
chmod -R 755 "$CLASH_DIR"

# 创建版本文件
echo "📝 创建版本文件..."
if [ -f "$(dirname "$0")/version_manager.sh" ]; then
    PROJECT_VERSION=$("$(dirname "$0")/version_manager.sh" --latest 2>/dev/null || echo "1.0.0")
else
    PROJECT_VERSION="1.0.0"
fi
echo "$PROJECT_VERSION" > "$CLASH_DIR/version"
log_message "INFO" "插件版本: $PROJECT_VERSION"

# 启用并启动服务
echo "🚀 启动服务..."
systemctl enable clash-meta
systemctl start clash-meta

# 配置透明代理
echo "🔧 配置透明代理..."
cat > "$CLASH_DIR/scripts/setup_transparent_proxy.sh" << 'EOF'
#!/bin/bash
# 透明代理配置脚本

# 清除现有规则
iptables -t nat -F PREROUTING
iptables -t mangle -F PREROUTING

# 添加透明代理规则
iptables -t nat -A PREROUTING -i vmbr0 -p tcp -j REDIRECT --to-ports 7892
iptables -t nat -A PREROUTING -i vmbr1 -p tcp -j REDIRECT --to-ports 7892
iptables -t mangle -A PREROUTING -i vmbr0 -p udp -j TPROXY --on-port 7893 --tproxy-mark 1
iptables -t mangle -A PREROUTING -i vmbr1 -p udp -j TPROXY --on-port 7893 --tproxy-mark 1

echo "透明代理配置完成"
EOF

chmod +x "$CLASH_DIR/scripts/setup_transparent_proxy.sh"

echo "✅ 安装完成！"
echo ""
echo "📋 安装信息："
echo "  - Clash 目录: $CLASH_DIR"
echo "  - API 插件: $API_DIR/Clash.pm"
echo "  - UI 插件: $UI_DIR/pve-panel-clash.js"
echo "  - 服务状态: $(systemctl is-active clash-meta)"
echo ""
echo "🌐 访问方式："
echo "  - Proxmox Web UI: 刷新页面后查看数据中心 'Clash 控制' 菜单"
echo ""
echo "📝 下一步操作："
echo "  1. 刷新 Proxmox Web UI 页面"
echo "  2. 在 'Clash 控制' 菜单中添加订阅"
echo "  3. 运行透明代理配置: $CLASH_DIR/scripts/setup_transparent_proxy.sh" 