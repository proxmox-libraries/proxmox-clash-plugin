#!/bin/bash

# Proxmox Clash 插件直接安装脚本
# 无需 .deb 包，直接下载并安装

set -e

# 配置变量
REPO_URL="https://github.com/proxmox-libraries/proxmox-clash-plugin"
INSTALL_DIR="/opt/proxmox-clash"
VERSION="${1:-latest}"

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

# 检查依赖
check_dependencies() {
    log_step "检查系统依赖..."
    
    local missing_deps=()
    
    for cmd in curl wget jq systemctl; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "缺少必要的依赖: ${missing_deps[*]}"
        echo "请安装以下包:"
        echo "  sudo apt-get install -y ${missing_deps[*]}"
        exit 1
    fi
    
    log_info "✅ 依赖检查完成"
}

# 下载项目文件
download_files() {
    log_step "下载项目文件..."
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    if [ "$VERSION" = "latest" ]; then
        # 下载最新版本
        log_info "下载最新版本..."
        curl -L -o project.tar.gz "$REPO_URL/archive/refs/heads/main.tar.gz"
    else
        # 下载指定版本
        log_info "下载版本: $VERSION"
        curl -L -o project.tar.gz "$REPO_URL/archive/refs/tags/$VERSION.tar.gz"
    fi
    
    # 解压文件
    tar -xzf project.tar.gz
    local extracted_dir=$(ls -d proxmox-clash-plugin-*)
    
    # 创建安装目录
    sudo mkdir -p "$INSTALL_DIR"
    
    # 复制文件
    sudo cp -r "$extracted_dir"/{api,ui,service,config} "$INSTALL_DIR/"
    sudo cp -r "$extracted_dir/scripts" "$INSTALL_DIR/"
    
    # 设置权限
    sudo chown -R root:root "$INSTALL_DIR"
    sudo chmod -R 755 "$INSTALL_DIR"
    sudo chmod +x "$INSTALL_DIR"/scripts/*/*.sh
    
    # 清理临时文件
    cd /
    rm -rf "$temp_dir"
    
    log_info "✅ 文件下载完成"
}

# 安装 API 模块
install_api() {
    log_step "安装 API 模块..."
    
    if [ -f "$INSTALL_DIR/api/Clash.pm" ]; then
        sudo cp "$INSTALL_DIR/api/Clash.pm" "/usr/share/perl5/PVE/API2/"
        log_info "✅ API 模块已安装"
    else
        log_warn "⚠️  API 文件不存在"
    fi
}

# 安装 UI 组件
install_ui() {
    log_step "安装 UI 组件..."
    
    if [ -f "$INSTALL_DIR/ui/pve-panel-clash.js" ]; then
        sudo cp "$INSTALL_DIR/ui/pve-panel-clash.js" "/usr/share/pve-manager/ext6/"
        log_info "✅ UI 组件已安装"
    else
        log_warn "⚠️  UI 文件不存在"
    fi
}

# 安装服务
install_service() {
    log_step "安装 systemd 服务..."
    
    if [ -f "$INSTALL_DIR/service/clash-meta.service" ]; then
        sudo cp "$INSTALL_DIR/service/clash-meta.service" "/etc/systemd/system/"
        sudo systemctl daemon-reload
        sudo systemctl enable clash-meta.service
        log_info "✅ 服务已安装并启用"
    else
        log_warn "⚠️  服务文件不存在"
    fi
}

# 下载 mihomo
download_mihomo() {
    log_step "下载 Clash.Meta (mihomo)..."
    
    local mihomo_url="https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-amd64"
    
    if curl -L -o "$INSTALL_DIR/clash-meta" "$mihomo_url"; then
        sudo chmod +x "$INSTALL_DIR/clash-meta"
        log_info "✅ Clash.Meta 下载成功"
    else
        log_error "❌ Clash.Meta 下载失败"
        exit 1
    fi
}

# 创建配置文件
create_config() {
    log_step "创建配置文件..."
    
    local config_file="$INSTALL_DIR/config/config.yaml"
    
    if [ ! -f "$config_file" ]; then
        sudo tee "$config_file" > /dev/null << 'EOF'
# Proxmox Clash 插件默认配置
mixed-port: 9090
allow-lan: true
bind-address: '*'
mode: rule
log-level: info
external-controller: 127.0.0.1:9092
secret: ""

proxies:
  - name: "DIRECT"
    type: direct

proxy-groups:
  - name: "PROXY"
    type: select
    proxies:
      - DIRECT

rules:
  - DOMAIN-SUFFIX,google.com,PROXY
  - DOMAIN-SUFFIX,github.com,PROXY
  - MATCH,DIRECT
EOF
        log_info "✅ 默认配置文件已创建"
    else
        log_info "✅ 配置文件已存在"
    fi
}

# 创建管理脚本链接
create_links() {
    log_step "创建管理脚本链接..."
    
    # 创建 /usr/local/bin 链接
    sudo ln -sf "$INSTALL_DIR/scripts/install/install_direct.sh" "/usr/local/bin/proxmox-clash-install"
sudo ln -sf "$INSTALL_DIR/scripts/management/upgrade.sh" "/usr/local/bin/proxmox-clash-upgrade"
sudo ln -sf "$INSTALL_DIR/scripts/management/uninstall.sh" "/usr/local/bin/proxmox-clash-uninstall"
    
    log_info "✅ 管理脚本链接已创建"
}

# 显示安装结果
show_result() {
    log_info "🎉 安装完成！"
    echo ""
    echo "📋 使用说明："
    echo "  启动服务: systemctl start clash-meta"
    echo "  停止服务: systemctl stop clash-meta"
    echo "  查看状态: systemctl status clash-meta"
    echo "  查看日志: journalctl -u clash-meta -f"
    echo ""
    echo "🔧 管理命令："
    echo "  升级插件: proxmox-clash-upgrade"
    echo "  卸载插件: proxmox-clash-uninstall"
    echo ""
    echo "🌐 访问地址："
    echo "  Proxmox Web UI: https://your-pve-host:8006"
    echo "  Clash API: http://127.0.0.1:9092"
    echo ""
    echo "📖 文档地址："
    echo "  https://proxmox-libraries.github.io/proxmox-clash-plugin/"
}

# 主函数
main() {
    echo "🚀 Proxmox Clash 插件直接安装脚本"
    echo "版本: $VERSION"
    echo ""
    
    check_dependencies
    download_files
    install_api
    install_ui
    install_service
    download_mihomo
    create_config
    create_links
    show_result
}

# 显示帮助
show_help() {
    echo "用法: $0 [版本]"
    echo ""
    echo "参数:"
    echo "  版本    指定安装版本 (默认: latest)"
    echo ""
    echo "示例:"
    echo "  $0              # 安装最新版本"
    echo "  $0 v1.1.0       # 安装指定版本"
    echo ""
    echo "注意: 此脚本需要 sudo 权限"
}

# 检查参数
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# 检查权限
if [ "$EUID" -eq 0 ]; then
    log_error "请不要使用 root 用户运行此脚本"
    exit 1
fi

# 运行主函数
main "$@"
