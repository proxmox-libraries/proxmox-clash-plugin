#!/bin/bash

# 透明代理配置脚本
# 用于设置 iptables 规则，让 CT/VM 自动使用 Clash 代理

set -e

# 日志函数
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a /var/log/proxmox-clash.log
}

log_message "INFO" "开始配置透明代理..."

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    log_message "ERROR" "非root用户运行脚本"
    echo "❌ 请使用 root 用户运行此脚本"
    exit 1
fi

# 清除现有规则
log_message "INFO" "清除现有 iptables 规则..."
iptables -t nat -F PREROUTING 2>/dev/null || true
iptables -t mangle -F PREROUTING 2>/dev/null || true
log_message "DEBUG" "iptables 规则清除完成"

# 添加透明代理规则
log_message "INFO" "添加透明代理规则..."

# TCP 透明代理 (REDIRECT)
log_message "DEBUG" "添加 TCP 透明代理规则 (vmbr0, vmbr1 -> 7892)"
iptables -t nat -A PREROUTING -i vmbr0 -p tcp -j REDIRECT --to-ports 7892
iptables -t nat -A PREROUTING -i vmbr1 -p tcp -j REDIRECT --to-ports 7892

# UDP 透明代理 (TPROXY)
log_message "DEBUG" "添加 UDP 透明代理规则 (vmbr0, vmbr1 -> 7893)"
iptables -t mangle -A PREROUTING -i vmbr0 -p udp -j TPROXY --on-port 7893 --tproxy-mark 1
iptables -t mangle -A PREROUTING -i vmbr1 -p udp -j TPROXY --on-port 7893 --tproxy-mark 1

# 保存 iptables 规则
log_message "INFO" "保存 iptables 规则..."
if command -v iptables-save >/dev/null 2>&1; then
    if iptables-save > /etc/iptables/rules.v4 2>/dev/null; then
        log_message "INFO" "iptables 规则保存到 /etc/iptables/rules.v4"
    elif iptables-save > /etc/iptables.rules 2>/dev/null; then
        log_message "INFO" "iptables 规则保存到 /etc/iptables.rules"
    else
        log_message "WARN" "无法保存 iptables 规则，请手动保存"
        echo "⚠️  无法保存 iptables 规则，请手动保存"
    fi
else
    log_message "WARN" "iptables-save 命令不可用"
fi

log_message "INFO" "透明代理配置完成"
echo "✅ 透明代理配置完成！"
echo ""
echo "📋 配置信息："
echo "  - TCP 代理端口: 7892"
echo "  - UDP 代理端口: 7893"
echo "  - 影响的网桥: vmbr0, vmbr1"
echo ""
echo "🧪 测试方法："
echo "  在任意 CT/VM 中运行: curl -I https://www.google.com" 