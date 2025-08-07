#!/bin/bash

# Proxmox Clash 插件 - GitHub 镜像配置脚本
# 解决中国大陆用户访问 GitHub 慢的问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_message() {
    local level="$1"
    local message="$2"
    case "$level" in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        "DEBUG")
            echo -e "${BLUE}[DEBUG]${NC} $message"
            ;;
    esac
}

# 显示帮助信息
show_help() {
    echo "Proxmox Clash 插件 - GitHub 镜像配置脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -m, --mirror MIRROR    设置镜像源 (ghproxy, fastgit, cnpmjs)"
    echo "  -c, --check            检查当前网络连接"
    echo "  -r, --reset            重置为原始 GitHub 地址"
    echo "  -h, --help             显示此帮助信息"
    echo ""
    echo "镜像源选项:"
    echo "  ghproxy    - 使用 ghproxy.com (推荐)"
    echo "  fastgit    - 使用 fastgit.org"
    echo "  cnpmjs     - 使用 cnpmjs.org"
    echo ""
    echo "示例:"
    echo "  $0 -m ghproxy          # 设置 ghproxy 镜像"
    echo "  $0 -c                  # 检查网络连接"
    echo "  $0 -r                  # 重置为原始地址"
}

# 检查网络连接
check_network() {
    log_message "INFO" "检查网络连接..."
    
    # 测试原始 GitHub
    echo -n "测试 GitHub.com: "
    if curl -s --connect-timeout 5 https://github.com > /dev/null; then
        echo -e "${GREEN}✓ 正常${NC}"
    else
        echo -e "${RED}✗ 无法访问${NC}"
    fi
    
    # 测试 ghproxy
    echo -n "测试 ghproxy.com: "
    if curl -s --connect-timeout 5 https://ghproxy.com > /dev/null; then
        echo -e "${GREEN}✓ 正常${NC}"
    else
        echo -e "${RED}✗ 无法访问${NC}"
    fi
    
    # 测试 fastgit
    echo -n "测试 fastgit.org: "
    if curl -s --connect-timeout 5 https://download.fastgit.org > /dev/null; then
        echo -e "${GREEN}✓ 正常${NC}"
    else
        echo -e "${RED}✗ 无法访问${NC}"
    fi
}

# 设置 Git 全局配置
setup_git_mirror() {
    local mirror="$1"
    local mirror_url=""
    
    case "$mirror" in
        "ghproxy")
            mirror_url="https://ghproxy.com/"
            log_message "INFO" "设置 ghproxy 镜像: $mirror_url"
            ;;
        "fastgit")
            mirror_url="https://download.fastgit.org/"
            log_message "INFO" "设置 fastgit 镜像: $mirror_url"
            ;;
        "cnpmjs")
            mirror_url="https://github.com.cnpmjs.org/"
            log_message "INFO" "设置 cnpmjs 镜像: $mirror_url"
            ;;
        *)
            log_message "ERROR" "不支持的镜像源: $mirror"
            return 1
            ;;
    esac
    
    # 设置 Git 全局配置
    git config --global url."$mirror_url".insteadOf "https://github.com/"
    git config --global url."$mirror_url".insteadOf "https://raw.githubusercontent.com/"
    
    log_message "INFO" "Git 镜像配置完成"
}

# 重置 Git 配置
reset_git_config() {
    log_message "INFO" "重置 Git 配置..."
    
    # 移除镜像配置
    git config --global --unset url."https://ghproxy.com/".insteadOf 2>/dev/null || true
    git config --global --unset url."https://download.fastgit.org/".insteadOf 2>/dev/null || true
    git config --global --unset url."https://github.com.cnpmjs.org/".insteadOf 2>/dev/null || true
    
    log_message "INFO" "Git 配置已重置为原始地址"
}

# 设置 npm 镜像
setup_npm_mirror() {
    local mirror="$1"
    
    log_message "INFO" "设置 npm 镜像..."
    
    case "$mirror" in
        "ghproxy")
            npm config set registry https://registry.npmmirror.com/
            ;;
        "fastgit")
            npm config set registry https://registry.npmmirror.com/
            ;;
        "cnpmjs")
            npm config set registry https://r.cnpmjs.org/
            ;;
    esac
    
    log_message "INFO" "npm 镜像设置完成"
}

# 设置 pip 镜像
setup_pip_mirror() {
    local mirror="$1"
    
    log_message "INFO" "设置 pip 镜像..."
    
    # 创建 pip 配置目录
    mkdir -p ~/.pip
    
    case "$mirror" in
        "ghproxy"|"fastgit"|"cnpmjs")
            cat > ~/.pip/pip.conf << EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF
            ;;
    esac
    
    log_message "INFO" "pip 镜像设置完成"
}

# 设置 gem 镜像
setup_gem_mirror() {
    local mirror="$1"
    
    log_message "INFO" "设置 gem 镜像..."
    
    case "$mirror" in
        "ghproxy"|"fastgit"|"cnpmjs")
            gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
            ;;
    esac
    
    log_message "INFO" "gem 镜像设置完成"
}

# 创建环境变量配置
create_env_config() {
    local mirror="$1"
    local config_file="$HOME/.github_mirror_config"
    
    log_message "INFO" "创建环境变量配置..."
    
    cat > "$config_file" << EOF
# GitHub 镜像配置
# 生成时间: $(date)
# 镜像源: $mirror

# Git 配置
export GITHUB_MIRROR="$mirror"

# 根据镜像源设置相应的环境变量
case "\$GITHUB_MIRROR" in
    "ghproxy")
        export GITHUB_URL="https://ghproxy.com/"
        ;;
    "fastgit")
        export GITHUB_URL="https://download.fastgit.org/"
        ;;
    "cnpmjs")
        export GITHUB_URL="https://github.com.cnpmjs.org/"
        ;;
esac

# 添加到 PATH 或设置别名
alias git-clone="git clone"
alias curl-github="curl"
EOF
    
    log_message "INFO" "环境变量配置文件已创建: $config_file"
    log_message "INFO" "请将以下行添加到您的 ~/.bashrc 或 ~/.zshrc:"
    echo "source $config_file"
}

# 主函数
main() {
    local action=""
    local mirror=""
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--mirror)
                mirror="$2"
                action="setup"
                shift 2
                ;;
            -c|--check)
                action="check"
                shift
                ;;
            -r|--reset)
                action="reset"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_message "ERROR" "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查是否以 root 权限运行
    if [[ $EUID -eq 0 ]]; then
        log_message "WARN" "检测到 root 权限，建议使用普通用户运行"
    fi
    
    case "$action" in
        "setup")
            if [[ -z "$mirror" ]]; then
                log_message "ERROR" "请指定镜像源"
                show_help
                exit 1
            fi
            
            log_message "INFO" "开始配置 GitHub 镜像..."
            setup_git_mirror "$mirror"
            setup_npm_mirror "$mirror"
            setup_pip_mirror "$mirror"
            setup_gem_mirror "$mirror"
            create_env_config "$mirror"
            
            log_message "INFO" "配置完成！"
            log_message "INFO" "建议重启终端或运行: source ~/.bashrc"
            ;;
        "check")
            check_network
            ;;
        "reset")
            reset_git_config
            log_message "INFO" "重置完成！"
            ;;
        "")
            log_message "ERROR" "请指定操作"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"
