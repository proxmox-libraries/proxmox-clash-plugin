#!/bin/bash

# Web UI 安装器模块
# 从 GitHub Release 下载并安装 web-ui

# 配置变量
WEB_UI_DIR="/opt/proxmox-clash/web-ui"
GITHUB_REPO="proxmox-libraries/proxmox-clash-plugin"
NGINX_CONF_DIR="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"

# 安装 web-ui
install_web_ui() {
    local version="$1"
    local temp_dir=$(mktemp -d)
    
    log_info "开始安装 Web UI 版本: $version"
    
    # 创建 web-ui 目录
    mkdir -p "$WEB_UI_DIR"
    
    # 下载 web-ui 压缩包
    local download_url="https://github.com/$GITHUB_REPO/releases/download/$version/web-ui-$version.tar.gz"
    local archive_name="web-ui-$version.tar.gz"
    
    log_info "下载 Web UI: $download_url"
    
    if curl -sSL -o "$temp_dir/$archive_name" "$download_url"; then
        log_info "✅ Web UI 下载成功"
    else
        log_error "❌ Web UI 下载失败"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # 解压到目标目录
    log_info "解压 Web UI 到: $WEB_UI_DIR"
    if tar -xzf "$temp_dir/$archive_name" -C "$WEB_UI_DIR" --strip-components=1; then
        log_info "✅ Web UI 解压成功"
    else
        log_error "❌ Web UI 解压失败"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # 设置权限
    chown -R root:root "$WEB_UI_DIR"
    chmod -R 755 "$WEB_UI_DIR"
    
    # 清理临时文件
    rm -rf "$temp_dir"
    
    log_info "✅ Web UI 安装完成"
    return 0
}

# 配置 nginx
configure_nginx() {
    log_info "配置 Nginx..."
    
    # 检查 nginx 是否安装
    if ! command -v nginx &> /dev/null; then
        log_info "安装 Nginx..."
        apt-get update
        apt-get install -y nginx
    fi
    
    # 复制 nginx 配置文件
    local nginx_conf="$NGINX_CONF_DIR/clash-dashboard"
    if [[ -f "config/nginx-clash-dashboard.conf" ]]; then
        cp "config/nginx-clash-dashboard.conf" "$nginx_conf"
        log_info "✅ Nginx 配置文件已复制"
    else
        log_error "❌ 找不到 Nginx 配置文件"
        return 1
    fi
    
    # 启用站点
    if [[ -L "$NGINX_SITES_ENABLED/clash-dashboard" ]]; then
        rm "$NGINX_SITES_ENABLED/clash-dashboard"
    fi
    ln -s "$nginx_conf" "$NGINX_SITES_ENABLED/clash-dashboard"
    
    # 测试 nginx 配置
    if nginx -t; then
        log_info "✅ Nginx 配置测试通过"
    else
        log_error "❌ Nginx 配置测试失败"
        return 1
    fi
    
    # 重启 nginx
    systemctl restart nginx
    if systemctl is-active --quiet nginx; then
        log_info "✅ Nginx 服务已启动"
    else
        log_error "❌ Nginx 服务启动失败"
        return 1
    fi
    
    log_info "✅ Nginx 配置完成"
    return 0
}

# 更新 web-ui
update_web_ui() {
    local version="$1"
    
    log_info "更新 Web UI 到版本: $version"
    
    # 备份当前版本
    if [[ -d "$WEB_UI_DIR" ]]; then
        local backup_dir="/opt/proxmox-clash/web-ui-backup-$(date +%Y%m%d-%H%M%S)"
        cp -r "$WEB_UI_DIR" "$backup_dir"
        log_info "当前版本已备份到: $backup_dir"
    fi
    
    # 安装新版本
    if install_web_ui "$version"; then
        log_info "✅ Web UI 更新成功"
        
        # 重启 nginx
        if systemctl restart nginx; then
            log_info "✅ Nginx 已重启"
        else
            log_warn "⚠️  Nginx 重启失败，请手动重启"
        fi
        
        return 0
    else
        log_error "❌ Web UI 更新失败"
        
        # 恢复备份
        if [[ -d "$backup_dir" ]]; then
            rm -rf "$WEB_UI_DIR"
            mv "$backup_dir" "$WEB_UI_DIR"
            log_info "已恢复之前的版本"
        fi
        
        return 1
    fi
}

# 卸载 web-ui
uninstall_web_ui() {
    log_info "卸载 Web UI..."
    
    # 停止 nginx
    if systemctl is-active --quiet nginx; then
        systemctl stop nginx
        log_info "✅ Nginx 服务已停止"
    fi
    
    # 删除 nginx 配置
    if [[ -L "$NGINX_SITES_ENABLED/clash-dashboard" ]]; then
        rm "$NGINX_SITES_ENABLED/clash-dashboard"
        log_info "✅ Nginx 站点配置已删除"
    fi
    
    if [[ -f "$NGINX_CONF_DIR/clash-dashboard" ]]; then
        rm "$NGINX_CONF_DIR/clash-dashboard"
        log_info "✅ Nginx 配置文件已删除"
    fi
    
    # 删除 web-ui 目录
    if [[ -d "$WEB_UI_DIR" ]]; then
        rm -rf "$WEB_UI_DIR"
        log_info "✅ Web UI 目录已删除"
    fi
    
    # 重启 nginx
    if systemctl start nginx; then
        log_info "✅ Nginx 服务已重启"
    else
        log_warn "⚠️  Nginx 服务启动失败"
    fi
    
    log_info "✅ Web UI 卸载完成"
    return 0
}

# 检查 web-ui 状态
check_web_ui_status() {
    log_info "检查 Web UI 状态..."
    
    local status=0
    
    # 检查 web-ui 目录
    if [[ -d "$WEB_UI_DIR" ]]; then
        log_info "✅ Web UI 目录存在: $WEB_UI_DIR"
        
        # 检查主要文件
        if [[ -f "$WEB_UI_DIR/index.html" ]]; then
            log_info "✅ index.html 文件存在"
        else
            log_error "❌ index.html 文件不存在"
            status=1
        fi
    else
        log_error "❌ Web UI 目录不存在"
        status=1
    fi
    
    # 检查 nginx 配置
    if [[ -L "$NGINX_SITES_ENABLED/clash-dashboard" ]]; then
        log_info "✅ Nginx 站点配置已启用"
    else
        log_error "❌ Nginx 站点配置未启用"
        status=1
    fi
    
    # 检查 nginx 服务状态
    if systemctl is-active --quiet nginx; then
        log_info "✅ Nginx 服务正在运行"
    else
        log_error "❌ Nginx 服务未运行"
        status=1
    fi
    
    # 检查端口监听
    if netstat -tlnp | grep -q ":80 "; then
        log_info "✅ Nginx 正在监听 80 端口"
    else
        log_error "❌ Nginx 未监听 80 端口"
        status=1
    fi
    
    if [[ $status -eq 0 ]]; then
        log_info "✅ Web UI 状态检查通过"
        echo "Web UI 访问地址: http://$(hostname -I | awk '{print $1}')"
    else
        log_error "❌ Web UI 状态检查失败"
    fi
    
    return $status
}
