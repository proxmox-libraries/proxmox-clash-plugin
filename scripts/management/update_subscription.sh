#!/bin/bash

# 订阅更新脚本
# 用法: ./update_subscription.sh <订阅URL> [配置名称]

set -e

# 日志函数
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a /var/log/proxmox-clash.log
}

SUBSCRIPTION_URL="$1"
CONFIG_NAME="${2:-config.yaml}"
CLASH_DIR="/opt/proxmox-clash"
CONFIG_DIR="$CLASH_DIR/config"
TEMP_DIR="/tmp/clash_subscription"

log_message "INFO" "开始更新订阅: URL=$SUBSCRIPTION_URL, 配置名称=$CONFIG_NAME"

if [ -z "$SUBSCRIPTION_URL" ]; then
    log_message "ERROR" "未提供订阅URL"
    echo "错误: 请提供订阅URL"
    echo "用法: $0 <订阅URL> [配置名称]"
    exit 1
fi

log_message "INFO" "开始更新订阅: $SUBSCRIPTION_URL"

# 创建临时目录
log_message "DEBUG" "创建临时目录: $TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# 下载订阅内容
log_message "INFO" "下载订阅内容..."
if [[ "$SUBSCRIPTION_URL" =~ ^https?:// ]]; then
    # HTTP/HTTPS 订阅
    log_message "DEBUG" "从URL下载订阅: $SUBSCRIPTION_URL"
    curl -s -L "$SUBSCRIPTION_URL" -o subscription.txt
else
    # 本地文件
    log_message "DEBUG" "从本地文件复制订阅: $SUBSCRIPTION_URL"
    cp "$SUBSCRIPTION_URL" subscription.txt
fi

# 检查是否为 base64 编码
if grep -q "^vmess://\|^vless://\|^trojan://\|^ss://" subscription.txt; then
    log_message "INFO" "检测到明文订阅，直接使用..."
    cp subscription.txt "$CONFIG_DIR/$CONFIG_NAME"
else
    log_message "INFO" "检测到 base64 编码订阅，正在解码..."
    base64 -d subscription.txt > decoded.txt
    
    # 检查解码后的内容
    if grep -q "^vmess://\|^vless://\|^trojan://\|^ss://" decoded.txt; then
        log_message "DEBUG" "base64解码成功"
        cp decoded.txt "$CONFIG_DIR/$CONFIG_NAME"
    else
        log_message "ERROR" "无法解析订阅格式"
        echo "错误: 无法解析订阅格式"
        exit 1
    fi
fi

# 清理临时文件
log_message "DEBUG" "清理临时目录: $TEMP_DIR"
rm -rf "$TEMP_DIR"

log_message "INFO" "订阅更新完成: $CONFIG_DIR/$CONFIG_NAME"

# 重启 clash 服务
if systemctl is-active --quiet clash-meta; then
    log_message "INFO" "重启 clash-meta 服务..."
    systemctl restart clash-meta
    log_message "INFO" "clash-meta 服务重启完成"
else
    log_message "WARN" "clash-meta 服务未运行，跳过重启"
fi

log_message "INFO" "订阅更新成功完成"
echo "✅ 订阅更新成功！" 