# FitTracker AI服务API密钥配置

## 🤖 AI服务API密钥

### 1. DeepSeek AI (主要AI服务)
- **环境变量**: `DEEPSEEK_API_KEY`
- **API密钥**: `sk-c4a84c8bbff341cbb3006ecaf84030fe`
- **用途**: 主要AI对话和内容生成服务
- **API文档**: https://api.deepseek.com/
- **状态**: ✅ 已配置

### 2. AIMLAPI (聚合AI服务)
- **环境变量**: `AIMLAPI_API_KEY`
- **API密钥**: `d78968b01cd8440eb7b28d683f3230da`
- **用途**: 支持200+种AI模型的聚合服务
- **状态**: ⚠️ 需要验证
- **验证页面**: https://aimlapi.com/app/billing/verification

### 3. 腾讯混元大模型
- **环境变量**: `TENCENT_SECRET_ID`, `TENCENT_SECRET_KEY`
- **API密钥**: 
  - `TENCENT_SECRET_ID`: `100032618506_100032618506_16a17a3a4bc2eba0534e7b25c4363fc8`
  - `TENCENT_SECRET_KEY`: `sk-O5tVxVeCGTtSgPlaHMuPe9CdmgEUuy2d79yK5rf5Rp5qsI3m`
- **用途**: 腾讯云混元大模型服务
- **API文档**: https://cloud.tencent.com/document/product/1729/101848

### 4. 免费AI服务 (推荐配置)
```bash
# Groq API - 免费额度大，速度快
GROQ_API_KEY=your_groq_api_key_here

# AI Tools API - 无需登录，兼容OpenAI
AITOOLS_API_KEY=your_aitools_key_here

# Together AI - 有免费额度
TOGETHER_API_KEY=your_together_api_key_here

# OpenRouter - 聚合多个模型
OPENROUTER_API_KEY=your_openrouter_api_key_here

# 讯飞星火 - 完全免费
XUNFEI_API_KEY=your_xunfei_key_here

# 百度千帆 - 免费额度
BAIDU_API_KEY=your_baidu_key_here

# 字节扣子 - 开发者免费
BYTEDANCE_API_KEY=your_bytedance_key_here

# 硅基流动 - 免费额度
SILICONFLOW_API_KEY=your_siliconflow_key_here
```

## 🗺️ 地图和位置服务

### 高德地图API
- **环境变量**: `AMAP_API_KEY`
- **API密钥**: `a825cd9231f473717912d3203a62c53e`
- **用途**: 地图服务、位置查询、路径规划
- **API文档**: https://lbs.amap.com/

## 🖼️ 图片和媒体服务

### Pixabay图片API
- **环境变量**: `PIXABAY_API_KEY`
- **API密钥**: `36817612-8c0c4c8c8c8c8c8c8c8c8c8c`
- **用途**: 免费图片搜索和下载
- **API文档**: https://pixabay.com/api/docs/

## 🌤️ 天气服务

### OpenWeather API
- **环境变量**: `OPENWEATHER_API_KEY`
- **用途**: 天气信息查询
- **API文档**: https://openweathermap.org/api

## 📊 服务优先级

系统会按以下优先级自动选择可用的AI服务：

1. **AIMLAPI** (你的密钥) - 最高优先级
2. **AI Tools** (无需登录) - 立即可用
3. **Groq** (免费额度大) - 推荐
4. **讯飞星火** (完全免费) - 国内服务
5. **百度千帆** (免费额度) - 国内服务
6. **腾讯混元** (免费版本) - 国内服务
7. **字节扣子** (开发者免费) - 国内服务
8. **硅基流动** (免费额度) - 国内服务
9. **DeepSeek** (备用) - 费用较高

## 🔒 安全注意事项

1. **永远不要**将API密钥提交到版本控制
2. **永远不要**在日志中输出API密钥
3. **永远不要**在错误消息中暴露API密钥
4. 使用 `.gitignore` 忽略包含密钥的文件
5. 定期审查代码中的密钥使用情况
6. 定期轮换API密钥
7. 监控API使用情况
