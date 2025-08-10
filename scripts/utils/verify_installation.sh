#!/bin/bash

# Proxmox Clash 插件安装验证脚本
# 用于验证安装是否成功

set -e

# 配置变量
INSTALL_DIR="/opt/proxmox-clash"
API_DIR="/usr/share/perl5/PVE/API2"

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

# 检测 PVE UI 目录
detect_pve_ui_dir() {
    if [ -d "/usr/share/pve-manager/js" ]; then
        echo "/usr/share/pve-manager/js"
        return 0
    fi
    if [ -d "/usr/share/pve-manager/ext6" ]; then
        echo "/usr/share/pve-manager/ext6"
        return 0
    fi
    echo ""
    return 1
}

# 验证文件安装
verify_files() {
    log_step "验证文件安装..."
    
    local all_good=true
    
    # 检查主目录
    if [ -d "$INSTALL_DIR" ]; then
        log_info "✅ 主目录存在: $INSTALL_DIR"
    else
        log_error "❌ 主目录不存在: $INSTALL_DIR"
        all_good=false
    fi
    
    # 检查 API 文件
    if [ -f "$API_DIR/Clash.pm" ]; then
        log_info "✅ API 文件已安装: $API_DIR/Clash.pm"
    else
        log_error "❌ API 文件未安装: $API_DIR/Clash.pm"
        all_good=false
    fi
    
    # 检查 UI 文件
    local ui_dir
    ui_dir=$(detect_pve_ui_dir)
    if [ -n "$ui_dir" ]; then
        if [ -f "$ui_dir/pve-panel-clash.js" ]; then
            log_info "✅ UI 文件已安装: $ui_dir/pve-panel-clash.js"
            
            # 检查文件权限
            local perms=$(stat -c %a "$ui_dir/pve-panel-clash.js" 2>/dev/null || echo "unknown")
            if [ "$perms" = "644" ]; then
                log_info "✅ UI 文件权限正确: $perms"
            else
                log_warn "⚠️  UI 文件权限可能不正确: $perms (期望: 644)"
            fi
        else
            log_error "❌ UI 文件未安装: $ui_dir/pve-panel-clash.js"
            all_good=false
        fi
    else
        log_warn "⚠️  未找到 PVE UI 目录"
    fi
    
    # 检查服务文件
    if [ -f "/etc/systemd/system/clash-meta.service" ]; then
        log_info "✅ 服务文件已安装: /etc/systemd/system/clash-meta.service"
    else
        log_error "❌ 服务文件未安装: /etc/systemd/system/clash-meta.service"
        all_good=false
    fi
    
    # 检查可执行文件
    if [ -f "$INSTALL_DIR/clash-meta" ]; then
        log_info "✅ Clash 可执行文件存在: $INSTALL_DIR/clash-meta"
        
        # 检查执行权限
        if [ -x "$INSTALL_DIR/clash-meta" ]; then
            log_info "✅ Clash 可执行文件权限正确"
        else
            log_warn "⚠️  Clash 可执行文件缺少执行权限"
        fi
        
        # 检查文件大小
        local size=$(stat -c %s "$INSTALL_DIR/clash-meta" 2>/dev/null || echo 0)
        if [ "$size" -gt 1000000 ]; then
            log_info "✅ Clash 可执行文件大小正常: $((size/1024)) KB"
        else
            log_warn "⚠️  Clash 可执行文件大小异常: $((size/1024)) KB"
        fi
    else
        log_error "❌ Clash 可执行文件不存在: $INSTALL_DIR/clash-meta"
        all_good=false
    fi
    
    # 检查配置文件
    if [ -f "$INSTALL_DIR/config/config.yaml" ]; then
        log_info "✅ 配置文件存在: $INSTALL_DIR/config/config.yaml"
    else
        log_warn "⚠️  配置文件不存在: $INSTALL_DIR/config/config.yaml"
    fi
    
    # 检查管理脚本
    local scripts=("upgrade.sh" "uninstall.sh" "view_logs.sh")
    for script in "${scripts[@]}"; do
        if [ -f "$INSTALL_DIR/scripts/management/$script" ]; then
            if [ -x "$INSTALL_DIR/scripts/management/$script" ]; then
                log_info "✅ 管理脚本存在且可执行: $script"
            else
                log_warn "⚠️  管理脚本存在但不可执行: $script"
            fi
        else
            log_warn "⚠️  管理脚本不存在: $script"
        fi
    done
    
    return $([ "$all_good" = true ] && echo 0 || echo 1)
}

# 验证 HTML 模板修改
verify_html_template() {
    log_step "验证 HTML 模板修改..."
    
    local template_file="/usr/share/pve-manager/index.html.tpl"
    
    if [ ! -f "$template_file" ]; then
        log_warn "⚠️  HTML 模板文件不存在: $template_file"
        return 0
    fi
    
    if grep -q "pve-panel-clash.js" "$template_file"; then
        log_info "✅ HTML 模板已包含 Clash 插件引用"
        
        # 显示引用行
        local line_num=$(grep -n "pve-panel-clash.js" "$template_file" | cut -d: -f1)
        log_info "  引用位置: 第 $line_num 行"
        
        # 显示上下文
        local context=$(grep -A2 -B2 "pve-panel-clash.js" "$template_file")
        log_info "  引用上下文:"
        echo "$context" | sed 's/^/    /'
        
        return 0
    else
        log_error "❌ HTML 模板未包含 Clash 插件引用"
        return 1
    fi
}

# 验证服务状态
verify_service() {
    log_step "验证服务状态..."
    
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl is-enabled clash-meta >/dev/null 2>&1; then
            log_info "✅ clash-meta 服务已启用"
        else
            log_warn "⚠️  clash-meta 服务未启用"
        fi
        
        if systemctl is-active clash-meta >/dev/null 2>&1; then
            log_info "✅ clash-meta 服务正在运行"
        else
            log_warn "⚠️  clash-meta 服务未运行"
        fi
        
        # 显示服务状态详情
        log_info "服务状态详情:"
        systemctl status clash-meta --no-pager -l | head -20 | sed 's/^/    /'
    else
        log_warn "⚠️  systemctl 命令不可用"
    fi
}

# 验证网络端口
verify_ports() {
    log_step "验证网络端口..."
    
    local ports=(7890 9090 53)
    local port_names=("代理端口" "API端口" "DNS端口")
    
    for i in "${!ports[@]}"; do
        local port=${ports[$i]}
        local name=${port_names[$i]}
        
        if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
            log_info "✅ $name ($port) 正在监听"
        else
            log_warn "⚠️  $name ($port) 未监听"
        fi
    done
}

# 验证 API 功能
verify_api() {
    log_step "验证 API 功能..."
    
    # 检查 PVE API 是否可用
    if [ -f "/usr/share/perl5/PVE/API2/Clash.pm" ]; then
        log_info "✅ Clash API 模块已安装"
        
        # 尝试加载模块
        if perl -MPVE::API2::Clash -e "print 'Module loaded successfully\n'" 2>/dev/null; then
            log_info "✅ Clash API 模块可以正常加载"
        else
            log_warn "⚠️  Clash API 模块加载失败"
        fi
    else
        log_error "❌ Clash API 模块未安装"
    fi
}

# 显示验证结果
show_verification_result() {
    local exit_code=$1
    
    echo ""
    if [ $exit_code -eq 0 ]; then
        log_info "🎉 安装验证完成！"
        echo ""
        echo "📋 验证结果："
        echo "  ✅ 所有核心组件安装正常"
        echo "  ✅ HTML 模板修改成功"
        echo "  ✅ 服务配置正确"
        echo ""
        echo "🚀 下一步操作："
        echo "  1. 刷新 Proxmox Web UI 页面"
        echo "  2. 在左侧菜单中查找 'Clash 控制' 选项"
        echo "  3. 如果未显示，请清除浏览器缓存后重试"
        echo "  4. 启动 clash-meta 服务: systemctl start clash-meta"
        echo ""
        echo "🔧 故障排除："
        echo "  - 查看详细日志: journalctl -u clash-meta -f"
        echo "  - 检查服务状态: systemctl status clash-meta"
        echo "  - 重新安装: proxmox-clash-install"
    else
        log_error "❌ 安装验证失败！"
        echo ""
        echo "📋 问题分析："
        echo "  - 部分组件安装不完整"
        echo "  - 请检查安装日志"
        echo "  - 尝试重新安装"
        echo ""
        echo "🔧 建议操作："
        echo "  1. 查看安装日志"
        echo "  2. 检查系统权限"
        echo "  3. 重新运行安装脚本"
        echo "  4. 联系技术支持"
    fi
}

# 主函数
main() {
    echo "🔍 Proxmox Clash 插件安装验证"
    echo "================================"
    echo ""
    
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用 sudo 运行此验证脚本"
        exit 1
    fi
    
    local overall_success=true
    
    # 运行各项验证
    verify_files || overall_success=false
    echo ""
    
    verify_html_template || overall_success=false
    echo ""
    
    verify_service || overall_success=false
    echo ""
    
    verify_ports || overall_success=false
    echo ""
    
    verify_api || overall_success=false
    echo ""
    
    # 显示最终结果
    show_verification_result $([ "$overall_success" = true ] && echo 0 || echo 1)
    
    exit $([ "$overall_success" = true ] && echo 0 || echo 1)
}

# 运行主函数
main "$@"
