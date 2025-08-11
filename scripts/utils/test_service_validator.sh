#!/bin/bash

# 测试服务验证工具脚本

echo "🧪 测试 Proxmox Clash 插件服务验证工具"
echo "========================================"
echo ""

# 检查服务验证工具是否存在
if [ -f "scripts/utils/service_validator.sh" ]; then
    echo "✅ 服务验证工具存在"
    
    # 测试基本功能
    echo ""
    echo "📋 测试基本功能..."
    
    # 模拟测试环境
    export CLASH_DIR="$(pwd)"
    export SERVICE_FILE="/tmp/test-clash-meta.service"
    export SOURCE_SERVICE_FILE="service/clash-meta.service"
    
    # 创建测试服务文件
    if [ -f "service/clash-meta.service" ]; then
        echo "✅ 源服务文件存在"
        
        # 测试快速验证函数
        source "scripts/utils/service_validator.sh"
        
        echo ""
        echo "🔍 测试快速验证函数..."
        if quick_verify_service "service/clash-meta.service" "service/clash-meta.service"; then
            echo "✅ 快速验证函数工作正常"
        else
            echo "❌ 快速验证函数测试失败"
        fi
        
        echo ""
        echo "🎯 测试完成！"
        echo ""
        echo "📝 说明："
        echo "  - 此测试脚本验证了服务验证工具的基本功能"
        echo "  - 在实际安装过程中，验证工具会自动运行"
        echo "  - 如果遇到问题，仍可使用 fix_service_installation.sh 脚本"
        
    else
        echo "❌ 源服务文件不存在，无法进行完整测试"
    fi
    
else
    echo "❌ 服务验证工具不存在"
    echo "请确保 scripts/utils/service_validator.sh 文件存在"
fi

echo ""
echo "🏁 测试结束"
