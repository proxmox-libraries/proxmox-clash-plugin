#!/bin/bash

# 辅助函数工具模块
# 提供各种辅助功能函数

# 检测 PVE UI 目录
detect_pve_ui_dir() {
    local pve_ui_dir=""
    
    # 检查常见的 PVE UI 目录
    for dir in "/usr/share/pve-manager" "/usr/share/javascript/pve-manager" "/usr/share/pve-manager/js"; do
        if [ -d "$dir" ]; then
            pve_ui_dir="$dir"
            break
        fi
    done
    
    echo "$pve_ui_dir"
}

# 获取当前安装版本
get_current_version() {
    local version_file="$INSTALL_DIR/version.txt"
    
    if [ -f "$version_file" ]; then
        cat "$version_file"
    else
        echo "unknown"
    fi
}

# 检查是否为 root 用户
check_root_user() {
    if [ "$EUID" -ne 0 ]; then
        log_error "此脚本需要 root 权限运行"
        log_error "请使用: sudo $0"
        exit 1
    fi
}

# 检查系统架构
check_system_architecture() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        armv7l)
            echo "armv7"
            ;;
        *)
            log_error "不支持的系统架构: $arch"
            exit 1
            ;;
    esac
}

# 检查操作系统类型
check_os_type() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
            echo "debian"
        elif [[ "$ID" == "rhel" || "$ID" == "centos" || "$ID" == "fedora" ]]; then
            echo "rhel"
        else
            log_warn "未知的操作系统类型: $ID"
            echo "unknown"
        fi
    else
        log_warn "无法检测操作系统类型"
        echo "unknown"
    fi
}

# 创建临时目录
create_temp_dir() {
    local temp_dir=$(mktemp -d)
    echo "$temp_dir"
}

# 清理临时目录
cleanup_temp_dir() {
    local temp_dir="$1"
    if [ -n "$temp_dir" ] && [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
        log_debug "已清理临时目录: $temp_dir"
    fi
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 等待服务启动
wait_for_service() {
    local service_name="$1"
    local max_wait="${2:-30}"
    local wait_time=0
    
    log_info "等待服务 $service_name 启动..."
    
    while [ $wait_time -lt $max_wait ]; do
        if systemctl is-active --quiet "$service_name"; then
            log_info "✅ 服务 $service_name 已启动"
            return 0
        fi
        
        sleep 1
        wait_time=$((wait_time + 1))
        
        if [ $((wait_time % 5)) -eq 0 ]; then
            log_info "等待中... ($wait_time/$max_wait 秒)"
        fi
    done
    
    log_error "❌ 服务 $service_name 启动超时"
    return 1
}

# 检查端口是否被占用
check_port_available() {
    local port="$1"
    if command_exists netstat; then
        netstat -tuln | grep -q ":$port "
    elif command_exists ss; then
        ss -tuln | grep -q ":$port "
    else
        log_warn "无法检查端口占用情况"
        return 0
    fi
    
    if [ $? -eq 0 ]; then
        return 1  # 端口被占用
    else
        return 0  # 端口可用
    fi
}

# 生成随机字符串
generate_random_string() {
    local length="${1:-8}"
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "$length" | head -n 1
}

# 备份文件
backup_file() {
    local file_path="$1"
    local backup_suffix="${2:-.backup.$(date +%s)}"
    
    if [ -f "$file_path" ]; then
        local backup_path="${file_path}${backup_suffix}"
        if cp "$file_path" "$backup_path"; then
            log_info "已备份文件: $backup_path"
            return 0
        else
            log_error "备份文件失败: $file_path"
            return 1
        fi
    else
        log_warn "文件不存在，无需备份: $file_path"
        return 0
    fi
}

# 恢复文件
restore_file() {
    local file_path="$1"
    local backup_path="$2"
    
    if [ -f "$backup_path" ]; then
        if cp "$backup_path" "$file_path"; then
            log_info "已恢复文件: $file_path"
            return 0
        else
            log_error "恢复文件失败: $file_path"
            return 1
        fi
    else
        log_error "备份文件不存在: $backup_path"
        return 1
    fi
}
