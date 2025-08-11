#!/bin/bash

# Proxmox Clash 插件服务安装修复脚本
# 用于检查和修复 clash-meta.service 安装问题

set -e

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

# 检查服务文件状态
check_service_status() {
    log_step "检查 clash-meta.service 状态..."
    
    # 检查源文件是否存在
    if [ ! -f "$SOURCE_SERVICE_FILE" ]; then
        log_error "源服务文件不存在: $SOURCE_SERVICE_FILE"
        return 1
    fi
    
    # 检查系统服务文件是否存在
    if [ ! -f "$SERVICE_FILE" ]; then
        log_warn "系统服务文件不存在: $SERVICE_FILE"
        return 1
    fi
    
    # 比较文件内容
    if diff "$SOURCE_SERVICE_FILE" "$SERVICE_FILE" >/dev/null 2>&1; then
        log_info "✅ 服务文件内容一致"
        return 0
    else
        log_warn "⚠️  服务文件内容不一致"
        return 1
    fi
}

# 修复服务文件
fix_service_file() {
    log_step "修复 clash-meta.service 文件..."
    
    # 备份当前系统服务文件
    if [ -f "$SERVICE_FILE" ]; then
        sudo cp "$SERVICE_FILE" "$SERVICE_FILE.backup.$(date +%s)"
        log_info "已备份当前服务文件"
    fi
    
    # 复制新的服务文件
    if sudo cp "$SOURCE_SERVICE_FILE" "$SERVICE_FILE"; then
        log_info "✅ 服务文件已更新"
        
        # 重新加载 systemd
        sudo systemctl daemon-reload
        log_info "✅ systemd 已重新加载"
        
        # 检查服务状态
        if systemctl is-enabled clash-meta >/dev/null 2>&1; then
            log_info "✅ 服务已启用"
        else
            log_warn "⚠️  服务未启用，正在启用..."
            sudo systemctl enable clash-meta
            log_info "✅ 服务已启用"
        fi
        
        return 0
    else
        log_error "❌ 服务文件更新失败"
        return 1
    fi
}

# 验证服务文件
verify_service_file() {
    log_step "验证服务文件..."
    
    # 检查文件权限
    if [ -f "$SERVICE_FILE" ]; then
        local perms=$(stat -c %a "$SERVICE_FILE")
        log_info "服务文件权限: $perms"
        
        # 检查文件内容
        if systemd-analyze verify "$SERVICE_FILE" >/dev/null 2>&1; then
            log_info "✅ 服务文件语法正确"
        else
            log_error "❌ 服务文件语法错误"
            return 1
        fi
        
        # 显示服务文件内容
        echo ""
        log_info "服务文件内容:"
        echo "===================="
        cat "$SERVICE_FILE"
        echo "===================="
        echo ""
        
        return 0
    else
        log_error "❌ 服务文件不存在"
        return 1
    fi
}

# 重启服务
restart_service() {
    log_step "重启 clash-meta 服务..."
    
    if systemctl is-active clash-meta >/dev/null 2>&1; then
        log_info "停止服务..."
        sudo systemctl stop clash-meta
        
        log_info "启动服务..."
        if sudo systemctl start clash-meta; then
            log_info "✅ 服务启动成功"
            
            # 等待服务稳定
            sleep 2
            
            # 检查服务状态
            if systemctl is-active clash-meta >/dev/null 2>&1; then
                log_info "✅ 服务运行正常"
                return 0
            else
                log_error "❌ 服务启动失败"
                return 1
            fi
        else
            log_error "❌ 服务启动失败"
            return 1
        fi
    else
        log_info "服务未运行，正在启动..."
        if sudo systemctl start clash-meta; then
            log_info "✅ 服务启动成功"
            return 0
        else
            log_error "❌ 服务启动失败"
            return 1
        fi
    fi
}

# 显示帮助信息
show_help() {
    echo "Proxmox Clash 插件服务安装修复工具"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -c, --check              检查服务文件状态"
    echo "  -f, --fix                修复服务文件问题"
    echo "  -v, --verify             验证服务文件"
    echo "  -r, --restart            重启服务"
    echo "  -a, --all                执行所有检查和修复操作"
    echo "  -h, --help               显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -c                     # 检查服务文件状态"
    echo "  $0 -f                     # 修复服务文件问题"
    echo "  $0 -a                     # 执行所有操作"
    echo ""
    echo "注意: 此脚本需要 sudo 权限"
}

# 主函数
main() {
    echo "🔧 Proxmox Clash 插件服务安装修复工具"
    echo "=========================================="
    echo ""
    
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用 sudo 运行此脚本"
        exit 1
    fi
    
    # 检查插件是否已安装
    if [ ! -d "$CLASH_DIR" ]; then
        log_error "插件未安装，请先运行安装脚本"
        exit 1
    fi
    
    # 解析参数
    local check_only=false
    local fix_service=false
    local verify_file=false
    local restart_service_flag=false
    local all_operations=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--check)
                check_only=true
                shift
                ;;
            -f|--fix)
                fix_service=true
                shift
                ;;
            -v|--verify)
                verify_file=true
                shift
                ;;
            -r|--restart)
                restart_service_flag=true
                shift
                ;;
            -a|--all)
                all_operations=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "❌ 未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 如果没有指定操作，显示帮助
    if [ "$check_only" = false ] && [ "$fix_service" = false ] && [ "$verify_file" = false ] && [ "$restart_service_flag" = false ] && [ "$all_operations" = false ]; then
        show_help
        exit 0
    fi
    
    # 执行操作
    local success=true
    
    if [ "$check_only" = true ] || [ "$all_operations" = true ]; then
        if ! check_service_status; then
            success=false
        fi
    fi
    
    if [ "$fix_service" = true ] || [ "$all_operations" = true ]; then
        if ! fix_service_file; then
            success=false
        fi
    fi
    
    if [ "$verify_file" = true ] || [ "$all_operations" = true ]; then
        if ! verify_service_file; then
            success=false
        fi
    fi
    
    if [ "$restart_service_flag" = true ] || [ "$all_operations" = true ]; then
        if ! restart_service; then
            success=false
        fi
    fi
    
    # 显示结果
    echo ""
    if [ "$success" = true ]; then
        log_info "🎉 所有操作完成成功！"
        echo ""
        echo "📋 后续操作建议："
        echo "  - 检查服务状态: systemctl status clash-meta"
        echo "  - 查看服务日志: journalctl -u clash-meta -f"
        echo "  - 测试服务功能: curl -s http://127.0.0.1:9092"
    else
        log_error "❌ 部分操作失败，请检查上面的错误信息"
        exit 1
    fi
}

# 运行主函数
main "$@"
