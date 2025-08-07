#!/bin/bash

# Proxmox Clash 插件安装脚本（带版本管理）
# 结合 GitHub 版本管理进行安装

set -e

# 配置变量
CLASH_DIR="/opt/proxmox-clash"
API_DIR="/usr/share/perl5/PVE/API2"
UI_DIR="/usr/share/pve-manager/ext6"
GITHUB_REPO="proxmox-libraries/proxmox-clash-plugin"

# 日志函数
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a /var/log/proxmox-clash.log
}

# 显示帮助信息
show_help() {
    echo "Proxmox Clash 插件安装工具（带版本管理）"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -v, --version VERSION    安装指定版本"
    echo "  -l, --latest             安装最新版本"
    echo "  -c, --check              检查可用版本"
    echo "  -h, --help               显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -l                     # 安装最新版本"
    echo "  $0 -v v1.1.0              # 安装指定版本"
    echo "  $0 -c                    # 检查可用版本"
}

# 检查依赖
check_dependencies() {
    log_message "INFO" "检查系统依赖..."
    
    local missing_deps=()
    
    # 检查必要的命令
    for cmd in curl wget jq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "❌ 缺少必要的依赖: ${missing_deps[*]}"
        echo "请安装以下包:"
        echo "  apt-get update && apt-get install -y ${missing_deps[*]}"
        exit 1
    fi
    
    log_message "INFO" "依赖检查完成"
}

# 获取可用版本列表
get_available_versions() {
    if [ -f "$(dirname "$0")/version_manager.sh" ]; then
        "$(dirname "$0")/version_manager.sh" --all
    else
        echo "版本管理脚本不可用"
        exit 1
    fi
}

# 下载指定版本
download_version() {
    local version="$1"
    local download_url="https://github.com/$GITHUB_REPO/archive/refs/tags/$version.tar.gz"
    local temp_dir=$(mktemp -d)
    local archive_file="$temp_dir/proxmox-clash-plugin-$version.tar.gz"
    
    log_message "INFO" "下载版本 $version..."
    
    if ! curl -L -o "$archive_file" "$download_url"; then
        log_message "ERROR" "下载失败: $download_url"
        rm -rf "$temp_dir"
        return 1
    fi
    
    log_message "INFO" "解压文件..."
    tar -xzf "$archive_file" -C "$temp_dir"
    
    local extracted_dir="$temp_dir/proxmox-clash-plugin-${version#v}"
    
    if [ ! -d "$extracted_dir" ]; then
        log_message "ERROR" "解压后的目录不存在: $extracted_dir"
        rm -rf "$temp_dir"
        return 1
    fi
    
    echo "$extracted_dir"
}

# 安装插件
install_plugin() {
    local source_dir="$1"
    local version="$2"
    
    log_message "INFO" "开始安装 Proxmox Clash 插件..."
    
    # 创建必要的目录
    mkdir -p "$CLASH_DIR"
    mkdir -p "$API_DIR"
    mkdir -p "$UI_DIR"
    
    # 复制文件
    log_message "INFO" "复制 API 文件..."
    cp -r "$source_dir/api/"* "$API_DIR/" 2>/dev/null || true
    
    log_message "INFO" "复制 UI 文件..."
    cp -r "$source_dir/ui/"* "$UI_DIR/" 2>/dev/null || true
    
    log_message "INFO" "复制配置文件..."
    cp -r "$source_dir/config/"* "$CLASH_DIR/" 2>/dev/null || true
    
    log_message "INFO" "复制服务文件..."
    cp -r "$source_dir/service/"* "$CLASH_DIR/" 2>/dev/null || true
    
    log_message "INFO" "复制脚本文件..."
    cp -r "$source_dir/scripts/"* "$CLASH_DIR/" 2>/dev/null || true
    
    # 设置权限
    chmod +x "$CLASH_DIR"/*.sh 2>/dev/null || true
    chmod +x "$CLASH_DIR/scripts"/*.sh 2>/dev/null || true
    
    # 设置版本
    if [ -f "$(dirname "$0")/version_manager.sh" ]; then
        "$(dirname "$0")/version_manager.sh" --set "$version"
    else
        echo "$version" > "$CLASH_DIR/version"
    fi
    
    log_message "INFO" "安装完成！版本: $version"
}

# 安装最新版本
install_latest() {
    log_message "INFO" "获取最新版本..."
    
    if [ -f "$(dirname "$0")/version_manager.sh" ]; then
        local latest_version=$("$(dirname "$0")/version_manager.sh" --latest)
        if [ "$latest_version" = "unknown" ]; then
            log_message "ERROR" "无法获取最新版本"
            exit 1
        fi
        
        log_message "INFO" "最新版本: $latest_version"
        install_specific_version "$latest_version"
    else
        log_message "ERROR" "版本管理脚本不可用"
        exit 1
    fi
}

# 安装指定版本
install_specific_version() {
    local version="$1"
    
    log_message "INFO" "安装版本: $version"
    
    # 下载版本
    local source_dir=$(download_version "$version")
    if [ $? -ne 0 ]; then
        log_message "ERROR" "下载版本失败"
        exit 1
    fi
    
    # 安装插件
    install_plugin "$source_dir" "$version"
    
    # 清理临时文件
    rm -rf "$(dirname "$source_dir")"
    
    log_message "INFO" "版本 $version 安装完成！"
}

# 主函数
main() {
    case "${1:-}" in
        -v|--version)
            if [ -z "$2" ]; then
                echo "错误: 请指定版本号"
                exit 1
            fi
            check_dependencies
            install_specific_version "$2"
            ;;
        -l|--latest)
            check_dependencies
            install_latest
            ;;
        -c|--check)
            get_available_versions
            ;;
        -h|--help|"")
            show_help
            ;;
        *)
            echo "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
