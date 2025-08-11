#!/bin/bash

# 配置创建功能模块
# 负责创建 Clash 配置文件

# 创建配置
create_config() {
    log_step "创建配置..."
    
    if should_skip_step "config"; then
        log_info "跳过配置创建"
        return 0
    fi
    
    local config_dir="$INSTALL_DIR/config"
    local config_file="$config_dir/config.yaml"
    
    # 创建配置目录
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
    fi
    
    # 备份现有配置
    if [ -f "$config_file" ]; then
        backup_file "$config_file"
    fi
    
    # 创建默认配置
    if create_default_config "$config_file"; then
        log_info "✅ 配置创建完成"
        return 0
    else
        log_error "❌ 配置创建失败"
        return 1
    fi
}

# 创建默认配置
create_default_config() {
    local config_file="$1"
    
    cat > "$config_file" << 'EOF'
# Clash 配置文件
# 由 Proxmox Clash 插件自动生成

mixed-port: 7890
allow-lan: true
bind-address: '*'
mode: rule
log-level: info
ipv6: false

# 外部控制
external-controller: 127.0.0.1:9090
external-ui: /opt/proxmox-clash/web-ui

# DNS 配置
dns:
  enable: true
  listen: 0.0.0.0:53
  enhanced-mode: redir-host
  nameserver:
    - 223.5.5.5
    - 8.8.8.8
    - 114.114.114.114

# 代理配置
proxies:
  - name: "direct"
    type: direct

proxy-groups:
  - name: "PROXY"
    type: select
    proxies:
      - direct
    use:
      - default

rules:
  - DOMAIN-SUFFIX,google.com,PROXY
  - DOMAIN-SUFFIX,github.com,PROXY
  - DOMAIN-SUFFIX,githubusercontent.com,PROXY
  - MATCH,direct
EOF

    # 设置权限
    chmod 644 "$config_file"
    chown root:root "$config_file"
    
    return 0
}
