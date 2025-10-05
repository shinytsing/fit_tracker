#!/usr/bin/env python3
"""
Go 模型与数据库 Schema 比对工具
自动检测 Go struct 与 PostgreSQL 表字段的差异
"""

import re
import json
import argparse
import os
from typing import Dict, List, Any, Optional
from dataclasses import dataclass

@dataclass
class FieldInfo:
    name: str
    go_type: str
    gorm_tags: Dict[str, str]
    json_tag: str
    db_column: Optional[str] = None
    db_type: Optional[str] = None
    is_primary: bool = False
    is_nullable: bool = True
    default_value: Optional[str] = None

@dataclass
class ModelInfo:
    name: str
    table_name: str
    fields: List[FieldInfo]

class GoModelParser:
    """解析 Go 模型文件"""
    
    def __init__(self):
        self.models = {}
    
    def parse_file(self, file_path: str):
        """解析单个 Go 文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            self._parse_content(content)
        except Exception as e:
            print(f"解析文件 {file_path} 失败: {e}")
    
    def _parse_content(self, content: str):
        """解析文件内容"""
        # 匹配 struct 定义
        struct_pattern = r'type\s+(\w+)\s+struct\s*\{([^}]+)\}'
        
        for match in re.finditer(struct_pattern, content, re.MULTILINE | re.DOTALL):
            struct_name = match.group(1)
            struct_body = match.group(2)
            
            # 跳过请求/响应模型
            if any(skip in struct_name.lower() for skip in ['request', 'response', 'req', 'resp']):
                continue
                
            model_info = self._parse_struct(struct_name, struct_body)
            if model_info:
                self.models[struct_name] = model_info
    
    def _parse_struct(self, name: str, body: str) -> Optional[ModelInfo]:
        """解析单个 struct"""
        fields = []
        table_name = self._to_snake_case(name)
        
        # 解析字段
        field_lines = [line.strip() for line in body.split('\n') if line.strip()]
        
        for line in field_lines:
            if line.startswith('//') or not line:
                continue
                
            field_info = self._parse_field(line)
            if field_info:
                fields.append(field_info)
        
        if not fields:
            return None
            
        return ModelInfo(name=name, table_name=table_name, fields=fields)
    
    def _parse_field(self, line: str) -> Optional[FieldInfo]:
        """解析单个字段"""
        # 匹配字段定义: Name Type `tags`
        field_pattern = r'(\w+)\s+([^`]+?)\s*`([^`]*)`'
        match = re.match(field_pattern, line)
        
        if not match:
            return None
            
        field_name = match.group(1)
        go_type = match.group(2).strip()
        tags = match.group(3)
        
        # 解析 gorm tags
        gorm_tags = self._parse_gorm_tags(tags)
        
        # 解析 json tag
        json_tag = self._parse_json_tag(tags)
        
        # 获取数据库列名
        db_column = gorm_tags.get('column', self._to_snake_case(field_name))
        
        return FieldInfo(
            name=field_name,
            go_type=go_type,
            gorm_tags=gorm_tags,
            json_tag=json_tag,
            db_column=db_column,
            is_primary='primaryKey' in gorm_tags,
            is_nullable='not null' not in gorm_tags.get('gorm', '')
        )
    
    def _parse_gorm_tags(self, tags: str) -> Dict[str, str]:
        """解析 gorm tags"""
        gorm_match = re.search(r'gorm:"([^"]*)"', tags)
        if not gorm_match:
            return {}
        
        gorm_content = gorm_match.group(1)
        gorm_tags = {}
        
        # 解析 gorm tag 内容
        parts = gorm_content.split(';')
        for part in parts:
            part = part.strip()
            if ':' in part:
                key, value = part.split(':', 1)
                gorm_tags[key] = value
            else:
                gorm_tags[part] = 'true'
        
        return gorm_tags
    
    def _parse_json_tag(self, tags: str) -> str:
        """解析 json tag"""
        json_match = re.search(r'json:"([^"]*)"', tags)
        if json_match:
            return json_match.group(1)
        return ""
    
    def _to_snake_case(self, name: str) -> str:
        """转换为下划线命名"""
        s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
        return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

class DatabaseSchemaParser:
    """解析数据库 Schema"""
    
    def __init__(self):
        self.tables = {}
    
    def parse_schema_file(self, file_path: str):
        """解析数据库 schema 文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            self._parse_content(content)
        except Exception as e:
            print(f"解析 schema 文件 {file_path} 失败: {e}")
    
    def _parse_content(self, content: str):
        """解析 schema 内容"""
        # 匹配 CREATE TABLE 语句
        table_pattern = r'CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(\w+)\s*\(([^;]+)\)'
        
        for match in re.finditer(table_pattern, content, re.MULTILINE | re.DOTALL):
            table_name = match.group(1)
            table_body = match.group(2)
            
            columns = self._parse_table_columns(table_body)
            if columns:
                self.tables[table_name] = columns
    
    def _parse_table_columns(self, table_body: str) -> Dict[str, Dict[str, Any]]:
        """解析表列定义"""
        columns = {}
        lines = [line.strip() for line in table_body.split('\n') if line.strip()]
        
        for line in lines:
            if line.startswith('--') or line.startswith('PRIMARY KEY') or line.startswith('FOREIGN KEY'):
                continue
                
            column_info = self._parse_column(line)
            if column_info:
                columns[column_info['name']] = column_info
        
        return columns
    
    def _parse_column(self, line: str) -> Optional[Dict[str, Any]]:
        """解析单个列定义"""
        # 移除末尾的逗号
        line = line.rstrip(',')
        
        # 匹配列定义: name type constraints
        column_pattern = r'(\w+)\s+([^,\s]+(?:\s+[^,\s]+)*?)(?:\s+(.*))?$'
        match = re.match(column_pattern, line)
        
        if not match:
            return None
            
        column_name = match.group(1)
        column_type = match.group(2).strip()
        constraints = match.group(3) or ""
        
        # 解析约束
        is_primary = 'PRIMARY KEY' in constraints
        is_nullable = 'NOT NULL' not in constraints
        has_default = 'DEFAULT' in constraints
        
        # 提取默认值
        default_value = None
        if has_default:
            default_match = re.search(r'DEFAULT\s+([^,\s]+)', constraints)
            if default_match:
                default_value = default_match.group(1)
        
        return {
            'name': column_name,
            'type': column_type,
            'is_primary': is_primary,
            'is_nullable': is_nullable,
            'default_value': default_value,
            'constraints': constraints
        }

class ModelDiffAnalyzer:
    """分析模型差异"""
    
    def __init__(self, go_models: Dict[str, ModelInfo], db_tables: Dict[str, Dict]):
        self.go_models = go_models
        self.db_tables = db_tables
        self.diff_report = {}
    
    def analyze(self) -> Dict[str, Any]:
        """分析所有差异"""
        for model_name, model_info in self.go_models.items():
            table_name = model_info.table_name
            
            if table_name not in self.db_tables:
                print(f"警告: 表 {table_name} 在数据库中不存在")
                continue
            
            table_columns = self.db_tables[table_name]
            diff = self._analyze_model_diff(model_info, table_columns)
            
            if any(diff.values()):
                self.diff_report[model_name] = diff
        
        return self.diff_report
    
    def _analyze_model_diff(self, model: ModelInfo, table_columns: Dict) -> Dict[str, List]:
        """分析单个模型的差异"""
        diff = {
            'column_missing_in_model': [],
            'field_missing_in_db': [],
            'type_mismatch': [],
            'tag_mismatch': []
        }
        
        # 检查数据库列是否在模型中存在
        for column_name, column_info in table_columns.items():
            field_found = False
            for field in model.fields:
                if field.db_column == column_name:
                    field_found = True
                    break
            
            if not field_found:
                diff['column_missing_in_model'].append(column_name)
        
        # 检查模型字段是否在数据库中存在
        for field in model.fields:
            if field.db_column not in table_columns:
                diff['field_missing_in_db'].append(field.name)
                continue
            
            column_info = table_columns[field.db_column]
            
            # 检查类型匹配
            if not self._is_type_compatible(field.go_type, column_info['type']):
                diff['type_mismatch'].append({
                    'field': field.name,
                    'model_type': field.go_type,
                    'db_type': column_info['type']
                })
            
            # 检查约束匹配
            if field.is_primary != column_info['is_primary']:
                diff['tag_mismatch'].append({
                    'field': field.name,
                    'issue': 'primary_key_mismatch',
                    'model_primary': field.is_primary,
                    'db_primary': column_info['is_primary']
                })
        
        return diff
    
    def _is_type_compatible(self, go_type: str, db_type: str) -> bool:
        """检查类型兼容性"""
        # Go 类型到数据库类型的映射
        type_mapping = {
            'string': ['VARCHAR', 'TEXT', 'CHAR'],
            'int': ['INTEGER', 'INT', 'SMALLINT'],
            'int64': ['BIGINT', 'BIGSERIAL'],
            'uint': ['INTEGER', 'INT'],
            'uint64': ['BIGINT', 'BIGSERIAL'],
            'float64': ['DECIMAL', 'NUMERIC', 'DOUBLE PRECISION', 'REAL'],
            'bool': ['BOOLEAN', 'BOOL'],
            'time.Time': ['TIMESTAMP', 'TIMESTAMPTZ', 'DATE']
        }
        
        # 清理类型名称
        go_type = go_type.replace('*', '').replace('[]', '')
        db_type = db_type.upper().split()[0]  # 取第一个词
        
        # 检查映射
        for go_t, db_types in type_mapping.items():
            if go_t in go_type and db_type in db_types:
                return True
        
        return False

def main():
    parser = argparse.ArgumentParser(description='比对 Go 模型与数据库 Schema')
    parser.add_argument('--schema', required=True, help='数据库 schema 文件路径')
    parser.add_argument('--models', required=True, help='Go 模型文件目录')
    parser.add_argument('--out', required=True, help='输出差异报告文件路径')
    
    args = parser.parse_args()
    
    # 解析 Go 模型
    go_parser = GoModelParser()
    models_dir = args.models
    
    if os.path.isfile(models_dir):
        go_parser.parse_file(models_dir)
    else:
        for root, dirs, files in os.walk(models_dir):
            for file in files:
                if file.endswith('.go'):
                    go_parser.parse_file(os.path.join(root, file))
    
    print(f"解析到 {len(go_parser.models)} 个 Go 模型")
    
    # 解析数据库 Schema
    db_parser = DatabaseSchemaParser()
    db_parser.parse_schema_file(args.schema)
    
    print(f"解析到 {len(db_parser.tables)} 个数据库表")
    
    # 分析差异
    analyzer = ModelDiffAnalyzer(go_parser.models, db_parser.tables)
    diff_report = analyzer.analyze()
    
    # 输出报告
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    with open(args.out, 'w', encoding='utf-8') as f:
        json.dump(diff_report, f, indent=2, ensure_ascii=False)
    
    print(f"差异报告已保存到: {args.out}")
    
    # 打印摘要
    total_models = len(go_parser.models)
    models_with_diff = len(diff_report)
    
    print(f"\n=== 差异分析摘要 ===")
    print(f"总模型数: {total_models}")
    print(f"有差异的模型: {models_with_diff}")
    
    for model_name, diff in diff_report.items():
        print(f"\n模型 {model_name}:")
        for diff_type, items in diff.items():
            if items:
                print(f"  {diff_type}: {len(items)} 项")
                for item in items[:3]:  # 只显示前3项
                    print(f"    - {item}")
                if len(items) > 3:
                    print(f"    ... 还有 {len(items) - 3} 项")

if __name__ == '__main__':
    main()
