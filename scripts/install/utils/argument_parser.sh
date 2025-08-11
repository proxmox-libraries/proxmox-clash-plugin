#!/bin/bash

# 参数解析工具模块
# 处理命令行参数和选项

# 全局变量
VERSION="latest"
BRANCH="main"
KERNEL_VARIANT="v1"
VERIFY_AFTER_INSTALL=false
SKIP_STEPS=()

# 参数解析函数
parse_args() {
    local args=("$@")
    local i=0
    
    log_debug "开始解析参数，参数数量: ${#args[@]}"
    log_debug "参数列表: ${args[*]}"

    while [ $i -lt ${#args[@]} ]; do
        log_debug "处理参数 $i: ${args[$i]}"
        case "${args[$i]}" in
            -l|--latest)
                VERSION="latest"
                log_debug "设置版本为 latest"
                ((i++))
                ;;
            -v|--version)
                if [ $((i+1)) -ge ${#args[@]} ]; then
                    log_error "必须在 -v/--version 后提供版本号，例如: -v v1.2.0"
                    exit 1
                fi
                VERSION="${args[$((i+1))]}"
                log_debug "设置版本为 $VERSION"
                ((i+=2))
                ;;
            -b|--branch)
                if [ $((i+1)) -ge ${#args[@]} ]; then
                    log_error "必须在 -b/--branch 后提供分支名称，例如: -b main"
                    exit 1
                fi
                BRANCH="${args[$((i+1))]}"
                log_debug "设置分支为 $BRANCH"
                ((i+=2))
                ;;
            --kernel-variant|--variant)
                if [ $((i+1)) -ge ${#args[@]} ]; then
                    log_error "必须在 --kernel-variant 后提供变体：v1|v2|v3|compatible|auto"
                    exit 1
                fi
                case "${args[$((i+1))]}" in
                    v1|v2|v3|compatible|auto) KERNEL_VARIANT="${args[$((i+1))]}" ;;
                    *) log_error "无效的变体：${args[$((i+1))]}（可选：v1|v2|v3|compatible|auto）"; exit 1 ;;
                esac
                log_debug "设置内核变体为 $KERNEL_VARIANT"
                ((i+=2))
                ;;
            --verify)
                VERIFY_AFTER_INSTALL=true
                log_debug "启用安装后验证"
                ((i++))
                ;;
            --no-verify)
                VERIFY_AFTER_INSTALL=false
                log_debug "禁用安装后验证"
                ((i++))
                ;;
            --skip-step)
                if [ $((i+1)) -ge ${#args[@]} ]; then
                    log_error "必须在 --skip-step 后提供步骤名称"
                    exit 1
                fi
                SKIP_STEPS+=("${args[$((i+1))]}")
                log_debug "跳过步骤: ${args[$((i+1))]}"
                ((i+=2))
                ;;
            --debug)
                DEBUG=true
                log_debug "启用调试模式"
                ((i++))
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                # 兼容直接传入版本字符串
                VERSION="${args[$i]}"
                log_debug "直接设置版本为 $VERSION"
                ((i++))
                ;;
        esac
    done
    
    log_debug "参数解析完成"
    log_debug "最终版本: $VERSION"
    log_debug "最终分支: $BRANCH"
    log_debug "最终内核变体: $KERNEL_VARIANT"
    log_debug "最终验证设置: $VERIFY_AFTER_INSTALL"
    log_debug "跳过的步骤: ${SKIP_STEPS[*]}"
}

# 检查是否跳过某个步骤
should_skip_step() {
    local step_name="$1"
    for step in "${SKIP_STEPS[@]}"; do
        if [ "$step" = "$step_name" ]; then
            return 0  # 应该跳过
        fi
    done
    return 1  # 不应该跳过
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [版本] [选项]"
    echo ""
    echo "参数:"
    echo "  版本    指定安装版本 (默认: latest)"
    echo ""
    echo "选项:"
    echo "  -l, --latest          安装最新版本 (默认)"
    echo "  -v, --version VERSION 安装指定版本"
    echo "  -b, --branch BRANCH   指定 Git 分支 (默认: main)"
    echo "  --kernel-variant VAR  指定内核变体: v1|v2|v3|compatible|auto (默认: v1)"
    echo "  --verify              安装完成后自动运行验证"
    echo "  --no-verify           跳过安装后验证 (默认)"
    echo "  --skip-step STEP      跳过指定步骤 (可多次使用)"
    echo "  --debug               启用调试模式"
    echo "  -h, --help            显示此帮助信息"
    echo ""
    echo "可跳过的步骤:"
    echo "  dependencies   依赖检查"
    echo "  download      文件下载"
    echo "  api          API安装"
    echo "  service      服务安装"
    echo "  mihomo       mihomo下载"
    echo "  config       配置创建"
    echo "  links        链接创建"
    echo ""
    echo "示例:"
    echo "  $0                           # 安装最新版本"
    echo "  $0 v1.1.0                    # 安装指定版本"
    echo "  $0 -b main                   # 从 main 分支安装最新版本"
    echo "  $0 -b develop                # 从 develop 分支安装最新版本"
    echo "  $0 --verify                  # 安装最新版本并验证"
    echo "  $0 v1.1.0 --verify          # 安装指定版本并验证"
    echo "  $0 --skip-step dependencies # 跳过依赖检查"
    echo "  $0 --debug                   # 启用调试模式"
    echo ""
    echo "注意: 此脚本需要 sudo 权限"
}

# 显示当前配置
show_config() {
    echo "🚀 Proxmox Clash 插件安装配置"
    echo "=================================="
    echo "版本: $VERSION"
    echo "分支: $BRANCH"
    echo "内核变体: $KERNEL_VARIANT"
    echo "安装后验证: $([ "$VERIFY_AFTER_INSTALL" = true ] && echo "是" || echo "否")"
    if [ ${#SKIP_STEPS[@]} -gt 0 ]; then
        echo "跳过的步骤: ${SKIP_STEPS[*]}"
    fi
    echo ""
}
