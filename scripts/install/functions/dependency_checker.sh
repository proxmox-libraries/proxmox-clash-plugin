#!/bin/bash

# 依赖检查功能模块
# 检查系统是否满足安装要求

# 检查系统依赖
check_dependencies() {
    log_step "检查系统依赖..."
    
    # 检查是否为 root 用户
    check_root_user
    
    # 检查系统架构
    local arch=$(check_system_architecture)
    log_info "系统架构: $arch"
    
    # 检查操作系统类型
    local os_type=$(check_os_type)
    log_info "操作系统类型: $os_type"
    
    # 检查必要的命令
    local required_commands=("curl" "wget" "tar" "gzip" "systemctl")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [ ${#missing_commands[@]} -gt 0 ]; then
        log_error "缺少必要的命令: ${missing_commands[*]}"
        log_info "请安装缺失的包后重试"
        
        case "$os_type" in
            "debian")
                log_info "Debian/Ubuntu 系统可以使用: apt update && apt install -y curl wget tar gzip"
                ;;
            "rhel")
                log_info "RHEL/CentOS 系统可以使用: yum install -y curl wget tar gzip"
                ;;
            *)
                log_info "请根据您的系统安装缺失的包"
                ;;
        esac
        
        exit 1
    fi
    
    # 检查 systemd 是否可用
    if ! command_exists systemctl; then
        log_error "系统不支持 systemd，无法安装服务"
        exit 1
    fi
    
    # 检查网络连接
    if ! check_network_connectivity; then
        log_error "网络连接检查失败，请检查网络设置"
        exit 1
    fi
    
    # 检查端口可用性
    local required_ports=(9092 9093)
    for port in "${required_ports[@]}"; do
        if ! check_port_available "$port"; then
            log_warn "端口 $port 已被占用，安装后可能需要修改配置"
        fi
    done
    
    # 检查磁盘空间
    if ! check_disk_space; then
        log_error "磁盘空间不足，至少需要 100MB 可用空间"
        exit 1
    fi
    
    log_info "✅ 系统依赖检查通过"
}

# 检查网络连接
check_network_connectivity() {
    # 尝试连接 GitHub
    if curl -s --connect-timeout 10 --max-time 30 "https://github.com" >/dev/null 2>&1; then
        return 0
    fi
    
    # 尝试连接 Google
    if curl -s --connect-timeout 10 --max-time 30 "https://www.google.com" >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# 检查磁盘空间
check_disk_space() {
    local required_space=100  # 100MB
    local available_space
    
    if command_exists df; then
        available_space=$(df -m "$INSTALL_DIR" 2>/dev/null | awk 'NR==2 {print $4}')
        if [ -n "$available_space" ] && [ "$available_space" -ge "$required_space" ]; then
            return 0
        fi
    fi
    
    # 如果无法获取具体空间，尝试创建测试文件
    local test_file="$INSTALL_DIR/.space_test"
    if dd if=/dev/zero of="$test_file" bs=1M count="$required_space" 2>/dev/null; then
        rm -f "$test_file"
        return 0
    fi
    
    return 1
}

# 检查 PVE 环境
check_pve_environment() {
    log_info "检查 PVE 环境..."
    
    # 检查 PVE 相关目录
    local pve_ui_dir=$(detect_pve_ui_dir)
    if [ -n "$pve_ui_dir" ]; then
        log_info "检测到 PVE UI 目录: $pve_ui_dir"
    else
        log_warn "未检测到 PVE UI 目录，某些功能可能受限"
    fi
    
    # 检查 PVE 版本
    if command_exists pveversion; then
        local pve_version=$(pveversion -v 2>/dev/null | head -n1)
        if [ -n "$pve_version" ]; then
            log_info "PVE 版本: $pve_version"
        fi
    fi
    
    # 检查是否在容器中运行
    if [ -f /.dockerenv ] || grep -q 'lxc' /proc/1/cgroup 2>/dev/null; then
        log_warn "检测到在容器中运行，某些功能可能受限"
    fi
}

# 检查现有安装
check_existing_installation() {
    log_info "检查现有安装..."
    
    if [ -d "$INSTALL_DIR" ]; then
        local current_version=$(get_current_version)
        log_info "检测到现有安装，版本: $current_version"
        
        if [ "$current_version" != "unknown" ]; then
            log_info "建议先卸载现有版本或使用升级脚本"
            log_info "卸载命令: $INSTALL_DIR/scripts/management/uninstall.sh"
            log_info "升级命令: $INSTALL_DIR/scripts/management/upgrade.sh"
        fi
    else
        log_info "未检测到现有安装"
    fi
}
