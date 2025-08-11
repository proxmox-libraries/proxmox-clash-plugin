#!/bin/bash

# Proxmox Clash 插件服务验证工具
# 提供可复用的服务验证函数

# 配置变量
CLASH_DIR="/opt/proxmox-clash"
SERVICE_FILE="/etc/systemd/system/clash-meta.service"
SOURCE_SERVICE_FILE="$CLASH_DIR/service/clash-meta.service"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 验证服务安装状态
verify_service_installation() {
    local source_file="${1:-$SOURCE_SERVICE_FILE}"
    local system_file="${2:-$SERVICE_FILE}"
    
    log_step "验证服务安装状态..."
    
    # 检查源文件是否存在
    if [ ! -f "$source_file" ]; then
        log_error "❌ 源服务文件不存在: $source_file"
        return 1
    fi
    
    # 检查系统服务文件是否存在
    if [ ! -f "$system_file" ]; then
        log_error "❌ 系统服务文件不存在: $system_file"
        return 1
    fi
    
    # 比较文件内容
    if diff "$source_file" "$system_file" >/dev/null 2>&1; then
        log_info "✅ 服务文件内容一致"
    else
        log_warn "⚠️  服务文件内容不一致，正在修复..."
        sudo cp "$source_file" "$system_file"
        sudo systemctl daemon-reload
        log_info "✅ 服务文件已修复"
    fi
    
    # 验证服务文件语法
    if systemd-analyze verify "$system_file" >/dev/null 2>&1; then
        log_info "✅ 服务文件语法正确"
    else
        log_error "❌ 服务文件语法错误"
        return 1
    fi
    
    # 检查服务是否已启用
    if systemctl is-enabled clash-meta >/dev/null 2>&1; then
        log_info "✅ 服务已启用"
    else
        log_warn "⚠️  服务未启用，正在启用..."
        sudo systemctl enable clash-meta
        log_info "✅ 服务已启用"
    fi
    
    log_info "✅ 服务安装验证完成"
    return 0
}

# 快速验证服务文件
quick_verify_service() {
    local source_file="${1:-$SOURCE_SERVICE_FILE}"
    local system_file="${2:-$SERVICE_FILE}"
    
    # 检查文件是否存在
    if [ ! -f "$source_file" ] || [ ! -f "$system_file" ]; then
        return 1
    fi
    
    # 检查文件内容是否一致
    if diff "$source_file" "$system_file" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 修复服务文件
fix_service_file() {
    local source_file="${1:-$SOURCE_SERVICE_FILE}"
    local system_file="${2:-$SERVICE_FILE}"
    
    log_step "修复服务文件..."
    
    # 备份当前系统服务文件
    if [ -f "$system_file" ]; then
        sudo cp "$system_file" "$system_file.backup.$(date +%s)"
        log_info "已备份当前服务文件"
    fi
    
    # 复制新的服务文件
    if sudo cp "$source_file" "$system_file"; then
        log_info "✅ 服务文件已更新"
        
        # 重新加载 systemd
        sudo systemctl daemon-reload
        log_info "✅ systemd 已重新加载"
        
        # 确保服务已启用
        if ! systemctl is-enabled clash-meta >/dev/null 2>&1; then
            sudo systemctl enable clash-meta
            log_info "✅ 服务已启用"
        fi
        
        return 0
    else
        log_error "❌ 服务文件更新失败"
        return 1
    fi
}

# 如果直接运行此脚本，显示帮助信息
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "🔧 Proxmox Clash 插件服务验证工具"
    echo "====================================="
    echo ""
    echo "此脚本提供可复用的服务验证函数，主要用于："
    echo "  - 安装脚本中的服务验证"
    echo "  - 升级脚本中的服务验证"
    echo "  - 其他脚本中的服务状态检查"
    echo ""
    echo "主要函数："
    echo "  - verify_service_installation: 完整验证服务安装"
    echo "  - quick_verify_service: 快速验证服务文件"
    echo "  - fix_service_file: 修复服务文件"
    echo ""
    echo "注意: 此脚本通常被其他脚本引用，不直接运行"
fi
