#!/bin/bash

# 服务安装功能模块
# 负责安装和配置 systemd 服务

# 安装服务
install_service() {
    log_step "安装服务..."
    
    # 检查是否跳过此步骤
    if should_skip_step "service"; then
        log_info "跳过服务安装"
        return 0
    fi
    
    local source_file="$INSTALL_DIR/service/clash-meta.service"
    local system_file="/etc/systemd/system/clash-meta.service"
    
    # 检查源服务文件是否存在
    if [ ! -f "$source_file" ]; then
        log_error "源服务文件不存在: $source_file"
        return 1
    fi
    
    # 备份现有的服务文件
    if [ -f "$system_file" ]; then
        if ! backup_file "$system_file"; then
            log_warn "备份现有服务文件失败，继续安装"
        fi
    fi
    
    # 复制服务文件到系统目录
    if ! cp "$source_file" "$system_file"; then
        log_error "复制服务文件失败"
        return 1
    fi
    
    # 设置正确的权限
    chmod 644 "$system_file"
    chown root:root "$system_file"
    
    # 重新加载 systemd
    if ! systemctl daemon-reload; then
        log_error "重新加载 systemd 失败"
        return 1
    fi
    
    # 启用服务
    if ! systemctl enable clash-meta; then
        log_error "启用服务失败"
        return 1
    fi
    
    log_info "✅ 服务安装完成"
    
    # 验证服务安装
    if ! verify_service_installation; then
        log_warn "⚠️  服务安装验证失败，但安装过程已完成"
    fi
    
    return 0
}

# 验证服务安装状态
verify_service_installation() {
    log_step "验证服务安装状态..."
    
    # 引用服务验证工具
    if [ -f "$INSTALL_DIR/scripts/utils/service_validator.sh" ]; then
        source "$INSTALL_DIR/scripts/utils/service_validator.sh"
        if verify_service_installation; then
            return 0
        else
            return 1
        fi
    else
        log_warn "⚠️  服务验证工具不存在，使用内置验证..."
        
        local source_file="$INSTALL_DIR/service/clash-meta.service"
        local system_file="/etc/systemd/system/clash-meta.service"
        
        # 检查源文件是否存在
        if [ ! -f "$source_file" ]; then
            log_error "❌ 源服务文件不存在: $source_file"
            return 1
        fi
        
        # 检查系统服务文件是否存在
        if [ ! -f "$system_file" ]; then
            log_error "❌ 系统服务文件不存在: $system_file"
            return 1
        fi
        
        # 比较文件内容
        if diff "$source_file" "$system_file" >/dev/null 2>&1; then
            log_info "✅ 服务文件内容一致"
        else
            log_warn "⚠️  服务文件内容不一致，正在修复..."
            sudo cp "$source_file" "$system_file"
            sudo systemctl daemon-reload
            log_info "✅ 服务文件已修复"
        fi
        
        # 验证服务文件语法
        if systemd-analyze verify "$system_file" >/dev/null 2>&1; then
            log_info "✅ 服务文件语法正确"
        else
            log_error "❌ 服务文件语法错误"
            return 1
        fi
        
        # 检查服务是否已启用
        if systemctl is-enabled clash-meta >/dev/null 2>&1; then
            log_info "✅ 服务已启用"
        else
            log_warn "⚠️  服务未启用，正在启用..."
            sudo systemctl enable clash-meta
            log_info "✅ 服务已启用"
        fi
        
        log_info "✅ 服务安装验证完成"
        return 0
    fi
}

# 启动服务
start_service() {
    log_info "启动 Clash 服务..."
    
    if systemctl start clash-meta; then
        log_info "✅ 服务启动成功"
        
        # 等待服务完全启动
        if wait_for_service "clash-meta" 30; then
            return 0
        else
            log_warn "⚠️  服务启动超时，但可能仍在启动中"
            return 0
        fi
    else
        log_error "❌ 服务启动失败"
        return 1
    fi
}

# 停止服务
stop_service() {
    log_info "停止 Clash 服务..."
    
    if systemctl stop clash-meta; then
        log_info "✅ 服务停止成功"
        return 0
    else
        log_error "❌ 服务停止失败"
        return 1
    fi
}

# 重启服务
restart_service() {
    log_info "重启 Clash 服务..."
    
    if systemctl restart clash-meta; then
        log_info "✅ 服务重启成功"
        
        # 等待服务完全启动
        if wait_for_service "clash-meta" 30; then
            return 0
        else
            log_warn "⚠️  服务重启超时，但可能仍在启动中"
            return 0
        fi
    else
        log_error "❌ 服务重启失败"
        return 1
    fi
}

# 检查服务状态
check_service_status() {
    local service_name="clash-meta"
    
    log_info "检查服务状态..."
    
    # 检查服务是否运行
    if systemctl is-active --quiet "$service_name"; then
        log_info "✅ 服务正在运行"
        
        # 显示服务状态
        systemctl status "$service_name" --no-pager -l
        
        return 0
    else
        log_warn "⚠️  服务未运行"
        
        # 显示服务状态
        systemctl status "$service_name" --no-pager -l
        
        return 1
    fi
}

# 卸载服务
uninstall_service() {
    log_info "卸载 Clash 服务..."
    
    local system_file="/etc/systemd/system/clash-meta.service"
    
    # 停止服务
    if systemctl is-active --quiet clash-meta; then
        log_info "停止服务..."
        systemctl stop clash-meta
    fi
    
    # 禁用服务
    if systemctl is-enabled --quiet clash-meta; then
        log_info "禁用服务..."
        systemctl disable clash-meta
    fi
    
    # 删除服务文件
    if [ -f "$system_file" ]; then
        # 检查是否为我们的版本
        if grep -q "proxmox-clash-plugin" "$system_file" 2>/dev/null; then
            if rm -f "$system_file"; then
                log_info "✅ 已删除服务文件"
            else
                log_error "❌ 删除服务文件失败"
                return 1
            fi
        else
            log_warn "检测到其他版本的服务文件，跳过删除"
        fi
    fi
    
    # 重新加载 systemd
    if systemctl daemon-reload; then
        log_info "✅ systemd 已重新加载"
    else
        log_warn "⚠️  systemd 重新加载失败"
    fi
    
    return 0
}
