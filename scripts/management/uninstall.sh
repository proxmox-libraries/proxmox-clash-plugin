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
        echo ""
        echo "📋 备份文件列表（按版本和时间排序）:"
        
        # 解析备份文件信息并排序
        local backup_info=()
        for file in "${backup_files[@]}"; do
            local filename=$(basename "$file")
            local version="unknown"
            local timestamp="0"
            
            # 解析版本和时间戳
            if [[ "$filename" =~ \.backup\.v([^.]+)\.([0-9]+)$ ]]; then
                version="${BASH_REMATCH[1]}"
                timestamp="${BASH_REMATCH[2]}"
            elif [[ "$filename" =~ \.backup\.([0-9]+)$ ]]; then
                timestamp="${BASH_REMATCH[1]}"
            fi
            
            # 格式化时间
            local date_str=$(date -d "@$timestamp" 2>/dev/null || echo "未知时间")
            local size=$(stat -c %s "$file" 2>/dev/null || echo 0)
            local size_kb=$((size / 1024))
            
            backup_info+=("$version|$timestamp|$date_str|$size_kb|$file")
        done
        
        # 按时间戳排序（最新的在前）
        IFS=$'\n' sorted_backups=($(sort -t'|' -k2 -nr <<<"${backup_info[*]}"))
        unset IFS
        
        # 显示备份文件信息
        local index=1
        for backup in "${sorted_backups[@]}"; do
            IFS='|' read -r version timestamp date_str size_kb file <<< "$backup"
            echo "  $index. 版本: $version | 时间: $date_str | 大小: ${size_kb}KB"
            echo "     文件: $file"
            echo ""
            ((index++))
        done
        
        # 询问用户选择
        echo "请选择要恢复的备份文件（输入序号）:"
        read -p "选择 (1-${#sorted_backups[@]}) 或按 Enter 跳过: " choice
        
        if [[ -n "$choice" && "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le ${#sorted_backups[@]} ]]; then
            local selected_backup="${sorted_backups[$((choice-1))]}"
            IFS='|' read -r version timestamp date_str size_kb file <<< "$selected_backup"
            
            echo "🔄 恢复选择的备份文件:"
            echo "  版本: $version"
            echo "  时间: $date_str"
            echo "  文件: $file"
            
            read -p "确认恢复？(y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                cp "$file" "$template_file"
                echo "✅ 备份恢复完成"
                
                # 验证恢复结果
                if grep -q "pve-panel-clash.js" "$template_file"; then
                    echo "⚠️  警告：恢复后的文件仍包含 Clash 插件引用"
                    echo "   建议手动检查并清理"
                else
                    echo "✅ 恢复后的文件已清理 Clash 插件引用"
                fi
            else
                echo "❌ 取消恢复"
            fi
        else
            echo "⏭️  跳过备份恢复"
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