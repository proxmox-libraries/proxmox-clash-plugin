#!/bin/bash

# Proxmox Clash 插件直接安装脚本
# 无需 .deb 包，直接下载并安装

set -e

# 配置变量
REPO_URL="https://github.com/proxmox-libraries/proxmox-clash-plugin"
INSTALL_DIR="/opt/proxmox-clash"

# 参数解析：兼容 -l/--latest 与 -v/--version，也支持直接传入版本号
parse_args() {
    local arg1="$1"
    local arg2="$2"

    if [ -z "$arg1" ]; then
        VERSION="latest"
        return
    fi

    case "$arg1" in
        -l|--latest)
            VERSION="latest"
            ;;
        -v|--version)
            if [ -z "$arg2" ]; then
                log_error "必须在 -v/--version 后提供版本号，例如: -v v1.2.0"
                exit 1
            fi
            VERSION="$arg2"
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            # 兼容直接传入版本字符串
            VERSION="$arg1"
            ;;
    esac
}

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

# 检测 PVE UI 目录（PVE 8 使用 js，PVE 7 使用 ext6）
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
    local ui_dir
    ui_dir=$(detect_pve_ui_dir)
    if [ -z "$ui_dir" ]; then
        log_warn "⚠️  未找到 PVE UI 目录（/usr/share/pve-manager/js 或 ext6），跳过 UI 安装"
        return 0
    fi

    if [ -f "$INSTALL_DIR/ui/pve-panel-clash.js" ]; then
        sudo cp "$INSTALL_DIR/ui/pve-panel-clash.js" "$ui_dir/"
        log_info "✅ UI 组件已安装到: $ui_dir"
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
    
    # 检测架构
    local uname_arch
    uname_arch=$(uname -m)
    local arch=""
    case "$uname_arch" in
        x86_64)
            arch="amd64"
            ;;
        aarch64|arm64)
            arch="arm64"
            ;;
        armv7l|armv7)
            arch="armv7"
            ;;
        *)
            log_warn "⚠️ 未知架构: $uname_arch，默认使用 amd64。如运行失败请手动替换内核。"
            arch="amd64"
            ;;
    esac

    local target="$INSTALL_DIR/clash-meta"
    local api="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"

    # 优先通过 GitHub API 精确获取最新 Release 版本与资产
    local tag=""
    local asset_name=""
    local asset_url=""
    local api_json
    api_json=$(curl -sSL --connect-timeout 15 "$api" 2>/dev/null || echo "")
    # 如果直连 API 失败，尝试镜像 API
    if [ -z "$api_json" ] || echo "$api_json" | grep -qi 'rate limit exceeded'; then
        api_json=$(curl -sSL --connect-timeout 15 "https://mirror.ghproxy.com/https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" 2>/dev/null || echo "")
    fi
    if [ -n "$api_json" ] && command -v jq >/dev/null 2>&1 \
       && echo "$api_json" | jq -e 'type=="object" and (.assets|type=="array")' >/dev/null 2>&1; then
        tag=$(echo "$api_json" | jq -r '.tag_name // empty' 2>/dev/null || echo "")
        # 按优先级匹配 linux-{arch} 的 .gz 资产
        # 1) 纯净命名：mihomo-linux-{arch}-<ver>.gz（不含 -v[1-3]- / -goXXX- / -compatible-）
        # 2) compatible 变体：mihomo-linux-{arch}-compatible-<ver>.gz
        # 3) v1/v2/v3 变体：mihomo-linux-{arch}-v[1-3]-<ver>.gz（可能带 goXXX）
        asset_name=$(echo "$api_json" | jq -r --arg a "$arch" '
          (
            .assets[] | select((.name | test("^mihomo-linux-\($a)-v[0-9].*\\.gz$"))
                                and (.name | test("-v[123]-|go[0-9]{3}-|compatible-") | not)) | .name
          ),(
            .assets[] | select(.name | test("^mihomo-linux-\($a)-compatible-.*\\.gz$")) | .name
          ),(
            .assets[] | select(.name | test("^mihomo-linux-\($a)-(v[123]-|v[0-9].*-v[123]-).*(\\.gz)$")) | .name
          ) | select(. != null) | .[0] // empty' 2>/dev/null || echo "")
        if [ -n "$asset_name" ] && [ -n "$tag" ]; then
            asset_url=$(echo "$api_json" | jq -r --arg n "$asset_name" '.assets[] | select(.name==$n) | .browser_download_url' 2>/dev/null | head -n1 || echo "")
            log_info "最新 Release: $tag，资产: $asset_name"
        fi
    fi

    # 构造下载候选 URL 列表
    local urls=()
    if [ -n "$asset_url" ]; then
        urls+=("$asset_url")
        if [ -n "$tag" ] && [ -n "$asset_name" ]; then
            urls+=("https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/download/$tag/$asset_name")
        fi
    fi
    # 兜底：使用 latest/download（可能被限流或被代理拦截）
    urls+=(
        "https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-$arch"
        "https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-$arch-compatible"
        "https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-$arch.gz"
        "https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-$arch-compatible.gz"
        "https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-$arch"
        "https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-$arch-compatible"
        "https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-$arch.gz"
        "https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-linux-$arch-compatible.gz"
    )

    # 尝试下载
    local tmpfile
    tmpfile=$(mktemp)
    local downloaded=false
    local used_url=""
    for u in "${urls[@]}"; do
        log_info "尝试下载: $u"
        if curl -fL --retry 3 --connect-timeout 20 -o "$tmpfile" "$u"; then
            downloaded=true
            used_url="$u"
            break
        fi
    done

    if [ "$downloaded" != true ]; then
        rm -f "$tmpfile"
        log_error "❌ Clash.Meta 下载失败（主源和镜像均不可用）"
        exit 1
    fi

    # 如果是 .gz，解压到目标
    if echo "$used_url" | grep -q '\\.gz$'; then
        if command -v gzip >/dev/null 2>&1; then
            gzip -dc "$tmpfile" | sudo tee "$target" >/dev/null
            rm -f "$tmpfile"
        else
            log_error "❌ 系统缺少 gzip，无法解压 .gz 格式"
            rm -f "$tmpfile"
            exit 1
        fi
    else
        sudo mv "$tmpfile" "$target"
    fi

    # 基本校验：尺寸和文件类型
    local size
    size=$(stat -c %s "$target" 2>/dev/null || stat -f %z "$target" 2>/dev/null || echo 0)
    if [ -z "$size" ] || [ "$size" -lt 1000000 ]; then
        log_error "❌ 下载的 Clash.Meta 文件异常（大小 $size 字节），请检查网络/代理。"
        exit 1
    fi

    if command -v file >/dev/null 2>&1; then
        local ftype
        ftype=$(file "$target" 2>/dev/null || echo "")
        case "$ftype" in
            *ELF*) ;;
            *)
                log_error "❌ Clash.Meta 文件类型异常: $ftype"
                exit 1
                ;;
        esac
    fi

    sudo chmod +x "$target"
    if [ -n "$tag" ]; then
        log_info "✅ Clash.Meta 下载成功（$arch, $tag, 大小: $((size/1024)) KB）"
    else
        log_info "✅ Clash.Meta 下载成功（$arch, 大小: $((size/1024)) KB）"
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
    parse_args "$1" "$2"
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

# 运行主函数
main "$@"
