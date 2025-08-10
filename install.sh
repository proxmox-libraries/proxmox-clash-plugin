#!/bin/bash

# Proxmox Clash 插件一键安装脚本
# 自动下载并运行智能安装脚本

set -e

# 配置变量
GITHUB_REPO="proxmox-libraries/proxmox-clash-plugin"
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/$GITHUB_REPO/main/scripts/install/install_direct.sh"

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

# 显示欢迎信息
show_welcome() {
    echo ""
    echo "🎉 欢迎使用 Proxmox Clash 插件安装工具"
    echo "=========================================="
    echo ""
    echo "📋 功能特性:"
    echo "  ✅ 一键安装和配置"
    echo "  ✅ 智能版本管理"
    echo "  ✅ 透明代理支持"
    echo "  ✅ Web UI 管理界面"
    echo "  ✅ 自动服务管理"
    echo "  ✅ 配置文件备份"
    echo ""
    echo "📖 文档地址: https://proxmox-libraries.github.io/proxmox-clash-plugin/"
    echo ""
}

# 检查系统要求
check_system() {
    log_step "检查系统要求..."
    
    # 检查操作系统
    if [ ! -f /etc/debian_version ]; then
        log_error "此脚本仅支持 Debian/Ubuntu 系统"
        exit 1
    fi
    
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用 sudo 运行此脚本"
        exit 1
    fi
    
    # 检查网络连接
    if ! curl -s --connect-timeout 5 https://github.com >/dev/null; then
        log_error "无法连接到 GitHub，请检查网络连接"
        exit 1
    fi
    
    log_info "✅ 系统检查通过"
}

# 下载并运行安装脚本
download_and_run() {
    log_step "下载智能安装脚本..."
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    local install_script="$temp_dir/install_direct.sh"
    
    # 下载安装脚本
    if curl -sSL -o "$install_script" "$INSTALL_SCRIPT_URL"; then
        log_info "✅ 安装脚本下载成功"
    else
        log_error "❌ 安装脚本下载失败"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # 设置执行权限
    chmod +x "$install_script"
    
    # 运行安装脚本
    log_step "开始安装..."
    echo "执行安装脚本: $install_script"
    echo "传递参数: $*"
    
    if "$install_script" "$@"; then
        log_info "✅ 安装脚本执行成功"
    else
        local exit_code=$?
        log_error "❌ 安装脚本执行失败，退出码: $exit_code"
        log_error "请检查上面的错误信息"
        rm -rf "$temp_dir"
        exit $exit_code
    fi
    
    # 清理临时文件
    rm -rf "$temp_dir"
}

# 显示帮助信息
show_help() {
    echo "Proxmox Clash 插件一键安装工具"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -v, --version VERSION    安装指定版本"
    echo "  -l, --latest             安装最新版本"
    echo "  -b, --branch BRANCH      指定 Git 分支 (默认: main)"
    echo "  -c, --check              检查可用版本"
    echo "  -f, --force              强制重新下载"
    echo "  -h, --help               显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -l                     # 安装最新版本"
    echo "  $0 -v v1.1.0              # 安装指定版本"
    echo "  $0 -b main                # 从 main 分支安装最新版本"
    echo "  $0 -b develop             # 从 develop 分支安装最新版本"
    echo "  $0 -c                    # 检查可用版本"
    echo ""
    echo "🚀 一键安装最新版本:"
    echo "  curl -sSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | sudo bash -s -- -l"
    echo "🚀 从 main 分支安装:"
    echo "  curl -sSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | sudo bash -s -- -b main"
}

# 主函数
main() {
    # 显示欢迎信息
    show_welcome

    # 解析参数并规范化为 install_direct.sh 可识别的形式
    local normalized_version="latest"
    local branch_param=""
    local args=("$@")
    local i=0

    while [ $i -lt ${#args[@]} ]; do
        case "${args[$i]}" in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--latest)
                normalized_version="latest"
                ((i++))
                ;;
            -v|--version)
                if [ $((i+1)) -ge ${#args[@]} ]; then
                    log_error "必须在 -v/--version 后提供版本号，例如: -v v1.2.0"
                    exit 1
                fi
                normalized_version="${args[$((i+1))]}"
                ((i+=2))
                ;;
            -b|--branch)
                if [ $((i+1)) -ge ${#args[@]} ]; then
                    log_error "必须在 -b/--branch 后提供分支名称，例如: -b main"
                    exit 1
                fi
                branch_param="${args[$((i+1))]}"
                ((i+=2))
                ;;
            -c|--check)
                # 简易检查：列出 GitHub Releases 版本
                log_step "检查可用版本..."
                curl -s https://api.github.com/repos/$GITHUB_REPO/releases | jq -r '.[].tag_name' | grep -E '^v' | cat
                exit 0
                ;;
            *)
                # 兼容直接传入具体版本
                normalized_version="${args[$i]}"
                ((i++))
                ;;
        esac
    done

    # 检查系统要求
    check_system

    # 下载并运行安装脚本（传递版本和分支参数）
    if [ -n "$normalized_version" ] && [ -n "$branch_param" ]; then
        download_and_run "$normalized_version" "-b" "$branch_param"
    elif [ -n "$normalized_version" ]; then
        download_and_run "$normalized_version"
    elif [ -n "$branch_param" ]; then
        download_and_run "latest" "-b" "$branch_param"
    else
        download_and_run
    fi
}

# 运行主函数
main "$@"
