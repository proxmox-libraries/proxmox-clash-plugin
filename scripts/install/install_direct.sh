#!/bin/bash

# Proxmox Clash 插件直接安装脚本
# 无需 .deb 包，直接下载并安装

set -e

# 配置变量
REPO_URL="https://github.com/proxmox-libraries/proxmox-clash-plugin"
INSTALL_DIR="/opt/proxmox-clash"

# 参数解析：兼容 -l/--latest 与 -v/--version，也支持直接传入版本号
KERNEL_VARIANT="v1"  # 默认选择 v1 变体
VERIFY_AFTER_INSTALL=false  # 默认不验证
parse_args() {
    VERSION="latest"
    while [ $# -gt 0 ]; do
        case "$1" in
            -l|--latest)
                VERSION="latest"
                shift
                ;;
            -v|--version)
                if [ -z "$2" ]; then
                    log_error "必须在 -v/--version 后提供版本号，例如: -v v1.2.0"
                    exit 1
                fi
                VERSION="$2"
                shift 2
                ;;
            --kernel-variant|--variant)
                if [ -z "$2" ]; then
                    log_error "必须在 --kernel-variant 后提供变体：v1|v2|v3|compatible|auto"
                    exit 1
                fi
                case "$2" in
                    v1|v2|v3|compatible|auto) KERNEL_VARIANT="$2" ;;
                    *) log_error "无效的变体：$2（可选：v1|v2|v3|compatible|auto）"; exit 1 ;;
                esac
                shift 2
                ;;
            --verify)
                VERIFY_AFTER_INSTALL=true
                shift
                ;;
            --no-verify)
                VERIFY_AFTER_INSTALL=false
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                # 兼容直接传入版本字符串
                VERSION="$1"
                shift
                ;;
        esac
    done
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
    
    # 规范化版本并打印完整下载链接
    if [ -z "$VERSION" ] || [ "$VERSION" = "latest" ]; then
        log_info "获取插件最新 Release tag..."
        local api_json_tag
        api_json_tag=$(curl -sSL --connect-timeout 15 "https://api.github.com/repos/proxmox-libraries/proxmox-clash-plugin/releases/latest" 2>/dev/null || echo "")
        if [ -z "$api_json_tag" ] || echo "$api_json_tag" | grep -qi 'rate limit exceeded'; then
            api_json_tag=$(curl -sSL --connect-timeout 15 "https://mirror.ghproxy.com/https://api.github.com/repos/proxmox-libraries/proxmox-clash-plugin/releases/latest" 2>/dev/null || echo "")
        fi

        local latest_tag=""
        if command -v jq >/dev/null 2>&1 \
           && echo "$api_json_tag" | jq -e 'type=="object" and has("tag_name")' >/dev/null 2>&1; then
            latest_tag=$(echo "$api_json_tag" | jq -r '.tag_name // empty' 2>/dev/null || echo "")
        fi

        local url
        if [ -n "$latest_tag" ]; then
            log_info "最新 Release: $latest_tag"
            url="$REPO_URL/archive/refs/tags/$latest_tag.tar.gz"
        else
            log_warn "无法获取最新 tag，回退到 main 分支"
            url="$REPO_URL/archive/refs/heads/main.tar.gz"
        fi
        log_info "下载地址: $url"
        if ! curl -fL --retry 3 -o project.tar.gz "$url"; then
            log_error "❌ 下载失败: $url"
            cd /
            rm -rf "$temp_dir"
            exit 1
        fi
    else
        local ver="$VERSION"
        local taguse="$ver"
        # 标准化为以小写 v 开头；已含 v/V 则不重复添加，并统一小写
        if [[ "$taguse" =~ ^[vV] ]]; then
            taguse="v${taguse:1}"
        else
            taguse="v$taguse"
        fi
        log_info "下载版本: $taguse"
        local url="$REPO_URL/archive/refs/tags/$taguse.tar.gz"
        log_info "下载地址: $url"
        if ! curl -fL --retry 3 -o project.tar.gz "$url"; then
            log_error "❌ 指定版本下载失败: $ver"
            cd /
            rm -rf "$temp_dir"
            exit 1
        else
            VERSION="$taguse"
        fi
    fi
    
    # 校验压缩包并解压
    if ! tar -tzf project.tar.gz >/dev/null 2>&1; then
        log_error "❌ 下载的项目压缩包无效，请重试（可能被代理返回了错误页面）"
        cd /
        rm -rf "$temp_dir"
        exit 1
    fi
    tar -xzf project.tar.gz
    local extracted_dir=$(ls -d proxmox-clash-plugin-* 2>/dev/null | head -1)
    if [ -z "$extracted_dir" ]; then
        log_error "❌ 无法识别解压目录"
        cd /
        rm -rf "$temp_dir"
        exit 1
    fi
    
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
        # 设置正确的权限
        sudo chown root:root "$ui_dir/pve-panel-clash.js"
        sudo chmod 644 "$ui_dir/pve-panel-clash.js"
        log_info "✅ UI 组件已安装到: $ui_dir"
        
        # 修改 index.html.tpl 文件
        modify_html_template
    else
        log_warn "⚠️  UI 文件不存在"
    fi
}

# 修改 HTML 模板文件
modify_html_template() {
    log_step "修改 PVE HTML 模板文件..."
    
    local template_file="/usr/share/pve-manager/index.html.tpl"
    local backup_file="/usr/share/pve-manager/index.html.tpl.backup.$(date +%s)"
    
    if [ ! -f "$template_file" ]; then
        log_warn "⚠️  HTML 模板文件不存在: $template_file"
        return 0
    fi
    
    # 检查是否已经修改过
    if grep -q "pve-panel-clash.js" "$template_file"; then
        log_info "✅ HTML 模板已经包含 Clash 插件引用"
        return 0
    fi
    
    # 创建备份
    sudo cp "$template_file" "$backup_file"
    log_info "✅ 已创建备份: $backup_file"
    
    # 查找插入位置（在 pvemanagerlib.js 之后）
    local insert_after="pvemanagerlib.js?ver=\[% version %]"
    
    if grep -q "$insert_after" "$template_file"; then
        # 使用 sed 在指定行后插入我们的脚本引用
        sudo sed -i "/$insert_after/a\    <script type=\"text/javascript\" src=\"/pve2/js/pve-panel-clash.js\"></script>" "$template_file"
        
        if grep -q "pve-panel-clash.js" "$template_file"; then
            log_info "✅ HTML 模板修改成功"
        else
            log_error "❌ HTML 模板修改失败"
            # 恢复备份
            sudo cp "$backup_file" "$template_file"
            return 1
        fi
    else
        log_warn "⚠️  未找到插入位置，尝试在 head 标签末尾添加"
        # 备用方案：在 </head> 标签前插入
        sudo sed -i 's|</head>|    <script type="text/javascript" src="/pve2/js/pve-panel-clash.js"></script>\n  </head>|' "$template_file"
        
        if grep -q "pve-panel-clash.js" "$template_file"; then
            log_info "✅ HTML 模板修改成功（备用方案）"
        else
            log_error "❌ HTML 模板修改失败"
            # 恢复备份
            sudo cp "$backup_file" "$template_file"
            return 1
        fi
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

        # 根据变体构造匹配序列
        local jq_filter=""
        case "$KERNEL_VARIANT" in
            v1)
                jq_filter='(
                  .assets[] | select(.name | test("^mihomo-linux-\\($a)-v1\\.[^/]*\\.gz$")) | .name
                ),(
                  .assets[] | select(.name | test("^mihomo-linux-\\($a)-v1-.*\\.gz$")) | .name
                ),(
                  .assets[] | select(.name | test("^mihomo-linux-\\($a)-compatible-.*\\.gz$")) | .name
                )'
                ;;
            v2)
                jq_filter='(
                  .assets[] | select(.name | test("^mihomo-linux-\\($a)-v2.*\\.gz$")) | .name
                )'
                ;;
            v3)
                jq_filter='(
                  .assets[] | select(.name | test("^mihomo-linux-\\($a)-v3.*\\.gz$")) | .name
                )'
                ;;
            compatible)
                jq_filter='(
                  .assets[] | select(.name | test("^mihomo-linux-\\($a)-compatible-.*\\.gz$")) | .name
                )'
                ;;
            auto)
                jq_filter='(
                  .assets[] | select((.name | test("^mihomo-linux-\\($a)-v[0-9].*\\.gz$"))
                                      and (.name | test("-v[123]-|go[0-9]{3}-|compatible-") | not)) | .name
                ),(
                  .assets[] | select(.name | test("^mihomo-linux-\\($a)-compatible-.*\\.gz$")) | .name
                ),(
                  .assets[] | select(.name | test("^mihomo-linux-\\($a)-(v[123]-|v[0-9].*-v[123]-).*(\\.gz)$")) | .name
                )'
                ;;
        esac

        # 从候选流中取第一个匹配项
        asset_name=$(echo "$api_json" | jq -r --arg a "$arch" "[ ${jq_filter} ] | map(select(. != null)) | .[0] // empty" 2>/dev/null || echo "")
        if [ -n "$asset_name" ] && [ -n "$tag" ]; then
            asset_url=$(echo "$api_json" | jq -r --arg n "$asset_name" '.assets[] | select(.name==$n) | .browser_download_url' 2>/dev/null | head -n1 || echo "")
            log_info "最新 Release: $tag，资产: $asset_name"
            [ -n "$asset_url" ] && log_info "解析到资产 URL: $asset_url"
        fi

        # 变体规则未匹配到资产时，退而求其次匹配更宽泛的命名
        if [ -z "$asset_url" ] && [ -n "$tag" ]; then
            asset_name=$(echo "$api_json" | jq -r --arg a "$arch" '[
                (.assets[] | select(.name | test("^mihomo-linux-\($a)-v1\\.[^/]*\\.gz$")) | .name),
                (.assets[] | select(.name | test("^mihomo-linux-\($a)-v[0-9].*\\.gz$")) | .name),
                (.assets[] | select(.name | test("^mihomo-linux-\($a)-compatible-.*\\.gz$")) | .name)
            ] | map(select(. != null)) | .[0] // empty' 2>/dev/null || echo "")
            if [ -n "$asset_name" ]; then
                asset_url=$(echo "$api_json" | jq -r --arg n "$asset_name" '.assets[] | select(.name==$n) | .browser_download_url' 2>/dev/null | head -n1 || echo "")
                [ -n "$asset_url" ] && log_info "回退匹配到资产: $asset_name"
            fi
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
    # 如果拿到了 tag 但没拿到资产 URL，按常见命名猜测基于 tag 的直链
    if [ -z "$asset_url" ] && [ -n "$tag" ]; then
        short_tag=${tag#v}
        case "$KERNEL_VARIANT" in
            v1)
                urls+=(
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-v$short_tag.gz"
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-v1.$short_tag.gz"
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-$short_tag.gz"
                    "https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-v$short_tag.gz"
                    "https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-v1.$short_tag.gz"
                    "https://mirror.ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-$short_tag.gz"
                )
                ;;
            v2)
                urls+=(
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-v2-v$short_tag.gz"
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-v2-$short_tag.gz"
                )
                ;;
            v3)
                urls+=(
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-v3-v$short_tag.gz"
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-v3-$short_tag.gz"
                )
                ;;
            compatible)
                urls+=(
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-compatible-v$short_tag.gz"
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-compatible-$short_tag.gz"
                )
                ;;
            auto)
                urls+=(
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-v$short_tag.gz"
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-$short_tag.gz"
                    "https://github.com/MetaCubeX/mihomo/releases/download/$tag/mihomo-linux-$arch-compatible-v$short_tag.gz"
                )
                ;;
        esac
        # 添加镜像对应项
        expanded=()
        for u in "${urls[@]}"; do
            expanded+=("$u")
            case "$u" in
                https://github.com/*)
                    expanded+=("https://mirror.ghproxy.com/$u")
                    ;;
            esac
        done
        urls=("${expanded[@]}")
    fi

    # 兜底：使用 latest/download（可能被限流或被代理拦截且常常不存在简名）
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

    # 在替换前，若服务正在运行则先停止，避免 busy；替换后按需恢复
    local was_active=0
    if command -v systemctl >/dev/null 2>&1; then
        if sudo systemctl is-active --quiet clash-meta 2>/dev/null; then
            was_active=1
            log_step "停止 clash-meta 服务以更新内核..."
            sudo systemctl stop clash-meta || true
        fi
    fi

    # 备份当前可执行（可选）
    if [ -f "$target" ]; then
        sudo cp -f "$target" "$target.bak.$(date +%s)" 2>/dev/null || true
    fi

    # 如果是 .gz，解压到临时文件后原子替换，避免 Text file busy
    if echo "$used_url" | grep -q '\.gz$'; then
        if command -v gzip >/dev/null 2>&1; then
            tmp_bin=$(mktemp "$INSTALL_DIR/clash-meta.XXXXXX")
            if gzip -dc "$tmpfile" > "$tmp_bin" 2>/dev/null; then
                sudo chmod +x "$tmp_bin"
                sudo mv -f "$tmp_bin" "$target"
                rm -f "$tmpfile"
            else
                rm -f "$tmpfile" "$tmp_bin"
                log_error "❌ 解压失败"
                exit 1
            fi
        else
            log_error "❌ 系统缺少 gzip，无法解压 .gz 格式"
            rm -f "$tmpfile"
            exit 1
        fi
    else
        # 直接原子替换
        sudo mv -f "$tmpfile" "$target"
    fi

    # 保险：若目标仍是 gzip 压缩数据，尝试再解压一次
    if command -v file >/dev/null 2>&1; then
        ftype=$(file "$target" 2>/dev/null || echo "")
        case "$ftype" in
            *gzip\ compressed\ data*)
                if command -v gzip >/dev/null 2>&1; then
                    tmp2=$(mktemp "$INSTALL_DIR/clash-meta.XXXXXX")
                    if gzip -dc "$target" > "$tmp2" 2>/dev/null; then
                        sudo chmod +x "$tmp2"
                        sudo mv -f "$tmp2" "$target"
                    else
                        rm -f "$tmp2"
                    fi
                fi
                ;;
        esac
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
    log_info "使用下载地址: $used_url"
    if [ -n "$tag" ]; then
        log_info "✅ Clash.Meta 下载成功（$arch, $tag, 大小: $((size/1024)) KB）"
    else
        log_info "✅ Clash.Meta 下载成功（$arch, 大小: $((size/1024)) KB）"
    fi

    # 按需恢复服务
    if [ "$was_active" -eq 1 ]; then
        log_step "重启 clash-meta 服务..."
        sudo systemctl start clash-meta || true
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
    echo ""
    echo "⚠️  重要提示："
    echo "  - HTML 模板已自动修改，包含 Clash 插件引用"
    echo "  - 请刷新 Proxmox Web UI 页面以加载插件"
    echo "  - 如果页面未显示插件，请清除浏览器缓存后重试"
    echo "  - 安装过程中已创建 HTML 模板备份文件"
}

# 主函数
main() {
    echo "🚀 Proxmox Clash 插件直接安装脚本"
    parse_args "$@"
    echo "版本: $VERSION"
    echo "内核变体: $KERNEL_VARIANT"
    echo "安装后验证: $([ "$VERIFY_AFTER_INSTALL" = true ] && echo "是" || echo "否")"
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
    
    # 安装后验证
    if [ "$VERIFY_AFTER_INSTALL" = true ]; then
        echo ""
        log_step "运行安装后验证..."
        if [ -f "$INSTALL_DIR/scripts/utils/verify_installation.sh" ]; then
            "$INSTALL_DIR/scripts/utils/verify_installation.sh"
        else
            log_warn "⚠️  验证脚本不存在，跳过验证"
        fi
    fi
}

# 显示帮助
show_help() {
    echo "用法: $0 [版本] [选项]"
    echo ""
    echo "参数:"
    echo "  版本    指定安装版本 (默认: latest)"
    echo ""
    echo "选项:"
    echo "  --verify    安装完成后自动运行验证"
    echo "  --no-verify 跳过安装后验证 (默认)"
    echo ""
    echo "示例:"
    echo "  $0              # 安装最新版本"
    echo "  $0 v1.1.0       # 安装指定版本"
    echo "  $0 --verify     # 安装最新版本并验证"
    echo "  $0 v1.1.0 --verify  # 安装指定版本并验证"
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
