"""
FitTracker Backend - BMI计算器服务层
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_, desc, func
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime, timedelta

from app.models import HealthRecord, User
from app.schemas.bmi import (
    BMIRecordCreate,
    BMIRecordUpdate,
    BMIRecordResponse,
    BMICalculationResponse,
    BMIStatsResponse,
    BMITrendResponse,
    BMITrendPoint,
    HealthAdviceResponse,
    BMICategory,
    Gender,
)

class BMIService:
    """BMI计算器服务类"""
    
    def __init__(self, db: Session):
        self.db = db

    def calculate_bmi(self, user_id: str, height: float, weight: float, 
                     age: int, gender: Gender) -> BMICalculationResponse:
        """计算BMI"""
        # 计算BMI
        height_in_meters = height / 100
        bmi = weight / (height_in_meters * height_in_meters)
        
        # 确定BMI分类
        category = self._get_bmi_category(bmi)
        
        # 获取健康状态
        health_status = self._get_health_status(bmi, age, gender)
        
        # 获取健康建议
        advice = self._get_health_advice_list(bmi, category)
        
        # 获取风险因素
        risk_factors = self._get_risk_factors(bmi, age, gender)
        
        # 获取推荐行动
        recommendations = self._get_recommendations(bmi, category)
        
        return BMICalculationResponse(
            bmi=bmi,
            category=category,
            health_status=health_status,
            advice=advice,
            risk_factors=risk_factors,
            recommendations=recommendations
        )

    def create_record(self, user_id: str, record_data: BMIRecordCreate) -> BMIRecordResponse:
        """创建BMI记录"""
        record = BMIRecord(
            id=str(uuid.uuid4()),
            user_id=user_id,
            height=record_data.height,
            weight=record_data.weight,
            bmi=record_data.bmi,
            category=record_data.category.value,
            age=record_data.age,
            gender=record_data.gender.value,
            notes=record_data.notes,
            recorded_at=datetime.utcnow()
        )
        
        self.db.add(record)
        self.db.commit()
        self.db.refresh(record)
        
        return self._record_to_response(record)

    def get_user_records(self, user_id: str, skip: int = 0, limit: int = 20) -> List[BMIRecordResponse]:
        """获取用户BMI记录列表"""
        records = self.db.query(BMIRecord).filter(
            BMIRecord.user_id == user_id
        ).order_by(desc(BMIRecord.recorded_at)).offset(skip).limit(limit).all()
        
        return [self._record_to_response(record) for record in records]

    def get_record_by_id(self, record_id: str, user_id: str) -> Optional[BMIRecordResponse]:
        """根据ID获取BMI记录"""
        record = self.db.query(BMIRecord).filter(
            and_(
                BMIRecord.id == record_id,
                BMIRecord.user_id == user_id
            )
        ).first()
        
        return self._record_to_response(record) if record else None

    def update_record(self, record_id: str, user_id: str, record_data: BMIRecordUpdate) -> Optional[BMIRecordResponse]:
        """更新BMI记录"""
        record = self.db.query(BMIRecord).filter(
            and_(
                BMIRecord.id == record_id,
                BMIRecord.user_id == user_id
            )
        ).first()
        
        if not record:
            return None
        
        # 更新字段
        if record_data.height is not None:
            record.height = record_data.height
        if record_data.weight is not None:
            record.weight = record_data.weight
        if record_data.bmi is not None:
            record.bmi = record_data.bmi
        if record_data.category is not None:
            record.category = record_data.category.value
        if record_data.age is not None:
            record.age = record_data.age
        if record_data.gender is not None:
            record.gender = record_data.gender.value
        if record_data.notes is not None:
            record.notes = record_data.notes
        
        self.db.commit()
        self.db.refresh(record)
        
        return self._record_to_response(record)

    def delete_record(self, record_id: str, user_id: str) -> bool:
        """删除BMI记录"""
        record = self.db.query(BMIRecord).filter(
            and_(
                BMIRecord.id == record_id,
                BMIRecord.user_id == user_id
            )
        ).first()
        
        if not record:
            return False
        
        self.db.delete(record)
        self.db.commit()
        
        return True

    def get_user_stats(self, user_id: str, period: str = "month") -> BMIStatsResponse:
        """获取用户BMI统计信息"""
        now = datetime.utcnow()
        
        if period == "week":
            start_date = now - timedelta(days=7)
        elif period == "month":
            start_date = now - timedelta(days=30)
        elif period == "year":
            start_date = now - timedelta(days=365)
        else:
            start_date = now - timedelta(days=30)
        
        # 获取记录统计
        records_query = self.db.query(BMIRecord).filter(
            and_(
                BMIRecord.user_id == user_id,
                BMIRecord.recorded_at >= start_date
            )
        )
        
        total_records = records_query.count()
        
        if total_records == 0:
            return BMIStatsResponse(
                period=period,
                total_records=0,
                average_bmi=0.0,
                current_bmi=0.0,
                bmi_change=0.0,
                category_distribution={},
                trend_direction="stable",
                health_score=0.0,
                recommendations=[]
            )
        
        # 计算平均BMI
        average_bmi = records_query.with_entities(func.avg(BMIRecord.bmi)).scalar() or 0.0
        
        # 获取最新BMI
        latest_record = records_query.order_by(desc(BMIRecord.recorded_at)).first()
        current_bmi = latest_record.bmi if latest_record else 0.0
        
        # 计算BMI变化
        oldest_record = records_query.order_by(BMIRecord.recorded_at).first()
        bmi_change = (latest_record.bmi - oldest_record.bmi) if latest_record and oldest_record else 0.0
        
        # 计算分类分布
        category_distribution = {}
        for category in BMICategory:
            count = records_query.filter(BMIRecord.category == category.value).count()
            category_distribution[category.value] = count
        
        # 确定趋势方向
        trend_direction = "stable"
        if bmi_change > 0.5:
            trend_direction = "up"
        elif bmi_change < -0.5:
            trend_direction = "down"
        
        # 计算健康分数
        health_score = self._calculate_health_score(current_bmi, bmi_change, total_records)
        
        # 生成推荐
        recommendations = self._generate_recommendations(current_bmi, trend_direction)
        
        return BMIStatsResponse(
            period=period,
            total_records=total_records,
            average_bmi=average_bmi,
            current_bmi=current_bmi,
            bmi_change=bmi_change,
            category_distribution=category_distribution,
            trend_direction=trend_direction,
            health_score=health_score,
            recommendations=recommendations
        )

    def get_bmi_trend(self, user_id: str, days: int = 30) -> BMITrendResponse:
        """获取BMI趋势"""
        start_date = datetime.utcnow() - timedelta(days=days)
        
        records = self.db.query(BMIRecord).filter(
            and_(
                BMIRecord.user_id == user_id,
                BMIRecord.recorded_at >= start_date
            )
        ).order_by(BMIRecord.recorded_at).all()
        
        trend_points = []
        for record in records:
            trend_points.append(BMITrendPoint(
                date=record.recorded_at,
                bmi=record.bmi,
                weight=record.weight,
                category=BMICategory(record.category)
            ))
        
        # 计算趋势方向
        trend_direction = "stable"
        if len(trend_points) >= 2:
            first_bmi = trend_points[0].bmi
            last_bmi = trend_points[-1].bmi
            if last_bmi - first_bmi > 0.5:
                trend_direction = "up"
            elif last_bmi - first_bmi < -0.5:
                trend_direction = "down"
        
        # 计算每周平均变化
        average_change_per_week = 0.0
        if len(trend_points) >= 2:
            total_change = trend_points[-1].bmi - trend_points[0].bmi
            weeks = days / 7
            average_change_per_week = total_change / weeks if weeks > 0 else 0.0
        
        return BMITrendResponse(
            user_id=user_id,
            period_days=days,
            trend_points=trend_points,
            trend_direction=trend_direction,
            average_change_per_week=average_change_per_week,
            prediction=None
        )

    def get_health_advice(self, user_id: str, bmi: float) -> HealthAdviceResponse:
        """获取健康建议"""
        category = self._get_bmi_category(bmi)
        
        general_advice = self._get_general_advice(bmi, category)
        specific_recommendations = self._get_specific_recommendations(bmi, category)
        dietary_suggestions = self._get_dietary_suggestions(bmi, category)
        exercise_recommendations = self._get_exercise_recommendations(bmi, category)
        lifestyle_tips = self._get_lifestyle_tips(bmi, category)
        warning_signs = self._get_warning_signs(bmi, category)
        follow_up_schedule = self._get_follow_up_schedule(bmi, category)
        
        return HealthAdviceResponse(
            bmi=bmi,
            category=category,
            general_advice=general_advice,
            specific_recommendations=specific_recommendations,
            dietary_suggestions=dietary_suggestions,
            exercise_recommendations=exercise_recommendations,
            lifestyle_tips=lifestyle_tips,
            warning_signs=warning_signs,
            follow_up_schedule=follow_up_schedule
        )

    def _get_bmi_category(self, bmi: float) -> BMICategory:
        """获取BMI分类"""
        if bmi < 18.5:
            return BMICategory.UNDERWEIGHT
        elif bmi < 24:
            return BMICategory.NORMAL
        elif bmi < 28:
            return BMICategory.OVERWEIGHT
        else:
            return BMICategory.OBESE

    def _get_health_status(self, bmi: float, age: int, gender: Gender) -> str:
        """获取健康状态"""
        category = self._get_bmi_category(bmi)
        
        if category == BMICategory.NORMAL:
            return "健康"
        elif category == BMICategory.UNDERWEIGHT:
            return "偏瘦，需要增重"
        elif category == BMICategory.OVERWEIGHT:
            return "偏胖，建议减重"
        else:
            return "肥胖，需要减重"

    def _get_health_advice_list(self, bmi: float, category: BMICategory) -> List[str]:
        """获取健康建议列表"""
        if category == BMICategory.UNDERWEIGHT:
            return [
                "增加营养摄入，多吃高蛋白食物",
                "进行力量训练，增加肌肉量",
                "保证充足睡眠，促进肌肉恢复",
                "咨询营养师，制定增重计划"
            ]
        elif category == BMICategory.NORMAL:
            return [
                "保持均衡饮食，多吃蔬菜水果",
                "每周至少150分钟中等强度运动",
                "保持规律作息，充足睡眠",
                "定期监测体重和BMI变化"
            ]
        elif category == BMICategory.OVERWEIGHT:
            return [
                "控制热量摄入，减少高热量食物",
                "增加有氧运动，如跑步、游泳",
                "减少久坐时间，多活动",
                "设定合理的减重目标"
            ]
        else:  # OBESE
            return [
                "立即咨询专业医生或营养师",
                "制定科学的减重计划",
                "避免极端节食，循序渐进",
                "考虑专业减重指导"
            ]

    def _get_risk_factors(self, bmi: float, age: int, gender: Gender) -> List[str]:
        """获取风险因素"""
        risks = []
        
        if bmi >= 25:
            risks.extend([
                "心血管疾病风险增加",
                "糖尿病风险增加",
                "高血压风险增加"
            ])
        
        if bmi >= 30:
            risks.extend([
                "睡眠呼吸暂停",
                "关节疾病风险",
                "某些癌症风险增加"
            ])
        
        if bmi < 18.5:
            risks.extend([
                "营养不良风险",
                "免疫力下降",
                "骨质疏松风险"
            ])
        
        return risks

    def _get_recommendations(self, bmi: float, category: BMICategory) -> List[str]:
        """获取推荐行动"""
        if category == BMICategory.UNDERWEIGHT:
            return ["增加蛋白质摄入", "进行力量训练", "咨询营养师"]
        elif category == BMICategory.NORMAL:
            return ["保持当前生活方式", "定期监测", "维持运动习惯"]
        elif category == BMICategory.OVERWEIGHT:
            return ["控制饮食", "增加运动", "设定减重目标"]
        else:
            return ["咨询医生", "制定减重计划", "寻求专业指导"]

    def _calculate_health_score(self, bmi: float, bmi_change: float, record_count: int) -> float:
        """计算健康分数"""
        base_score = 100.0
        
        # BMI分数
        if 18.5 <= bmi <= 24:
            bmi_score = 100
        elif 17 <= bmi < 18.5 or 24 < bmi <= 25:
            bmi_score = 80
        elif 16 <= bmi < 17 or 25 < bmi <= 30:
            bmi_score = 60
        else:
            bmi_score = 40
        
        # 变化分数
        if abs(bmi_change) <= 0.5:
            change_score = 100
        elif abs(bmi_change) <= 1.0:
            change_score = 80
        else:
            change_score = 60
        
        # 记录频率分数
        if record_count >= 10:
            frequency_score = 100
        elif record_count >= 5:
            frequency_score = 80
        else:
            frequency_score = 60
        
        return (bmi_score * 0.6 + change_score * 0.2 + frequency_score * 0.2)

    def _generate_recommendations(self, bmi: float, trend_direction: str) -> List[str]:
        """生成推荐"""
        recommendations = []
        
        if trend_direction == "up":
            recommendations.append("BMI呈上升趋势，建议控制饮食和增加运动")
        elif trend_direction == "down":
            recommendations.append("BMI呈下降趋势，继续保持健康的生活方式")
        
        if bmi > 25:
            recommendations.append("建议咨询营养师制定减重计划")
        elif bmi < 18.5:
            recommendations.append("建议咨询营养师制定增重计划")
        
        return recommendations

    def _get_general_advice(self, bmi: float, category: BMICategory) -> str:
        """获取一般建议"""
        if category == BMICategory.NORMAL:
            return "恭喜！你的BMI在正常范围内，继续保持健康的生活方式。"
        elif category == BMICategory.UNDERWEIGHT:
            return "你的BMI偏低，建议增加营养摄入和适当的力量训练。"
        elif category == BMICategory.OVERWEIGHT:
            return "你的BMI偏高，建议控制饮食和增加有氧运动。"
        else:
            return "你的BMI过高，建议咨询专业医生制定科学的减重计划。"

    def _get_specific_recommendations(self, bmi: float, category: BMICategory) -> List[str]:
        """获取具体推荐"""
        return self._get_health_advice_list(bmi, category)

    def _get_dietary_suggestions(self, bmi: float, category: BMICategory) -> List[str]:
        """获取饮食建议"""
        if category == BMICategory.UNDERWEIGHT:
            return [
                "增加蛋白质摄入：瘦肉、鱼类、豆类",
                "多吃健康脂肪：坚果、橄榄油、鳄梨",
                "增加餐次，少食多餐",
                "补充维生素和矿物质"
            ]
        elif category == BMICategory.NORMAL:
            return [
                "保持均衡饮食",
                "多吃蔬菜水果",
                "适量蛋白质和健康脂肪",
                "控制糖分和盐分摄入"
            ]
        else:
            return [
                "控制总热量摄入",
                "减少高热量食物",
                "增加蔬菜和水果",
                "选择低脂蛋白质"
            ]

    def _get_exercise_recommendations(self, bmi: float, category: BMICategory) -> List[str]:
        """获取运动建议"""
        if category == BMICategory.UNDERWEIGHT:
            return [
                "进行力量训练增加肌肉量",
                "适度有氧运动",
                "避免过度消耗热量",
                "保证充足休息"
            ]
        elif category == BMICategory.NORMAL:
            return [
                "每周150分钟中等强度有氧运动",
                "每周2-3次力量训练",
                "保持运动多样性",
                "循序渐进增加强度"
            ]
        else:
            return [
                "增加有氧运动时间",
                "结合力量训练",
                "选择低冲击运动",
                "循序渐进，避免受伤"
            ]

    def _get_lifestyle_tips(self, bmi: float, category: BMICategory) -> List[str]:
        """获取生活方式建议"""
        return [
            "保持规律作息",
            "充足睡眠（7-9小时）",
            "减少压力",
            "戒烟限酒",
            "定期体检"
        ]

    def _get_warning_signs(self, bmi: float, category: BMICategory) -> List[str]:
        """获取警告信号"""
        if category == BMICategory.OBESE:
            return [
                "呼吸困难",
                "关节疼痛",
                "疲劳乏力",
                "睡眠质量差"
            ]
        elif category == BMICategory.UNDERWEIGHT:
            return [
                "疲劳乏力",
                "免疫力下降",
                "月经不调",
                "头发稀疏"
            ]
        else:
            return [
                "体重快速变化",
                "食欲异常",
                "疲劳持续",
                "情绪波动"
            ]

    def _get_follow_up_schedule(self, bmi: float, category: BMICategory) -> str:
        """获取随访计划"""
        if category == BMICategory.OBESE:
            return "每月监测BMI，每3个月咨询医生"
        elif category == BMICategory.OVERWEIGHT:
            return "每月监测BMI，每6个月体检"
        elif category == BMICategory.UNDERWEIGHT:
            return "每月监测BMI，每3个月咨询营养师"
        else:
            return "每3个月监测BMI，每年体检"

    def _record_to_response(self, record: HealthRecord) -> BMIRecordResponse:
        """将BMI记录模型转换为响应模型"""
        return BMIRecordResponse(
            id=record.id,
            user_id=record.user_id,
            height=record.height,
            weight=record.weight,
            bmi=record.bmi,
            category=BMICategory(record.category),
            age=record.age,
            gender=Gender(record.gender),
            notes=record.notes,
            recorded_at=record.recorded_at
        )
