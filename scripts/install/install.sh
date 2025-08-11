#!/bin/bash

# Proxmox Clash 插件模块化安装脚本
# 根据参数决定执行哪些安装步骤

set -e

# 配置变量
REPO_URL="https://github.com/proxmox-libraries/proxmox-clash-plugin"
INSTALL_DIR="/opt/proxmox-clash"

# 检查参数
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    # 显示帮助信息
    source "$(dirname "$0")/utils/argument_parser.sh"
    show_help
    exit 0
fi

# 加载工具模块
load_modules() {
    local script_dir="$(dirname "$0")"
    
    # 加载工具模块
    if [ -f "$script_dir/utils/logger.sh" ]; then
        source "$script_dir/utils/logger.sh"
    else
        echo "错误: 找不到日志模块: $script_dir/utils/logger.sh"
        exit 1
    fi
    
    if [ -f "$script_dir/utils/argument_parser.sh" ]; then
        source "$script_dir/utils/argument_parser.sh"
    else
        echo "错误: 找不到参数解析模块: $script_dir/utils/argument_parser.sh"
        exit 1
    fi
    
    if [ -f "$script_dir/utils/helpers.sh" ]; then
        source "$script_dir/utils/helpers.sh"
    else
        echo "错误: 找不到辅助函数模块: $script_dir/utils/helpers.sh"
        exit 1
    fi
    
    # 加载功能模块
    if [ -f "$script_dir/functions/dependency_checker.sh" ]; then
        source "$script_dir/functions/dependency_checker.sh"
    else
        echo "错误: 找不到依赖检查模块: $script_dir/functions/dependency_checker.sh"
        exit 1
    fi
    
    if [ -f "$script_dir/functions/file_downloader.sh" ]; then
        source "$script_dir/functions/file_downloader.sh"
    else
        echo "错误: 找不到文件下载模块: $script_dir/functions/file_downloader.sh"
        exit 1
    fi
    
    if [ -f "$script_dir/functions/api_installer.sh" ]; then
        source "$script_dir/functions/api_installer.sh"
    else
        echo "错误: 找不到API安装模块: $script_dir/functions/api_installer.sh"
        exit 1
    fi
    
    if [ -f "$script_dir/functions/service_installer.sh" ]; then
        source "$script_dir/functions/service_installer.sh"
    else
        echo "错误: 找不到服务安装模块: $script_dir/functions/service_installer.sh"
        exit 1
    fi
    
    if [ -f "$script_dir/functions/config_creator.sh" ]; then
        source "$script_dir/functions/config_creator.sh"
    else
        echo "错误: 找不到配置创建模块: $script_dir/functions/config_creator.sh"
        exit 1
    fi
    
    if [ -f "$script_dir/functions/link_creator.sh" ]; then
        source "$script_dir/functions/link_creator.sh"
    else
        echo "错误: 找不到链接创建模块: $script_dir/functions/link_creator.sh"
        exit 1
    fi
    
    if [ -f "$script_dir/functions/result_display.sh" ]; then
        source "$script_dir/functions/result_display.sh"
    else
        echo "错误: 找不到结果显示模块: $script_dir/functions/result_display.sh"
        exit 1
    fi
}

# 主函数
main() {
    echo "🚀 Proxmox Clash 插件模块化安装脚本"
    echo "======================================"
    
    # 加载所有模块
    load_modules
    
    # 解析参数
    parse_args "$@"
    
    # 显示配置
    show_config
    
    echo "开始执行安装步骤..."
    echo ""
    
    # 执行安装步骤
    local step_num=1
    
    # 步骤 1: 检查依赖
    if ! should_skip_step "dependencies"; then
        echo "步骤 $step_num: 检查依赖..."
        check_dependencies
        ((step_num++))
    else
        echo "步骤 $step_num: 跳过依赖检查..."
        ((step_num++))
    fi
    
    # 步骤 2: 下载文件
    if ! should_skip_step "download"; then
        echo "步骤 $step_num: 下载文件..."
        download_files
        ((step_num++))
    else
        echo "步骤 $step_num: 跳过文件下载..."
        ((step_num++))
    fi
    
    # 步骤 3: 安装 API
    if ! should_skip_step "api"; then
        echo "步骤 $step_num: 安装 API..."
        install_api
        ((step_num++))
    else
        echo "步骤 $step_num: 跳过 API 安装..."
        ((step_num++))
    fi
    
    # 步骤 4: 安装服务
    if ! should_skip_step "service"; then
        echo "步骤 $step_num: 安装服务..."
        install_service
        ((step_num++))
    else
        echo "步骤 $step_num: 跳过服务安装..."
        ((step_num++))
    fi
    
    # 步骤 5: 验证服务安装
    if ! should_skip_step "service"; then
        echo "步骤 $step_num: 验证服务安装..."
        verify_service_installation
        ((step_num++))
    else
        echo "步骤 $step_num: 跳过服务验证..."
        ((step_num++))
    fi
    
    # 步骤 6: 下载 mihomo
    if ! should_skip_step "mihomo"; then
        echo "步骤 $step_num: 下载 mihomo..."
        download_mihomo
        ((step_num++))
    else
        echo "步骤 $step_num: 跳过 mihomo 下载..."
        ((step_num++))
    fi
    
    # 步骤 7: 创建配置
    if ! should_skip_step "config"; then
        echo "步骤 $step_num: 创建配置..."
        create_config
        ((step_num++))
    else
        echo "步骤 $step_num: 跳过配置创建..."
        ((step_num++))
    fi
    
    # 步骤 8: 创建链接
    if ! should_skip_step "links"; then
        echo "步骤 $step_num: 创建链接..."
        create_links
        ((step_num++))
    else
        echo "步骤 $step_num: 跳过链接创建..."
        ((step_num++))
    fi
    
    # 步骤 9: 显示结果
    echo "步骤 $step_num: 显示结果..."
    show_result
    
    # 安装后验证
    if [ "$VERIFY_AFTER_INSTALL" = true ]; then
        echo ""
        log_step "运行安装后验证..."
        if [ -f "$INSTALL_DIR/scripts/utils/verify_installation.sh" ]; then
            "$INSTALL_DIR/scripts/utils/verify_installation.sh"
        else
            log_warn "⚠️  验证脚本不存在，跳过验证"
        fi
    fi
    
    echo ""
    echo "🎉 安装完成！"
}

# 运行主函数
main "$@"
