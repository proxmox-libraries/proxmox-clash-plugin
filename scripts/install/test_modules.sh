#!/bin/bash

# 测试模块加载脚本
# 验证所有模块是否能正确加载

set -e

echo "🧪 测试模块加载..."
echo "=================="

# 获取脚本目录
SCRIPT_DIR="$(dirname "$0")"
echo "脚本目录: $SCRIPT_DIR"

# 测试加载工具模块
echo ""
echo "📦 测试工具模块加载..."

echo "1. 测试日志模块..."
if [ -f "$SCRIPT_DIR/utils/logger.sh" ]; then
    source "$SCRIPT_DIR/utils/logger.sh"
    echo "   ✅ 日志模块加载成功"
    log_info "测试日志信息"
    log_warn "测试警告信息"
    log_error "测试错误信息"
    log_step "测试步骤信息"
else
    echo "   ❌ 日志模块不存在"
fi

echo "2. 测试参数解析模块..."
if [ -f "$SCRIPT_DIR/utils/argument_parser.sh" ]; then
    source "$SCRIPT_DIR/utils/argument_parser.sh"
    echo "   ✅ 参数解析模块加载成功"
    show_help
else
    echo "   ❌ 参数解析模块不存在"
fi

echo "3. 测试辅助函数模块..."
if [ -f "$SCRIPT_DIR/utils/helpers.sh" ]; then
    source "$SCRIPT_DIR/utils/helpers.sh"
    echo "   ✅ 辅助函数模块加载成功"
    echo "   PVE UI 目录: $(detect_pve_ui_dir)"
else
    echo "   ❌ 辅助函数模块不存在"
fi

# 测试加载功能模块
echo ""
echo "🔧 测试功能模块加载..."

echo "4. 测试依赖检查模块..."
if [ -f "$SCRIPT_DIR/functions/dependency_checker.sh" ]; then
    source "$SCRIPT_DIR/functions/dependency_checker.sh"
    echo "   ✅ 依赖检查模块加载成功"
else
    echo "   ❌ 依赖检查模块不存在"
fi

echo "5. 测试文件下载模块..."
if [ -f "$SCRIPT_DIR/functions/file_downloader.sh" ]; then
    source "$SCRIPT_DIR/functions/file_downloader.sh"
    echo "   ✅ 文件下载模块加载成功"
else
    echo "   ❌ 文件下载模块不存在"
fi

echo "6. 测试API安装模块..."
if [ -f "$SCRIPT_DIR/functions/api_installer.sh" ]; then
    source "$SCRIPT_DIR/functions/api_installer.sh"
    echo "   ✅ API安装模块加载成功"
else
    echo "   ❌ API安装模块不存在"
fi

echo "7. 测试服务安装模块..."
if [ -f "$SCRIPT_DIR/functions/service_installer.sh" ]; then
    source "$SCRIPT_DIR/functions/service_installer.sh"
    echo "   ✅ 服务安装模块加载成功"
else
    echo "   ❌ 服务安装模块不存在"
fi

echo "8. 测试配置创建模块..."
if [ -f "$SCRIPT_DIR/functions/config_creator.sh" ]; then
    source "$SCRIPT_DIR/functions/config_creator.sh"
    echo "   ✅ 配置创建模块加载成功"
else
    echo "   ❌ 配置创建模块不存在"
fi

echo "9. 测试链接创建模块..."
if [ -f "$SCRIPT_DIR/functions/link_creator.sh" ]; then
    source "$SCRIPT_DIR/functions/link_creator.sh"
    echo "   ✅ 链接创建模块加载成功"
else
    echo "   ❌ 链接创建模块不存在"
fi

echo "10. 测试结果显示模块..."
if [ -f "$SCRIPT_DIR/functions/result_display.sh" ]; then
    source "$SCRIPT_DIR/functions/result_display.sh"
    echo "   ✅ 结果显示模块加载成功"
else
    echo "   ❌ 结果显示模块不存在"
fi

echo ""
echo "🎯 测试完成！"
echo "如果所有模块都显示 ✅，说明模块化重构成功！"
