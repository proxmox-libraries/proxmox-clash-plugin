#!/bin/bash

# Proxmox Clash 插件升级脚本
# 用法: ./upgrade.sh [目标版本]

set -e

# 日志函数
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a /var/log/proxmox-clash.log
}

# 配置变量
CLASH_DIR="/opt/proxmox-clash"
API_DIR="/usr/share/perl5/PVE/API2"
# 自动检测 PVE UI 目录（已移除Web UI功能）
detect_pve_ui_dir() {
    echo ""
    return 1
}

UI_DIR="$(detect_pve_ui_dir)"
BACKUP_DIR="/opt/proxmox-clash/backup"
CURRENT_VERSION_FILE="$CLASH_DIR/version"
GITHUB_REPO="proxmox-libraries/proxmox-clash-plugin"
GITHUB_API="https://api.github.com/repos/$GITHUB_REPO/releases/latest"

# 显示帮助信息
show_help() {
    echo "Proxmox Clash 插件升级工具"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -v, --version VERSION    升级到指定版本"
    echo "  -l, --latest             升级到最新版本"
    echo "  -c, --check              检查可用更新"
    echo "  -b, --backup             创建备份"
    echo "  -r, --restore            从备份恢复"
    echo "  -h, --help               显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -l                     # 升级到最新版本"
    echo "  $0 -v 1.1.0              # 升级到指定版本"
    echo "  $0 -c                    # 检查更新"
    echo "  $0 -b                    # 创建备份"
}

# 获取当前版本
get_current_version() {
    if [ -f "$CURRENT_VERSION_FILE" ]; then
        cat "$CURRENT_VERSION_FILE"
    else
        echo "unknown"
    fi
}



# 获取最新版本
get_latest_version() {
    # 使用版本管理脚本获取最新版本
    if [ -f "$(dirname "$0")/version_manager.sh" ]; then
        local latest_version=$("$(dirname "$0")/version_manager.sh" --latest)
        if [ "$latest_version" != "unknown" ]; then
            echo "$latest_version"
            return 0
        fi
    fi
    
    # 备用方案：直接调用 GitHub API
    log_message "INFO" "检查 GitHub 最新版本..."
    if command -v curl >/dev/null 2>&1; then
        local response=$(curl -s "$GITHUB_API" 2>/dev/null || echo "")
        if [ -n "$response" ]; then
            local latest_version=$(echo "$response" | grep -o '"tag_name":"[^"]*"' | cut -d'"' -f4)
            if [ -n "$latest_version" ]; then
                echo "$latest_version"
                return 0
            fi
        fi
    fi
    
    # 如果无法获取，返回 unknown
    echo "unknown"
}

# 版本比较函数
version_compare() {
    local version1="$1"
    local version2="$2"
    
    # 移除 v 前缀
    version1=${version1#v}
    version2=${version2#v}
    
    # 分割版本号
    IFS='.' read -ra v1 <<< "$version1"
    IFS='.' read -ra v2 <<< "$version2"
    
    # 比较版本号
    for i in "${!v1[@]}"; do
        if [ "${v1[$i]}" -gt "${v2[$i]}" ]; then
            echo "greater"
            return 0
        elif [ "${v1[$i]}" -lt "${v2[$i]}" ]; then
            echo "less"
            return 0
        fi
    done
    
    echo "equal"
    return 0
}

# 检查更新
check_updates() {
    # 使用版本管理脚本检查更新
    if [ -f "$(dirname "$0")/version_manager.sh" ]; then
        "$(dirname "$0")/version_manager.sh" --update
        return $?
    fi
    
    # 备用方案：原有的检查逻辑
    local current_version=$(get_current_version)
    local latest_version=$(get_latest_version)
    
    log_message "INFO" "当前版本: $current_version"
    log_message "INFO" "最新版本: $latest_version"
    
    if [ "$current_version" = "unknown" ]; then
        echo "⚠️  无法确定当前版本，建议重新安装"
        return 1
    fi
    
    local comparison=$(version_compare "$latest_version" "$current_version")
    
    case $comparison in
        "greater")
            echo "🔄 发现新版本: $latest_version"
            echo "   当前版本: $current_version"
            return 0
            ;;
        "equal")
            echo "✅ 已是最新版本: $current_version"
            return 1
            ;;
        "less")
            echo "⚠️  当前版本 ($current_version) 比最新版本 ($latest_version) 更新"
            return 1
            ;;
    esac
}

# 创建备份
create_backup() {
    local backup_name="backup_$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log_message "INFO" "创建备份: $backup_name"
    
    # 创建备份目录
    mkdir -p "$backup_path"
    
    # 备份关键文件
    if [ -f "$API_DIR/Clash.pm" ]; then
        cp "$API_DIR/Clash.pm" "$backup_path/"
        log_message "DEBUG" "备份 API 插件"
    fi
    
    log_message "DEBUG" "跳过 UI 插件备份（已移除Web UI功能）"
    
    if [ -d "$CLASH_DIR/config" ]; then
        cp -r "$CLASH_DIR/config" "$backup_path/"
        log_message "DEBUG" "备份配置文件"
    fi
    
    if [ -d "$CLASH_DIR/scripts" ]; then
        cp -r "$CLASH_DIR/scripts" "$backup_path/"
        log_message "DEBUG" "备份脚本文件"
    fi
    
    # 记录备份信息
    echo "备份时间: $(date)" > "$backup_path/backup_info.txt"
    echo "版本: $(get_current_version)" >> "$backup_path/backup_info.txt"
    
    log_message "INFO" "备份完成: $backup_path"
    echo "✅ 备份已创建: $backup_path"
}

# 从备份恢复
restore_backup() {
    local backup_name="$1"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ -z "$backup_name" ]; then
        echo "❌ 请指定备份名称"
        echo "可用备份:"
        ls -1 "$BACKUP_DIR" 2>/dev/null || echo "  无可用备份"
        return 1
    fi
    
    if [ ! -d "$backup_path" ]; then
        echo "❌ 备份不存在: $backup_name"
        return 1
    fi
    
    log_message "INFO" "从备份恢复: $backup_name"
    
    # 停止服务
    systemctl stop clash-meta 2>/dev/null || true
    
    # 恢复文件
    if [ -f "$backup_path/Clash.pm" ]; then
        cp "$backup_path/Clash.pm" "$API_DIR/"
        log_message "DEBUG" "恢复 API 插件"
    fi
    
    log_message "DEBUG" "跳过 UI 插件恢复（已移除Web UI功能）"
    
    if [ -d "$backup_path/config" ]; then
        cp -r "$backup_path/config"/* "$CLASH_DIR/config/"
        log_message "DEBUG" "恢复配置文件"
    fi
    
    if [ -d "$backup_path/scripts" ]; then
        cp -r "$backup_path/scripts"/* "$CLASH_DIR/scripts/"
        chmod +x "$CLASH_DIR/scripts"/*.sh
        log_message "DEBUG" "恢复脚本文件"
    fi
    
    # 启动服务
    systemctl start clash-meta 2>/dev/null || true
    
    log_message "INFO" "备份恢复完成"
    echo "✅ 备份恢复完成: $backup_name"
}

# 下载指定版本
download_version() {
    local version="$1"
    local temp_dir="/tmp/proxmox-clash-upgrade"
    
    log_message "INFO" "下载版本: $version"
    
    # 创建临时目录
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    
    # 下载发布包
    local download_url="https://github.com/$GITHUB_REPO/archive/refs/tags/$version.tar.gz"
    log_message "DEBUG" "下载地址: $download_url"
    
    if ! curl -L -o "$version.tar.gz" "$download_url"; then
        log_message "ERROR" "下载失败: $download_url"
        echo "❌ 下载失败，请检查网络连接或版本号"
        return 1
    fi
    
    # 解压文件
    tar -xzf "$version.tar.gz" || {
        log_message "ERROR" "解压失败"
        echo "❌ 解压失败"
        return 1
    }
    
    # 查找解压后的目录
    local extracted_dir=$(find . -maxdepth 1 -type d -name "*$version*" | head -1)
    if [ -z "$extracted_dir" ]; then
        log_message "ERROR" "无法找到解压目录"
        echo "❌ 无法找到解压目录"
        return 1
    fi
    
    echo "$extracted_dir"
}

# 执行升级
perform_upgrade() {
    local target_version="$1"
    local current_version=$(get_current_version)
    
    log_message "INFO" "开始升级: $current_version -> $target_version"
    
    # 检查是否为降级
    local comparison=$(version_compare "$target_version" "$current_version")
    if [ "$comparison" = "less" ]; then
        echo "⚠️  警告: 这是降级操作 ($current_version -> $target_version)"
        read -p "是否继续? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_message "INFO" "用户取消升级"
            return 1
        fi
    fi
    
    # 创建备份
    create_backup
    
    # 下载新版本
    local temp_dir=$(download_version "$target_version")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # 停止服务
    log_message "INFO" "停止 clash-meta 服务"
    systemctl stop clash-meta 2>/dev/null || true
    
    # 备份当前文件
    local backup_temp="/tmp/proxmox-clash-backup-$(date +%s)"
    mkdir -p "$backup_temp"
    
    if [ -f "$API_DIR/Clash.pm" ]; then
        cp "$API_DIR/Clash.pm" "$backup_temp/"
    fi
    
    log_message "DEBUG" "跳过 UI 插件临时备份（已移除Web UI功能）"
    
    # 安装新版本
    log_message "INFO" "安装新版本文件"
    
    # 安装 API 插件
    if [ -f "$temp_dir/api/Clash.pm" ]; then
        cp "$temp_dir/api/Clash.pm" "$API_DIR/"
        log_message "DEBUG" "更新 API 插件"
    fi
    
    # 跳过 UI 插件安装（已移除Web UI功能）
log_message "DEBUG" "跳过 UI 插件安装（已移除Web UI功能）"
    
    # 更新脚本
    if [ -d "$temp_dir/scripts" ]; then
        cp -r "$temp_dir/scripts"/* "$CLASH_DIR/scripts/"
        chmod +x "$CLASH_DIR/scripts"/*.sh
        log_message "DEBUG" "更新脚本文件"
    fi
    
    # 更新配置文件
    if [ -d "$temp_dir/config" ]; then
        # 只更新 logrotate 配置，不覆盖用户配置
        if [ -f "$temp_dir/config/logrotate.conf" ]; then
            cp "$temp_dir/config/logrotate.conf" /etc/logrotate.d/proxmox-clash
            log_message "DEBUG" "更新 logrotate 配置"
        fi
    fi
    
    # 更新服务文件
    if [ -f "$temp_dir/service/clash-meta.service" ]; then
        cp "$temp_dir/service/clash-meta.service" /etc/systemd/system/
        systemctl daemon-reload
        log_message "DEBUG" "更新服务文件"
        
        # 验证服务文件
        log_message "INFO" "验证服务文件..."
        
        # 引用服务验证工具
        if [ -f "$CLASH_DIR/scripts/utils/service_validator.sh" ]; then
            source "$CLASH_DIR/scripts/utils/service_validator.sh"
            if verify_service_installation "$temp_dir/service/clash-meta.service" "/etc/systemd/system/clash-meta.service"; then
                log_message "INFO" "✅ 服务文件验证完成"
            else
                log_message "ERROR" "❌ 服务文件验证失败"
                return 1
            fi
        else
            log_message "WARN" "⚠️  服务验证工具不存在，使用基本验证..."
            
            if systemd-analyze verify /etc/systemd/system/clash-meta.service >/dev/null 2>&1; then
                log_message "INFO" "✅ 服务文件语法正确"
            else
                log_message "ERROR" "❌ 服务文件语法错误"
                return 1
            fi
            
            # 确保服务已启用
            if ! systemctl is-enabled clash-meta >/dev/null 2>&1; then
                systemctl enable clash-meta
                log_message "INFO" "✅ 服务已启用"
            fi
        fi
    fi
    
    # 更新版本号
    echo "$target_version" > "$CURRENT_VERSION_FILE"
    log_message "INFO" "版本号更新为: $target_version"
    
    # 启动服务
    log_message "INFO" "启动 clash-meta 服务"
    systemctl start clash-meta 2>/dev/null || true
    
    # 清理临时文件
    rm -rf "$temp_dir" "$backup_temp"
    
    log_message "INFO" "升级完成: $current_version -> $target_version"
    echo "✅ 升级完成: $current_version -> $target_version"
    echo ""
    echo "📝 升级后操作:"
    echo "  - 使用命令行脚本管理服务"
    echo "  - 检查服务状态: systemctl status clash-meta"
    echo "  - 查看日志: /opt/proxmox-clash/scripts/view_logs.sh"
}

# 主函数
main() {
    local action=""
    local target_version=""
    
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then
        log_message "ERROR" "非root用户运行升级脚本"
        echo "❌ 请使用 root 用户运行此脚本"
        exit 1
    fi
    
    # 检查插件是否已安装
    if [ ! -d "$CLASH_DIR" ]; then
        log_message "ERROR" "插件未安装，无法升级"
        echo "❌ 插件未安装，请先运行安装脚本"
        exit 1
    fi
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--version)
                target_version="$2"
                action="upgrade"
                shift 2
                ;;
            -l|--latest)
                action="upgrade"
                target_version="latest"
                shift
                ;;
            -c|--check)
                action="check"
                shift
                ;;
            -b|--backup)
                action="backup"
                shift
                ;;
            -r|--restore)
                action="restore"
                target_version="$2"
                shift 2
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
    if [ -z "$action" ]; then
        show_help
        exit 0
    fi
    
    # 执行操作
    case $action in
        "check")
            check_updates
            ;;
        "backup")
            create_backup
            ;;
        "restore")
            restore_backup "$target_version"
            ;;
        "upgrade")
            if [ "$target_version" = "latest" ]; then
                target_version=$(get_latest_version)
            fi
            
            if [ -z "$target_version" ]; then
                echo "❌ 无法获取目标版本"
                exit 1
            fi
            
            perform_upgrade "$target_version"
            ;;
    esac
}

# 运行主函数
main "$@" 