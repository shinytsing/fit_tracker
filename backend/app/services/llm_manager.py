"""
多LLM API管理器 - 支持优先级切换的AI服务
支持DeepSeek、腾讯混元、AIMLAPI等多个LLM提供商
"""
import os
import json
import requests
import asyncio
import aiohttp
from typing import Dict, List, Optional, Any, Union
from datetime import datetime
from abc import ABC, abstractmethod
import logging

logger = logging.getLogger(__name__)

class LLMProvider(ABC):
    """LLM提供商抽象基类"""
    
    @abstractmethod
    async def call(self, messages: List[Dict[str, str]], **kwargs) -> Dict[str, Any]:
        """调用LLM API"""
        pass
    
    @abstractmethod
    def get_name(self) -> str:
        """获取提供商名称"""
        pass
    
    @abstractmethod
    def is_available(self) -> bool:
        """检查是否可用"""
        pass

class DeepSeekProvider(LLMProvider):
    """DeepSeek API提供商"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.deepseek.com/v1/chat/completions"
        self.model = "deepseek-chat"
    
    def get_name(self) -> str:
        return "DeepSeek"
    
    def is_available(self) -> bool:
        return bool(self.api_key)
    
    async def call(self, messages: List[Dict[str, str]], **kwargs) -> Dict[str, Any]:
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        data = {
            "model": self.model,
            "messages": messages,
            "temperature": kwargs.get("temperature", 0.7),
            "max_tokens": kwargs.get("max_tokens", 2000)
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(self.base_url, headers=headers, json=data) as response:
                if response.status != 200:
                    error_text = await response.text()
                    raise Exception(f"DeepSeek API错误 {response.status}: {error_text}")
                
                result = await response.json()
                return {
                    "content": result["choices"][0]["message"]["content"],
                    "provider": self.get_name(),
                    "model": result.get("model", self.model),
                    "timestamp": datetime.now().isoformat()
                }

class TencentHunyuanProvider(LLMProvider):
    """腾讯混元API提供商"""
    
    def __init__(self, secret_id: str, secret_key: str):
        self.secret_id = secret_id
        self.secret_key = secret_key
        self.base_url = "https://hunyuan.tencentcloudapi.com"
        self.model = "hunyuan-lite"
    
    def get_name(self) -> str:
        return "腾讯混元"
    
    def is_available(self) -> bool:
        return bool(self.secret_id and self.secret_key)
    
    async def call(self, messages: List[Dict[str, str]], **kwargs) -> Dict[str, Any]:
        # 腾讯混元API调用实现
        # 注意：这里简化实现，实际需要腾讯云签名认证
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.secret_key}"  # 简化实现
        }
        
        data = {
            "Model": self.model,
            "Messages": messages,
            "Temperature": kwargs.get("temperature", 0.7),
            "MaxTokens": kwargs.get("max_tokens", 2000)
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(self.base_url, headers=headers, json=data) as response:
                if response.status != 200:
                    error_text = await response.text()
                    raise Exception(f"腾讯混元API错误 {response.status}: {error_text}")
                
                result = await response.json()
                return {
                    "content": result["Response"]["Choices"][0]["Message"]["Content"],
                    "provider": self.get_name(),
                    "model": self.model,
                    "timestamp": datetime.now().isoformat()
                }

class AIMLAPIProvider(LLMProvider):
    """AIMLAPI提供商"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.aimlapi.com/v1/chat/completions"
        self.model = "gpt-3.5-turbo"
    
    def get_name(self) -> str:
        return "AIMLAPI"
    
    def is_available(self) -> bool:
        return bool(self.api_key)
    
    async def call(self, messages: List[Dict[str, str]], **kwargs) -> Dict[str, Any]:
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        data = {
            "model": self.model,
            "messages": messages,
            "temperature": kwargs.get("temperature", 0.7),
            "max_tokens": kwargs.get("max_tokens", 2000)
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(self.base_url, headers=headers, json=data) as response:
                if response.status != 200:
                    error_text = await response.text()
                    raise Exception(f"AIMLAPI错误 {response.status}: {error_text}")
                
                result = await response.json()
                return {
                    "content": result["choices"][0]["message"]["content"],
                    "provider": self.get_name(),
                    "model": result.get("model", self.model),
                    "timestamp": datetime.now().isoformat()
                }

class LLMManager:
    """多LLM管理器 - 支持优先级切换"""
    
    def __init__(self):
        self.providers: List[LLMProvider] = []
        self._setup_providers()
    
    def _setup_providers(self):
        """按优先级设置提供商"""
        
        # 1. DeepSeek (最高优先级)
        deepseek_key = os.getenv('DEEPSEEK_API_KEY', 'sk-c4a84c8bbff341cbb3006ecaf84030fe')
        if deepseek_key:
            self.providers.append(DeepSeekProvider(deepseek_key))
            logger.info("已加载 DeepSeek API")
        
        # 2. 腾讯混元
        tencent_secret_id = os.getenv('TENCENT_SECRET_ID', '100032618506_100032618506_16a17a3a4bc2eba0534e7b25c4363fc8')
        tencent_secret_key = os.getenv('TENCENT_SECRET_KEY', 'sk-O5tVxVeCGTtSgPlaHMuPe9CdmgEUuy2d79yK5rf5Rp5qsI3m')
        if tencent_secret_id and tencent_secret_key:
            self.providers.append(TencentHunyuanProvider(tencent_secret_id, tencent_secret_key))
            logger.info("已加载 腾讯混元 API")
        
        # 3. AIMLAPI
        aimlapi_key = os.getenv('AIMLAPI_API_KEY', 'd78968b01cd8440eb7b28d683f3230da')
        if aimlapi_key:
            self.providers.append(AIMLAPIProvider(aimlapi_key))
            logger.info("已加载 AIMLAPI")
        
        if not self.providers:
            logger.warning("未配置任何LLM API，将使用模拟响应")
    
    async def call(self, messages: List[Dict[str, str]], **kwargs) -> Dict[str, Any]:
        """调用LLM，自动尝试可用的提供商"""
        
        if not self.providers:
            return self._mock_response(messages)
        
        last_error = None
        
        # 按优先级尝试每个提供商
        for provider in self.providers:
            if not provider.is_available():
                continue
            
            try:
                logger.info(f"尝试使用 {provider.get_name()}")
                response = await provider.call(messages, **kwargs)
                logger.info(f"{provider.get_name()} 调用成功")
                return response
                
            except Exception as e:
                logger.warning(f"{provider.get_name()} 调用失败: {str(e)}")
                last_error = e
                continue
        
        if last_error:
            raise Exception(f"所有LLM提供商都失败: {str(last_error)}")
        
        raise Exception("没有可用的LLM提供商")
    
    def _mock_response(self, messages: List[Dict[str, str]]) -> Dict[str, Any]:
        """模拟响应（当没有配置API时）"""
        return {
            "content": "这是一个模拟的AI响应。请配置LLM API密钥以获得真实的AI功能。",
            "provider": "Mock",
            "model": "mock-model",
            "timestamp": datetime.now().isoformat()
        }
    
    def get_available_providers(self) -> List[str]:
        """获取可用的提供商列表"""
        return [provider.get_name() for provider in self.providers if provider.is_available()]
    
    def get_provider_status(self) -> Dict[str, bool]:
        """获取所有提供商的状态"""
        return {provider.get_name(): provider.is_available() for provider in self.providers}

# 全局LLM管理器实例
llm_manager = LLMManager()

# 便捷函数
async def call_llm(messages: List[Dict[str, str]], **kwargs) -> Dict[str, Any]:
    """便捷的LLM调用函数"""
    return await llm_manager.call(messages, **kwargs)

def get_llm_status() -> Dict[str, Any]:
    """获取LLM服务状态"""
    return {
        "available_providers": llm_manager.get_available_providers(),
        "provider_status": llm_manager.get_provider_status(),
        "total_providers": len(llm_manager.providers)
    }
