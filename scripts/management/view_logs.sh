#!/bin/bash

# 日志查看脚本
# 用法: ./view_logs.sh [选项]

set -e

# 日志文件路径
LOG_FILE="/var/log/proxmox-clash.log"
SERVICE_NAME="clash-meta"

# 显示帮助信息
show_help() {
    echo "Proxmox Clash 日志查看工具"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -f, --follow     实时跟踪日志"
    echo "  -n, --lines N    显示最后 N 行 (默认: 50)"
    echo "  -e, --error      只显示错误日志"
    echo "  -w, --warn       只显示警告和错误日志"
    echo "  -s, --service    显示 clash-meta 服务日志"
    echo "  -a, --all        显示所有相关日志"
    echo "  -c, --clear      清空日志文件"
    echo "  -h, --help       显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -f              # 实时跟踪日志"
    echo "  $0 -n 100          # 显示最后 100 行"
    echo "  $0 -e              # 只显示错误日志"
    echo "  $0 -s              # 显示服务日志"
    echo "  $0 -a              # 显示所有日志"
}

# 检查日志文件是否存在
check_log_file() {
    if [ ! -f "$LOG_FILE" ]; then
        echo "❌ 日志文件不存在: $LOG_FILE"
        echo "请先运行安装脚本或检查日志文件路径"
        exit 1
    fi
}

# 显示日志文件信息
show_log_info() {
    if [ -f "$LOG_FILE" ]; then
        local size=$(du -h "$LOG_FILE" | cut -f1)
        local lines=$(wc -l < "$LOG_FILE")
        local last_modified=$(stat -c %y "$LOG_FILE")
        echo "📊 日志文件信息:"
        echo "  文件: $LOG_FILE"
        echo "  大小: $size"
        echo "  行数: $lines"
        echo "  最后修改: $last_modified"
        echo ""
    fi
}

# 主函数
main() {
    local follow=false
    local lines=50
    local error_only=false
    local warn_only=false
    local service_log=false
    local all_logs=false
    local clear_log=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--follow)
                follow=true
                shift
                ;;
            -n|--lines)
                lines="$2"
                shift 2
                ;;
            -e|--error)
                error_only=true
                shift
                ;;
            -w|--warn)
                warn_only=true
                shift
                ;;
            -s|--service)
                service_log=true
                shift
                ;;
            -a|--all)
                all_logs=true
                shift
                ;;
            -c|--clear)
                clear_log=true
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
    
    # 清空日志
    if [ "$clear_log" = true ]; then
        if [ -f "$LOG_FILE" ]; then
            echo "🗑️  清空日志文件..."
            > "$LOG_FILE"
            echo "✅ 日志文件已清空"
        else
            echo "❌ 日志文件不存在"
        fi
        exit 0
    fi
    
    # 显示日志文件信息
    show_log_info
    
    # 显示服务日志
    if [ "$service_log" = true ]; then
        echo "📋 clash-meta 服务日志:"
        echo "=================================="
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            journalctl -u "$SERVICE_NAME" -n "$lines" --no-pager
        else
            echo "⚠️  $SERVICE_NAME 服务未运行"
        fi
        exit 0
    fi
    
    # 显示所有日志
    if [ "$all_logs" = true ]; then
        echo "📋 所有相关日志:"
        echo "=================================="
        echo "1. Proxmox Clash 插件日志:"
        echo "----------------------------------"
        if [ -f "$LOG_FILE" ]; then
            tail -n "$lines" "$LOG_FILE"
        else
            echo "日志文件不存在"
        fi
        echo ""
        echo "2. clash-meta 服务日志:"
        echo "----------------------------------"
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            journalctl -u "$SERVICE_NAME" -n "$lines" --no-pager
        else
            echo "服务未运行"
        fi
        exit 0
    fi
    
    # 检查日志文件
    check_log_file
    
    # 构建 tail 命令
    local tail_cmd="tail -n $lines"
    if [ "$follow" = true ]; then
        tail_cmd="$tail_cmd -f"
    fi
    
    # 构建 grep 命令
    local grep_cmd=""
    if [ "$error_only" = true ]; then
        grep_cmd="grep '\[ERROR\]'"
    elif [ "$warn_only" = true ]; then
        grep_cmd="grep '\[WARN\]\|\[ERROR\]'"
    fi
    
    # 执行命令
    if [ -n "$grep_cmd" ]; then
        echo "📋 过滤日志 (${grep_cmd}):"
        echo "=================================="
        eval "$tail_cmd '$LOG_FILE' | $grep_cmd"
    else
        echo "📋 Proxmox Clash 插件日志:"
        echo "=================================="
        eval "$tail_cmd '$LOG_FILE'"
    fi
}

# 运行主函数
main "$@" 