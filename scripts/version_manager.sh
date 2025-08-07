#!/bin/bash

# Proxmox Clash 插件版本管理脚本
# 结合 GitHub 进行版本管理

set -e

# 配置变量
CLASH_DIR="/opt/proxmox-clash"
CURRENT_VERSION_FILE="$CLASH_DIR/version"
GITHUB_REPO="proxmox-libraries/proxmox-clash-plugin"
GITHUB_API="https://api.github.com/repos/$GITHUB_REPO"
CACHE_DIR="$CLASH_DIR/cache"
VERSION_CACHE_FILE="$CACHE_DIR/github_versions.json"
CACHE_EXPIRY=3600  # 1小时缓存过期

# 日志函数
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a /var/log/proxmox-clash.log
}

# 创建缓存目录
ensure_cache_dir() {
    mkdir -p "$CACHE_DIR"
}

# 检查缓存是否过期
is_cache_expired() {
    if [ ! -f "$VERSION_CACHE_FILE" ]; then
        return 0  # 缓存不存在，视为过期
    fi
    
    local cache_time=$(stat -c %Y "$VERSION_CACHE_FILE" 2>/dev/null || echo 0)
    local current_time=$(date +%s)
    local age=$((current_time - cache_time))
    
    [ $age -gt $CACHE_EXPIRY ]
}

# 从 GitHub 获取版本信息
fetch_github_versions() {
    log_message "INFO" "从 GitHub 获取版本信息..."
    
    ensure_cache_dir
    
    # 获取最新版本
    local latest_response=$(curl -s "$GITHUB_API/releases/latest" 2>/dev/null || echo "")
    
    # 获取所有版本
    local releases_response=$(curl -s "$GITHUB_API/releases" 2>/dev/null || echo "")
    
    # 保存到缓存文件
    cat > "$VERSION_CACHE_FILE" << EOF
{
    "latest": $latest_response,
    "releases": $releases_response,
    "fetched_at": "$(date -Iseconds)"
}
EOF
    
    log_message "INFO" "版本信息已缓存到 $VERSION_CACHE_FILE"
}

# 获取最新版本
get_latest_version() {
    if is_cache_expired; then
        fetch_github_versions
    fi
    
    if [ -f "$VERSION_CACHE_FILE" ]; then
        local latest_version=$(jq -r '.latest.tag_name' "$VERSION_CACHE_FILE" 2>/dev/null || echo "")
        if [ "$latest_version" != "null" ] && [ -n "$latest_version" ]; then
            echo "$latest_version"
            return 0
        fi
    fi
    
    echo "unknown"
    return 1
}

# 获取所有可用版本
get_available_versions() {
    if is_cache_expired; then
        fetch_github_versions
    fi
    
    if [ -f "$VERSION_CACHE_FILE" ]; then
        jq -r '.releases[] | .tag_name' "$VERSION_CACHE_FILE" 2>/dev/null || echo ""
    fi
}

# 获取版本详情
get_version_info() {
    local version="$1"
    
    if is_cache_expired; then
        fetch_github_versions
    fi
    
    if [ -f "$VERSION_CACHE_FILE" ]; then
        jq -r ".releases[] | select(.tag_name == \"$version\")" "$VERSION_CACHE_FILE" 2>/dev/null || echo ""
    fi
}

# 获取当前安装版本
get_current_version() {
    if [ -f "$CURRENT_VERSION_FILE" ]; then
        cat "$CURRENT_VERSION_FILE"
    else
        echo "unknown"
    fi
}

# 更新当前版本
update_current_version() {
    local version="$1"
    ensure_cache_dir
    echo "$version" > "$CURRENT_VERSION_FILE"
    log_message "INFO" "当前版本已更新为: $version"
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
    local current_version=$(get_current_version)
    local latest_version=$(get_latest_version)
    
    log_message "INFO" "当前版本: $current_version"
    log_message "INFO" "最新版本: $latest_version"
    
    if [ "$current_version" = "unknown" ]; then
        echo "⚠️  无法确定当前版本，建议重新安装"
        return 1
    fi
    
    if [ "$latest_version" = "unknown" ]; then
        echo "⚠️  无法获取最新版本信息"
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

# 显示版本信息
show_version_info() {
    local version="$1"
    
    if [ -z "$version" ]; then
        version=$(get_latest_version)
    fi
    
    local version_info=$(get_version_info "$version")
    
    if [ -n "$version_info" ]; then
        echo "版本信息: $version"
        echo "发布时间: $(echo "$version_info" | jq -r '.published_at' 2>/dev/null || echo 'unknown')"
        echo "下载次数: $(echo "$version_info" | jq -r '.assets[0].download_count // 0' 2>/dev/null || echo '0')"
        echo "更新说明:"
        echo "$version_info" | jq -r '.body' 2>/dev/null | head -20
    else
        echo "无法获取版本 $version 的详细信息"
    fi
}

# 列出所有版本
list_versions() {
    echo "可用版本列表:"
    echo "=============="
    
    local versions=$(get_available_versions)
    local current_version=$(get_current_version)
    local latest_version=$(get_latest_version)
    
    if [ -n "$versions" ]; then
        echo "$versions" | while read -r version; do
            local marker=""
            if [ "$version" = "$current_version" ]; then
                marker=" (当前)"
            elif [ "$version" = "$latest_version" ]; then
                marker=" (最新)"
            fi
            echo "  $version$marker"
        done
    else
        echo "无法获取版本列表"
    fi
}

# 清理缓存
clear_cache() {
    if [ -f "$VERSION_CACHE_FILE" ]; then
        rm -f "$VERSION_CACHE_FILE"
        log_message "INFO" "版本缓存已清理"
    fi
}

# 显示帮助信息
show_help() {
    echo "Proxmox Clash 插件版本管理工具"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -l, --latest             显示最新版本"
    echo "  -c, --current            显示当前版本"
    echo "  -a, --all                列出所有可用版本"
    echo "  -i, --info VERSION       显示指定版本的详细信息"
    echo "  -u, --update             检查更新"
    echo "  -s, --set VERSION        设置当前版本"
    echo "  --clear-cache            清理版本缓存"
    echo "  --refresh                强制刷新版本信息"
    echo "  -h, --help               显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -l                     # 显示最新版本"
    echo "  $0 -c                     # 显示当前版本"
    echo "  $0 -a                     # 列出所有版本"
    echo "  $0 -i v1.1.0              # 显示版本信息"
    echo "  $0 -u                     # 检查更新"
    echo "  $0 -s v1.1.0              # 设置当前版本"
}

# 主函数
main() {
    case "${1:-}" in
        -l|--latest)
            get_latest_version
            ;;
        -c|--current)
            get_current_version
            ;;
        -a|--all)
            list_versions
            ;;
        -i|--info)
            show_version_info "$2"
            ;;
        -u|--update)
            check_updates
            ;;
        -s|--set)
            update_current_version "$2"
            ;;
        --clear-cache)
            clear_cache
            ;;
        --refresh)
            clear_cache
            fetch_github_versions
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
