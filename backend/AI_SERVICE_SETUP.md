# 🤖 FitTracker AI服务配置指南

## 📋 概述

FitTracker集成了多个LLM API，提供智能健身教练和营养师服务。系统支持优先级切换，当一个API不可用时自动切换到备用API。

## 🔑 支持的LLM提供商（按优先级）

### 1. DeepSeek API ⭐ （最高优先级）
- **环境变量**: `DEEPSEEK_API_KEY`
- **当前配置值**: `sk-c4a84c8bbff341cbb3006ecaf84030fe`
- **API文档**: https://api.deepseek.com/
- **模型**: `deepseek-chat`
- **特点**: 高质量中文对话，响应速度快

### 2. 腾讯混元 API
- **环境变量**: 
  - `TENCENT_SECRET_ID`: `100032618506_100032618506_16a17a3a4bc2eba0534e7b25c4363fc8`
  - `TENCENT_SECRET_KEY`: `sk-O5tVxVeCGTtSgPlaHMuPe9CdmgEUuy2d79yK5rf5Rp5qsI3m`
- **API文档**: https://cloud.tencent.com/document/product/1729/101848
- **模型**: `hunyuan-lite`
- **特点**: 国内服务，稳定可靠

### 3. AIMLAPI
- **环境变量**: `AIMLAPI_API_KEY`
- **当前配置值**: `d78968b01cd8440eb7b28d683f3230da`
- **API文档**: https://aimlapi.com/
- **模型**: `gpt-3.5-turbo`
- **特点**: 支持200+种AI模型

## 🚀 快速配置

### 方法1: 使用环境变量文件

创建 `backend/.env` 文件：

```bash
# DeepSeek API (最高优先级)
DEEPSEEK_API_KEY=sk-c4a84c8bbff341cbb3006ecaf84030fe

# 腾讯混元 API
TENCENT_SECRET_ID=100032618506_100032618506_16a17a3a4bc2eba0534e7b25c4363fc8
TENCENT_SECRET_KEY=sk-O5tVxVeCGTtSgPlaHMuPe9CdmgEUuy2d79yK5rf5Rp5qsI3m

# AIMLAPI
AIMLAPI_API_KEY=d78968b01cd8440eb7b28d683f3230da

# 数据库配置
DATABASE_URL=postgresql://user:password@localhost:5432/fittracker
REDIS_URL=redis://localhost:6379/0
```

### 方法2: 系统环境变量

```bash
export DEEPSEEK_API_KEY=sk-c4a84c8bbff341cbb3006ecaf84030fe
export TENCENT_SECRET_ID=100032618506_100032618506_16a17a3a4bc2eba0534e7b25c4363fc8
export TENCENT_SECRET_KEY=sk-O5tVxVeCGTtSgPlaHMuPe9CdmgEUuy2d79yK5rf5Rp5qsI3m
export AIMLAPI_API_KEY=d78968b01cd8440eb7b28d683f3230da
```

## 📦 依赖安装

```bash
cd backend
pip install aiohttp requests python-dotenv
```

## 🎯 AI服务功能

### 1. AI健身教练 (`ai_coach_service.py`)

**功能：**
- ✅ 个性化训练计划生成
- ✅ 动作指导和纠正
- ✅ 训练进度分析
- ✅ 实时对话交流

**使用示例：**
```python
from app.services.ai_coach_service import ai_coach_service

# 生成训练计划
user_profile = {
    "age": 25,
    "gender": "男",
    "height": 175,
    "weight": 70,
    "fitness_level": "初学者",
    "goals": "减脂",
    "available_time": 3  # 每周小时数
}

result = await ai_coach_service.generate_workout_plan(user_profile)
```

### 2. AI营养师 (`ai_nutritionist_service.py`)

**功能：**
- ✅ 个性化饮食计划
- ✅ 食物营养分析
- ✅ 健康饮食建议
- ✅ 宏量营养素计算
- ✅ 实时对话交流

**使用示例：**
```python
from app.services.ai_nutritionist_service import ai_nutritionist_service

# 生成饮食计划
user_profile = {
    "age": 25,
    "gender": "男",
    "height": 175,
    "weight": 70,
    "target_weight": 65,
    "activity_level": "中等",
    "health_goals": "减脂"
}

result = await ai_nutritionist_service.generate_meal_plan(user_profile)
```

### 3. LLM管理器 (`llm_manager.py`)

**功能：**
- ✅ 多API优先级切换
- ✅ 自动故障转移
- ✅ 统一调用接口
- ✅ 服务状态监控

**使用示例：**
```python
from app.services.llm_manager import call_llm, get_llm_status

# 调用LLM
messages = [
    {"role": "user", "content": "如何提高深蹲的动作标准？"}
]
response = await call_llm(messages)
print(response['content'])

# 检查服务状态
status = get_llm_status()
print(status)
# 输出：{
#   "available_providers": ["DeepSeek", "腾讯混元", "AIMLAPI"],
#   "provider_status": {
#     "DeepSeek": True,
#     "腾讯混元": True,
#     "AIMLAPI": True
#   },
#   "total_providers": 3
# }
```

## 🔄 API优先级切换机制

系统会按以下顺序尝试API：

1. **DeepSeek** → 失败 →
2. **腾讯混元** → 失败 →
3. **AIMLAPI** → 失败 →
4. **模拟响应** (降级方案)

每次调用时，系统会：
1. 检查API是否配置（API密钥存在）
2. 尝试调用API
3. 如果失败，记录错误并尝试下一个
4. 返回第一个成功的响应

## 🛠️ 调试和监控

### 查看日志

```python
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# LLM管理器会自动记录：
# - 尝试使用的提供商
# - 成功/失败状态
# - 错误信息
```

### 测试API连接

```python
from app.services.llm_manager import llm_manager

# 获取可用提供商
available = llm_manager.get_available_providers()
print(f"可用的提供商: {available}")

# 获取所有提供商状态
status = llm_manager.get_provider_status()
print(f"提供商状态: {status}")
```

## ⚠️ 注意事项

1. **API密钥安全**
   - 不要将API密钥提交到版本控制
   - 使用环境变量或密钥管理服务
   - 定期轮换API密钥

2. **API配额管理**
   - DeepSeek: 根据账户配额
   - 腾讯混元: 根据账户配额
   - AIMLAPI: 根据账户配额

3. **错误处理**
   - 所有AI服务调用都已包含异常处理
   - 失败时会自动降级到备用方案
   - 查看日志了解详细错误信息

4. **性能优化**
   - LLM调用是异步的（使用async/await）
   - 可以并发处理多个请求
   - 考虑实现缓存机制避免重复调用

## 🔧 故障排除

### 问题1: 所有API都失败

**解决方案:**
- 检查网络连接
- 验证API密钥是否正确
- 检查API配额是否用完
- 查看详细错误日志

### 问题2: 响应是模拟数据

**原因:** 未配置任何API密钥

**解决方案:**
```bash
# 至少配置一个API
export DEEPSEEK_API_KEY=your_key_here
```

### 问题3: 切换不生效

**解决方案:**
- 重启应用以重新加载环境变量
- 检查LLM管理器初始化日志
- 验证环境变量是否正确设置

## 📚 相关文档

- [DeepSeek API文档](https://api.deepseek.com/)
- [腾讯混元API文档](https://cloud.tencent.com/document/product/1729/101848)
- [AIMLAPI文档](https://aimlapi.com/)

## 🎉 完成！

现在你的FitTracker应用已经集成了强大的AI功能！

**下一步:**
1. 创建API endpoints暴露AI服务
2. 在前端集成AI对话界面
3. 添加用户反馈和优化机制

---

*最后更新：2025-09-30*
*版本：v1.0*
