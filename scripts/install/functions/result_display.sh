#!/bin/bash

# 结果显示功能模块
# 负责显示安装结果和帮助信息

# 显示安装结果
show_result() {
    log_step "显示安装结果..."
    
    echo ""
    echo "🎉 Proxmox Clash 插件安装完成！"
    echo "=================================="
    echo ""
    
    # 显示安装信息
    show_installation_info
    
    # 显示服务状态
    show_service_status
    
    # 显示访问信息
    show_access_info
    
    # 显示管理命令
    show_management_commands
    
    # 显示文档链接
    show_documentation_links
    
    # 显示重要提示
    show_important_notes
}

# 显示安装信息
show_installation_info() {
    echo "📋 安装信息："
    echo "  安装目录: $INSTALL_DIR"
    echo "  安装版本: $VERSION"
    echo "  安装分支: $BRANCH"
    echo "  内核变体: $KERNEL_VARIANT"
    echo ""
}

# 显示服务状态
show_service_status() {
    echo "🔧 服务状态："
    if systemctl is-active --quiet clash-meta; then
        echo "  Clash 服务: ✅ 运行中"
    else
        echo "  Clash 服务: ❌ 未运行"
        echo "  启动命令: sudo systemctl start clash-meta"
    fi
    
    if systemctl is-enabled --quiet clash-meta; then
        echo "  开机自启: ✅ 已启用"
    else
        echo "  开机自启: ❌ 未启用"
        echo "  启用命令: sudo systemctl enable clash-meta"
    fi
    echo ""
}

# 显示访问信息
show_access_info() {
    echo "🌐 访问地址："
    echo "  Clash API: http://127.0.0.1:9090"
    echo "  Clash 端口: 7890"
    echo "  Clash DNS: 53"
    echo ""
}

# 显示管理命令
show_management_commands() {
    echo "🛠️  管理命令："
    echo "  升级插件: proxmox-clash-upgrade"
    echo "  卸载插件: proxmox-clash-uninstall"
    echo "  查看日志: proxmox-clash-view-logs"
    echo "  更新订阅: proxmox-clash-update-subscription"
    echo "  版本管理: proxmox-clash-version-manager"
    echo ""
}

# 显示文档链接
show_documentation_links() {
    echo "📖 文档地址："
    echo "  https://proxmox-libraries.github.io/proxmox-clash-plugin/"
    echo ""
}

# 显示重要提示
show_important_notes() {
    echo "⚠️  重要提示："
    echo "  - 使用命令行脚本管理 Clash 服务"
    echo "  - 所有功能通过命令行脚本提供"
    echo "  - 配置文件位于: $INSTALL_DIR/config/"
    echo "  - 日志文件位于: $INSTALL_DIR/logs/"
    echo ""
}
