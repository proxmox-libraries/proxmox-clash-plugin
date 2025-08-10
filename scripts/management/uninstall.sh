#!/bin/bash

# Proxmox Clash 插件卸载脚本
set -e

CLASH_DIR="/opt/proxmox-clash"
API_DIR="/usr/share/perl5/PVE/API2"
# 自动检测 PVE UI 目录（PVE 8 使用 js，PVE 7 使用 ext6）
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

UI_DIR="$(detect_pve_ui_dir)"

# 恢复 HTML 模板文件函数
restore_html_template() {
    local template_file="/usr/share/pve-manager/index.html.tpl"
    
    if [ ! -f "$template_file" ]; then
        echo "⚠️  HTML 模板文件不存在，跳过恢复"
        return 0
    fi
    
    # 查找并删除 Clash 插件的脚本引用
    if grep -q "pve-panel-clash.js" "$template_file"; then
        echo "🔄 从 HTML 模板中移除 Clash 插件引用..."
        
        # 使用 sed 删除包含 pve-panel-clash.js 的行
        sed -i '/pve-panel-clash.js/d' "$template_file"
        
        if ! grep -q "pve-panel-clash.js" "$template_file"; then
            echo "✅ HTML 模板恢复成功"
        else
            echo "⚠️  HTML 模板恢复可能不完整，请手动检查"
        fi
    else
        echo "✅ HTML 模板无需恢复"
    fi
    
    # 查找并恢复备份文件（如果存在）
    local backup_files=()
    while IFS= read -r -d '' file; do
        backup_files+=("$file")
    done < <(find /usr/share/pve-manager -name "index.html.tpl.backup.*" -print0 2>/dev/null)
    
    if [ ${#backup_files[@]} -gt 0 ]; then
        echo "🔄 发现备份文件，询问是否恢复..."
        echo "备份文件列表:"
        for file in "${backup_files[@]}"; do
            echo "  - $file"
        done
        
        read -p "是否要恢复备份文件？(y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # 选择最新的备份文件
            local latest_backup=""
            local latest_time=0
            for file in "${backup_files[@]}"; do
                local file_time=$(stat -c %Y "$file" 2>/dev/null || echo 0)
                if [ "$file_time" -gt "$latest_time" ]; then
                    latest_time=$file_time
                    latest_backup="$file"
                fi
            done
            
            if [ -n "$latest_backup" ]; then
                echo "🔄 恢复最新备份: $latest_backup"
                cp "$latest_backup" "$template_file"
                echo "✅ 备份恢复完成"
            fi
        fi
    fi
}

echo "🗑️ 开始卸载 Proxmox Clash 插件..."

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用 root 用户运行此脚本"
    exit 1
fi

# 停止服务
echo "🛑 停止 clash-meta 服务..."
systemctl stop clash-meta 2>/dev/null || true
systemctl disable clash-meta 2>/dev/null || true

# 删除服务文件
echo "🗑️ 删除 systemd 服务..."
rm -f /etc/systemd/system/clash-meta.service
systemctl daemon-reload

# 删除 API 插件
echo "🗑️ 删除 API 插件..."
rm -f "$API_DIR/Clash.pm"

# 删除前端插件
echo "🗑️ 删除前端插件..."
if [ -n "$UI_DIR" ]; then
    rm -f "$UI_DIR/pve-panel-clash.js"
else
    echo "⚠️  未找到 PVE UI 目录，跳过删除 UI 插件"
fi

# 恢复 HTML 模板文件
echo "🔄 恢复 HTML 模板文件..."
restore_html_template

# 删除主目录
echo "🗑️ 删除主目录..."
rm -rf "$CLASH_DIR"

# 清理日志文件
echo "🧹 清理日志文件..."
rm -f /var/log/proxmox-clash.log
rm -f /etc/logrotate.d/proxmox-clash

# 清理备份和版本文件
echo "🧹 清理备份和版本文件..."
rm -rf "$CLASH_DIR/backup"
rm -f "$CLASH_DIR/version"

# 清除 iptables 规则
echo "🧹 清除 iptables 规则..."
iptables -t nat -F PREROUTING 2>/dev/null || true
iptables -t mangle -F PREROUTING 2>/dev/null || true

# 保存清理后的 iptables 规则
if command -v iptables-save >/dev/null 2>&1; then
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || \
    iptables-save > /etc/iptables.rules 2>/dev/null || true
fi

echo "✅ 卸载完成！"
echo ""
echo "📝 注意事项："
echo "  - 请刷新 Proxmox Web UI 页面"
echo "  - 如果之前配置了透明代理，可能需要重启网络服务" 