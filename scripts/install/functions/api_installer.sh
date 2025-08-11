#!/bin/bash

# API 安装功能模块
# 负责安装 Proxmox API 模块

# 安装 API 模块
install_api() {
    log_step "安装 API 模块..."
    
    # 检查是否跳过此步骤
    if should_skip_step "api"; then
        log_info "跳过 API 安装"
        return 0
    fi
    
    local api_dir="$INSTALL_DIR/api"
    local pve_api_dir="/usr/share/perl5/PVE/API2"
    
    # 检查 API 目录是否存在
    if [ ! -d "$api_dir" ]; then
        log_error "API 目录不存在: $api_dir"
        return 1
    fi
    
    # 检查 PVE API 目录是否存在
    if [ ! -d "$pve_api_dir" ]; then
        log_error "PVE API 目录不存在: $pve_api_dir"
        log_error "请确保已安装 Proxmox VE"
        return 1
    fi
    
    # 备份现有的 Clash.pm 文件
    if [ -f "$pve_api_dir/Clash.pm" ]; then
        if ! backup_file "$pve_api_dir/Clash.pm"; then
            log_warn "备份现有 API 文件失败，继续安装"
        fi
    fi
    
    # 复制 API 文件
    if ! cp "$api_dir/Clash.pm" "$pve_api_dir/"; then
        log_error "复制 API 文件失败"
        return 1
    fi
    
    # 设置正确的权限
    chmod 644 "$pve_api_dir/Clash.pm"
    chown root:root "$pve_api_dir/Clash.pm"
    
    log_info "✅ API 模块安装完成"
    
    # 验证安装
    if ! verify_api_installation; then
        log_warn "⚠️  API 安装验证失败，但安装过程已完成"
    fi
    
    return 0
}

# 验证 API 安装
verify_api_installation() {
    local pve_api_dir="/usr/share/perl5/PVE/API2"
    local api_file="$pve_api_dir/Clash.pm"
    
    # 检查文件是否存在
    if [ ! -f "$api_file" ]; then
        log_error "API 文件不存在: $api_file"
        return 1
    fi
    
    # 检查文件权限
    local file_perms=$(stat -c "%a" "$api_file" 2>/dev/null || stat -f "%Lp" "$api_file" 2>/dev/null)
    if [ "$file_perms" != "644" ]; then
        log_warn "API 文件权限不正确: $file_perms (应为 644)"
    fi
    
    # 检查文件所有者
    local file_owner=$(stat -c "%U:%G" "$api_file" 2>/dev/null || stat -f "%Su:%Sg" "$api_file" 2>/dev/null)
    if [ "$file_owner" != "root:root" ]; then
        log_warn "API 文件所有者不正确: $file_owner (应为 root:root)"
    fi
    
    # 检查 Perl 语法
    if command_exists perl; then
        if ! perl -c "$api_file" >/dev/null 2>&1; then
            log_error "API 文件 Perl 语法错误"
            return 1
        fi
    else
        log_warn "无法检查 Perl 语法，perl 命令不存在"
    fi
    
    log_info "✅ API 安装验证通过"
    return 0
}

# 检查 API 是否已安装
check_api_installed() {
    local pve_api_dir="/usr/share/perl5/PVE/API2"
    local api_file="$pve_api_dir/Clash.pm"
    
    if [ -f "$api_file" ]; then
        # 检查是否为我们的版本
        if grep -q "proxmox-clash-plugin" "$api_file" 2>/dev/null; then
            log_info "检测到已安装的 Clash API 模块"
            return 0
        else
            log_warn "检测到其他版本的 Clash API 模块"
            return 1
        fi
    fi
    
    return 1
}

# 卸载 API 模块
uninstall_api() {
    local pve_api_dir="/usr/share/perl5/PVE/API2"
    local api_file="$pve_api_dir/Clash.pm"
    
    log_info "卸载 API 模块..."
    
    if [ -f "$api_file" ]; then
        # 检查是否为我们的版本
        if grep -q "proxmox-clash-plugin" "$api_file" 2>/dev/null; then
            # 查找备份文件
            local backup_file=$(find "$pve_api_dir" -name "Clash.pm.backup.*" | head -n1)
            
            if [ -n "$backup_file" ]; then
                # 恢复备份
                if cp "$backup_file" "$api_file"; then
                    log_info "✅ 已恢复原始 API 文件"
                    rm -f "$backup_file"
                else
                    log_error "❌ 恢复原始 API 文件失败"
                    return 1
                fi
            else
                # 直接删除
                if rm -f "$api_file"; then
                    log_info "✅ 已删除 API 文件"
                else
                    log_error "❌ 删除 API 文件失败"
                    return 1
                fi
            fi
        else
            log_warn "检测到其他版本的 API 文件，跳过卸载"
        fi
    else
        log_info "API 文件不存在，无需卸载"
    fi
    
    return 0
}
