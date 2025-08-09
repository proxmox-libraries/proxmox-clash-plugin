#!/bin/bash

# Proxmox Clash 插件卸载脚本
set -e

CLASH_DIR="/opt/proxmox-clash"
API_DIR="/usr/share/perl5/PVE/API2"
# 自动检测 PVE UI 目录（PVE 8 使用 js，PVE 7 使用 ext6）
detect_pve_ui_dir() {
    if [ -d "/usr/share/pve-manager/js" ]; then
        echo "/usr/share/pve-manager/js"
        return 0
    fi
    if [ -d "/usr/share/pve-manager/ext6" ]; then
        echo "/usr/share/pve-manager/ext6"
        return 0
    fi
    echo ""
    return 1
}

UI_DIR="$(detect_pve_ui_dir)"

echo "🗑️ 开始卸载 Proxmox Clash 插件..."

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用 root 用户运行此脚本"
    exit 1
fi

# 停止服务
echo "🛑 停止 clash-meta 服务..."
systemctl stop clash-meta 2>/dev/null || true
systemctl disable clash-meta 2>/dev/null || true

# 删除服务文件
echo "🗑️ 删除 systemd 服务..."
rm -f /etc/systemd/system/clash-meta.service
systemctl daemon-reload

# 删除 API 插件
echo "🗑️ 删除 API 插件..."
rm -f "$API_DIR/Clash.pm"

# 删除前端插件
echo "🗑️ 删除前端插件..."
if [ -n "$UI_DIR" ]; then
    rm -f "$UI_DIR/pve-panel-clash.js"
else
    echo "⚠️  未找到 PVE UI 目录，跳过删除 UI 插件"
fi

# 删除主目录
echo "🗑️ 删除主目录..."
rm -rf "$CLASH_DIR"

# 清理日志文件
echo "🧹 清理日志文件..."
rm -f /var/log/proxmox-clash.log
rm -f /etc/logrotate.d/proxmox-clash

# 清理备份和版本文件
echo "🧹 清理备份和版本文件..."
rm -rf "$CLASH_DIR/backup"
rm -f "$CLASH_DIR/version"

# 清除 iptables 规则
echo "🧹 清除 iptables 规则..."
iptables -t nat -F PREROUTING 2>/dev/null || true
iptables -t mangle -F PREROUTING 2>/dev/null || true

# 保存清理后的 iptables 规则
if command -v iptables-save >/dev/null 2>&1; then
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || \
    iptables-save > /etc/iptables.rules 2>/dev/null || true
fi

echo "✅ 卸载完成！"
echo ""
echo "📝 注意事项："
echo "  - 请刷新 Proxmox Web UI 页面"
echo "  - 如果之前配置了透明代理，可能需要重启网络服务" 