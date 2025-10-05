#!/bin/bash

# 自动修复 Go 模型以匹配数据库 Schema
# 使用方法: ./auto_fix_models.sh <diff_report.json>

set -e

DIFF_REPORT="$1"
MODELS_DIR="./backend-go/internal/models"
BACKUP_DIR="./backup_models_$(date +%Y%m%d_%H%M%S)"

if [ -z "$DIFF_REPORT" ] || [ ! -f "$DIFF_REPORT" ]; then
    echo "错误: 请提供有效的差异报告文件"
    echo "使用方法: $0 <diff_report.json>"
    exit 1
fi

echo "开始自动修复 Go 模型..."
echo "差异报告: $DIFF_REPORT"
echo "模型目录: $MODELS_DIR"

# 创建备份目录
mkdir -p "$BACKUP_DIR"
echo "已创建备份目录: $BACKUP_DIR"

# 备份原始模型文件
cp -r "$MODELS_DIR" "$BACKUP_DIR/"
echo "已备份原始模型文件"

# 解析差异报告
python3 -c "
import json
import sys
import os

def fix_models(diff_report_path, models_dir):
    with open(diff_report_path, 'r', encoding='utf-8') as f:
        diff_report = json.load(f)
    
    models_file = os.path.join(models_dir, 'models.go')
    if not os.path.exists(models_file):
        print(f'错误: 模型文件不存在: {models_file}')
        return False
    
    # 读取模型文件
    with open(models_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # 处理每个模型的差异
    for model_name, diff in diff_report.items():
        print(f'处理模型: {model_name}')
        
        # 处理缺失的字段
        for column in diff.get('column_missing_in_model', []):
            print(f'  添加缺失字段: {column}')
            # 这里需要根据具体字段类型添加相应的 Go 字段
            # 暂时跳过，需要手动处理
        
        # 处理类型不匹配
        for mismatch in diff.get('type_mismatch', []):
            field = mismatch['field']
            model_type = mismatch['model_type']
            db_type = mismatch['db_type']
            print(f'  修复类型不匹配: {field} ({model_type} -> {db_type})')
            
            # 根据数据库类型确定 Go 类型
            go_type_map = {
                'BIGINT': 'uint64',
                'BIGSERIAL': 'uint64',
                'INTEGER': 'uint',
                'INT': 'uint',
                'VARCHAR': 'string',
                'TEXT': 'string',
                'DECIMAL': 'float64',
                'NUMERIC': 'float64',
                'DOUBLE PRECISION': 'float64',
                'BOOLEAN': 'bool',
                'BOOL': 'bool',
                'TIMESTAMP': 'time.Time',
                'TIMESTAMPTZ': 'time.Time'
            }
            
            if db_type.split()[0] in go_type_map:
                new_go_type = go_type_map[db_type.split()[0]]
                # 替换字段类型
                pattern = f'(\s+{field}\s+){model_type}(\s+`[^`]*`)'
                replacement = f'\g<1>{new_go_type}\g<2>'
                content = re.sub(pattern, replacement, content)
        
        # 处理标签不匹配
        for tag_mismatch in diff.get('tag_mismatch', []):
            field = tag_mismatch['field']
            issue = tag_mismatch['issue']
            print(f'  修复标签不匹配: {field} ({issue})')
            
            if issue == 'primary_key_mismatch':
                # 添加或移除 primaryKey 标签
                if tag_mismatch['db_primary']:
                    # 添加 primaryKey
                    pattern = f'(\s+{field}\s+[^`]+`[^`]*gorm:\"[^\"]*?)(\")'
                    replacement = f'\g<1>;primaryKey\g<2>'
                    content = re.sub(pattern, replacement, content)
                else:
                    # 移除 primaryKey
                    pattern = f'(\s+{field}\s+[^`]+`[^`]*gorm:\"[^\"]*?)primaryKey;?([^\"]*\")'
                    replacement = f'\g<1>\g<2>'
                    content = re.sub(pattern, replacement, content)
    
    # 如果有修改，写回文件
    if content != original_content:
        with open(models_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'已更新模型文件: {models_file}')
        return True
    else:
        print('没有需要修复的内容')
        return False

import re
fix_models('$DIFF_REPORT', '$MODELS_DIR')
"

if [ $? -eq 0 ]; then
    echo "模型修复完成"
    
    # 运行 go fmt
    echo "运行 go fmt..."
    cd "$MODELS_DIR/.."
    go fmt ./models/
    
    # 运行 go vet
    echo "运行 go vet..."
    go vet ./models/
    
    # 尝试编译
    echo "尝试编译..."
    go build ./models/
    
    echo "修复成功！"
else
    echo "修复失败，请检查错误信息"
    exit 1
fi

echo "备份文件位置: $BACKUP_DIR"
echo "如需回滚，请执行: cp -r $BACKUP_DIR/models/* $MODELS_DIR/"
