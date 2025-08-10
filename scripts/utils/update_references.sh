#!/bin/bash

# 批量更新文档文件中的 install.sh 引用
# 将其替换为 install.sh

set -e

echo "🔍 开始查找并更新 install.sh 引用..."

# 查找所有包含 install.sh 的文件
files=$(grep -l "install_direct\.sh" $(find . -name "*.md" -o -name "*.txt" -o -name "*.sh") 2>/dev/null | grep -v ".git" | sort)

if [ -z "$files" ]; then
    echo "✅ 没有找到需要更新的文件"
    exit 0
fi

echo "📁 找到以下文件需要更新："
echo "$files"
echo ""

# 备份计数
backup_count=0
update_count=0

# 更新每个文件
for file in $files; do
    echo "🔄 更新文件: $file"
    
    # 创建备份
    cp "$file" "$file.backup"
    ((backup_count++))
    
    # 执行替换 (兼容 macOS)
    if sed -i '' 's/install_direct\.sh/install.sh/g' "$file"; then
        echo "  ✅ 更新成功"
        ((update_count++))
    else
        echo "  ❌ 更新失败"
        # 恢复备份
        mv "$file.backup" "$file"
    fi
done

echo ""
echo "📊 更新完成！"
echo "  📁 处理文件数: $(echo "$files" | wc -l)"
echo "  💾 备份文件数: $backup_count"
echo "  ✅ 成功更新数: $update_count"
echo ""
echo "💡 提示："
echo "  - 备份文件以 .backup 结尾"
echo "  - 如需恢复，请运行: mv file.backup file"
echo "  - 建议检查更新后的文件内容"
echo ""
echo "🚀 现在可以提交更改了："
echo "  git add ."
echo "  git commit -m 'docs: update all references from install.sh to install.sh'"
echo "  git push origin main"
