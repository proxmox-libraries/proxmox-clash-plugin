#!/bin/bash

# 链接创建功能模块
# 负责创建命令行工具链接

# 创建链接
create_links() {
    log_step "创建链接..."
    
    if should_skip_step "links"; then
        log_info "跳过链接创建"
        return 0
    fi
    
    local bin_dir="/usr/local/bin"
    
    # 创建链接目录
    if [ ! -d "$bin_dir" ]; then
        mkdir -p "$bin_dir"
    fi
    
    # 创建各种命令链接
    create_command_links "$bin_dir"
    
    log_info "✅ 链接创建完成"
    return 0
}

# 创建命令链接
create_command_links() {
    local bin_dir="$1"
    
    # 定义要创建的链接
    local links=(
        "proxmox-clash-upgrade:scripts/management/upgrade.sh"
        "proxmox-clash-uninstall:scripts/management/uninstall.sh"
        "proxmox-clash-view-logs:scripts/management/view_logs.sh"
        "proxmox-clash-update-subscription:scripts/management/update_subscription.sh"
        "proxmox-clash-version-manager:scripts/management/version_manager.sh"
    )
    
    for link_info in "${links[@]}"; do
        local link_name="${link_info%%:*}"
        local target_path="${link_info##*:}"
        local full_target="$INSTALL_DIR/$target_path"
        
        # 检查目标文件是否存在
        if [ ! -f "$full_target" ]; then
            log_warn "目标文件不存在，跳过创建链接: $full_target"
            continue
        fi
        
        # 备份现有链接
        if [ -L "$bin_dir/$link_name" ]; then
            rm -f "$bin_dir/$link_name"
        elif [ -f "$bin_dir/$link_name" ]; then
            backup_file "$bin_dir/$link_name"
            rm -f "$bin_dir/$link_name"
        fi
        
        # 创建符号链接
        if ln -sf "$full_target" "$bin_dir/$link_name"; then
            log_info "✅ 创建链接: $link_name -> $target_path"
        else
            log_error "❌ 创建链接失败: $link_name"
        fi
    done
}
