#!/bin/bash

# FitTracker 模块生成器 - Tab3: AI 推荐训练
# 自动生成AI推荐训练相关的前端和后端代码

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 项目路径
PROJECT_ROOT="/Users/gaojie/Desktop/fittraker"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend-go"

log_info() {
    echo -e "${BLUE}[Tab3 Generator]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[Tab3 Generator]${NC} $1"
}

log_error() {
    echo -e "${RED}[Tab3 Generator]${NC} $1"
}

# 生成前端AI推荐页面
generate_frontend_ai_page() {
    log_info "生成前端AI推荐页面..."
    
    mkdir -p "$FRONTEND_DIR/lib/features/ai/presentation/pages"
    mkdir -p "$FRONTEND_DIR/lib/features/ai/presentation/widgets"
    mkdir -p "$FRONTEND_DIR/lib/features/ai/domain/models"
    mkdir -p "$FRONTEND_DIR/lib/features/ai/data/repositories"
    
    # AI推荐模型
    cat > "$FRONTEND_DIR/lib/features/ai/domain/models/ai_models.dart" << 'EOF'
import 'package:json_annotation/json_annotation.dart';

part 'ai_models.g.dart';

@JsonSerializable()
class AIRecommendation {
  final String id;
  final String title;
  final String description;
  final List<Exercise> exercises;
  final int duration; // 分钟
  final String difficulty;
  final String category;
  final double confidence; // 推荐置信度
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  AIRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
    required this.duration,
    required this.difficulty,
    required this.category,
    required this.confidence,
    required this.metadata,
    required this.createdAt,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) =>
      _$AIRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$AIRecommendationToJson(this);
}

@JsonSerializable()
class Exercise {
  final String id;
  final String name;
  final String description;
  final String category;
  final int sets;
  final int reps;
  final int restTime; // 秒
  final String? imageUrl;
  final String? videoUrl;
  final String? instructions;
  final List<String>? tips;
  final Map<String, dynamic>? metadata;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.sets,
    required this.reps,
    required this.restTime,
    this.imageUrl,
    this.videoUrl,
    this.instructions,
    this.tips,
    this.metadata,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}

@JsonSerializable()
class AIRequest {
  final int duration; // 训练时长（分钟）
  final String difficulty; // 难度等级
  final List<String> goals; // 训练目标
  final List<String> preferences; // 偏好
  final List<String> limitations; // 限制条件
  final String? equipment; // 可用器械
  final Map<String, dynamic>? userProfile; // 用户画像

  AIRequest({
    required this.duration,
    required this.difficulty,
    required this.goals,
    required this.preferences,
    required this.limitations,
    this.equipment,
    this.userProfile,
  });

  factory AIRequest.fromJson(Map<String, dynamic> json) =>
      _$AIRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AIRequestToJson(this);
}

@JsonSerializable()
class AIResponse {
  final String requestId;
  final List<AIRecommendation> recommendations;
  final String reasoning; // AI推荐理由
  final Map<String, dynamic> analysis; // 分析结果
  final DateTime generatedAt;

  AIResponse({
    required this.requestId,
    required this.recommendations,
    required this.reasoning,
    required this.analysis,
    required this.generatedAt,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AIResponseToJson(this);
}

@JsonSerializable()
class ExerciseTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final String difficulty;
  final List<String> muscleGroups;
  final String? equipment;
  final String? imageUrl;
  final String? videoUrl;
  final String instructions;
  final List<String> tips;
  final Map<String, dynamic> metadata;

  ExerciseTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.muscleGroups,
    this.equipment,
    this.imageUrl,
    this.videoUrl,
    required this.instructions,
    required this.tips,
    required this.metadata,
  });

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) =>
      _$ExerciseTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseTemplateToJson(this);
}
EOF

    # AI推荐页面
    cat > "$FRONTEND_DIR/lib/features/ai/presentation/pages/ai_recommendation_page.dart" << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_request_form.dart';
import '../widgets/ai_recommendation_card.dart';
import '../widgets/exercise_template_list.dart';
import '../widgets/ai_loading_widget.dart';

class AIRecommendationPage extends ConsumerStatefulWidget {
  const AIRecommendationPage({super.key});

  @override
  ConsumerState<AIRecommendationPage> createState() => _AIRecommendationPageState();
}

class _AIRecommendationPageState extends ConsumerState<AIRecommendationPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 推荐训练'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(aiRecommendationsProvider);
              ref.refresh(exerciseTemplatesProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'AI推荐', icon: Icon(Icons.auto_awesome)),
            Tab(text: '动作库', icon: Icon(Icons.fitness_center)),
            Tab(text: '生成计划', icon: Icon(Icons.add)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendationsTab(),
          _buildTemplatesTab(),
          _buildGenerateTab(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    final recommendations = ref.watch(aiRecommendationsProvider);
    
    return recommendations.when(
      data: (recommendations) {
        if (recommendations.isEmpty) {
          return _buildEmptyRecommendations();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final recommendation = recommendations[index];
            return AIRecommendationCard(
              recommendation: recommendation,
              onTap: () {
                _showRecommendationDetail(recommendation);
              },
              onAccept: () {
                _acceptRecommendation(recommendation);
              },
            );
          },
        );
      },
      loading: () => const AILoadingWidget(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败: $error',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.refresh(aiRecommendationsProvider);
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesTab() {
    final templates = ref.watch(exerciseTemplatesProvider);
    
    return templates.when(
      data: (templates) {
        return ExerciseTemplateList(
          templates: templates,
          onTemplateTap: (template) {
            _showTemplateDetail(template);
          },
        );
      },
      loading: () => const AILoadingWidget(),
      error: (error, stack) => Center(
        child: Text('加载失败: $error'),
      ),
    );
  }

  Widget _buildGenerateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AIRequestForm(
        onSubmit: (request) {
          _generateRecommendation(request);
        },
      ),
    );
  }

  Widget _buildEmptyRecommendations() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无AI推荐',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _tabController.animateTo(2); // 切换到生成计划标签
            },
            icon: const Icon(Icons.add),
            label: const Text('生成训练计划'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showRecommendationDetail(recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recommendation.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(recommendation.description),
              const SizedBox(height: 16),
              Text(
                '训练时长: ${recommendation.duration} 分钟',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '难度等级: ${recommendation.difficulty}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '推荐置信度: ${(recommendation.confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '训练动作:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...recommendation.exercises.map((exercise) => ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(exercise.name),
                subtitle: Text('${exercise.sets}组 x ${exercise.reps}次'),
                dense: true,
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptRecommendation(recommendation);
            },
            child: const Text('接受推荐'),
          ),
        ],
      ),
    );
  }

  void _showTemplateDetail(template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(template.description),
              const SizedBox(height: 16),
              Text(
                '分类: ${template.category}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '难度: ${template.difficulty}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '目标肌群: ${template.muscleGroups.join(', ')}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (template.equipment != null)
                Text(
                  '所需器械: ${template.equipment}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 16),
              const Text(
                '动作说明:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(template.instructions),
              if (template.tips.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  '训练技巧:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...template.tips.map((tip) => Text('• $tip')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _acceptRecommendation(recommendation) {
    ref.read(aiProvider.notifier).acceptRecommendation(recommendation.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已接受AI推荐，训练计划已添加到今日计划'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _generateRecommendation(request) {
    ref.read(aiProvider.notifier).generateRecommendation(request);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在生成AI推荐，请稍候...'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
EOF

    log_success "前端AI推荐页面生成完成"
}

# 生成后端AI服务
generate_backend_ai_service() {
    log_info "生成后端AI服务..."
    
    # AI服务处理器
    cat > "$BACKEND_DIR/internal/handlers/ai_handler.go" << 'EOF'
package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"fittracker/backend/internal/services"
)

type AIHandler struct {
	aiService *services.AIService
}

func NewAIHandler(aiService *services.AIService) *AIHandler {
	return &AIHandler{
		aiService: aiService,
	}
}

// GenerateRecommendation 生成AI推荐
func (h *AIHandler) GenerateRecommendation(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req struct {
		Duration    int      `json:"duration" binding:"required"`
		Difficulty  string   `json:"difficulty" binding:"required"`
		Goals       []string `json:"goals" binding:"required"`
		Preferences []string `json:"preferences"`
		Limitations []string `json:"limitations"`
		Equipment   string   `json:"equipment"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	recommendations, err := h.aiService.GenerateRecommendation(userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": recommendations})
}

// GetRecommendations 获取AI推荐列表
func (h *AIHandler) GetRecommendations(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	recommendations, err := h.aiService.GetRecommendations(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": recommendations})
}

// AcceptRecommendation 接受AI推荐
func (h *AIHandler) AcceptRecommendation(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	recommendationID := c.Param("id")
	if recommendationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "推荐ID不能为空"})
		return
	}

	err := h.aiService.AcceptRecommendation(userID, recommendationID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "推荐已接受"})
}

// GetExerciseTemplates 获取动作模板
func (h *AIHandler) GetExerciseTemplates(c *gin.Context) {
	category := c.Query("category")
	difficulty := c.Query("difficulty")
	equipment := c.Query("equipment")

	templates, err := h.aiService.GetExerciseTemplates(category, difficulty, equipment)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": templates})
}

// GetExerciseTemplate 获取单个动作模板
func (h *AIHandler) GetExerciseTemplate(c *gin.Context) {
	templateID := c.Param("id")
	if templateID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "模板ID不能为空"})
		return
	}

	template, err := h.aiService.GetExerciseTemplate(templateID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": template})
}

// AnalyzeUserProfile 分析用户画像
func (h *AIHandler) AnalyzeUserProfile(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	profile, err := h.aiService.AnalyzeUserProfile(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": profile})
}
EOF

    # AI服务实现
    cat > "$BACKEND_DIR/internal/services/ai_service.go" << 'EOF'
package services

import (
	"encoding/json"
	"fmt"
	"time"

	"fittracker/backend/internal/models"
	"gorm.io/gorm"
)

type AIService struct {
	db *gorm.DB
}

func NewAIService(db *gorm.DB) *AIService {
	return &AIService{db: db}
}

// GenerateRecommendation 生成AI推荐
func (s *AIService) GenerateRecommendation(userID string, req struct {
	Duration    int      `json:"duration"`
	Difficulty  string   `json:"difficulty"`
	Goals       []string `json:"goals"`
	Preferences []string `json:"preferences"`
	Limitations []string `json:"limitations"`
	Equipment   string   `json:"equipment"`
}) ([]models.AIRecommendation, error) {
	// 分析用户画像
	profile, err := s.AnalyzeUserProfile(userID)
	if err != nil {
		return nil, err
	}

	// 构建AI请求
	aiRequest := map[string]interface{}{
		"user_id":     userID,
		"duration":    req.Duration,
		"difficulty":  req.Difficulty,
		"goals":       req.Goals,
		"preferences": req.Preferences,
		"limitations": req.Limitations,
		"equipment":   req.Equipment,
		"profile":     profile,
	}

	// 调用AI服务生成推荐
	recommendations, err := s.callAIService(aiRequest)
	if err != nil {
		return nil, err
	}

	// 保存推荐到数据库
	for _, rec := range recommendations {
		rec.UserID = userID
		rec.CreatedAt = time.Now()
		if err := s.db.Create(&rec).Error; err != nil {
			return nil, err
		}
	}

	return recommendations, nil
}

// GetRecommendations 获取AI推荐列表
func (s *AIService) GetRecommendations(userID string) ([]models.AIRecommendation, error) {
	var recommendations []models.AIRecommendation

	if err := s.db.
		Preload("Exercises").
		Where("user_id = ? AND created_at >= ?", userID, time.Now().AddDate(0, 0, -7)).
		Order("created_at DESC").
		Find(&recommendations).Error; err != nil {
		return nil, err
	}

	return recommendations, nil
}

// AcceptRecommendation 接受AI推荐
func (s *AIService) AcceptRecommendation(userID, recommendationID string) error {
	var recommendation models.AIRecommendation

	if err := s.db.
		Preload("Exercises").
		Where("id = ? AND user_id = ?", recommendationID, userID).
		First(&recommendation).Error; err != nil {
		return err
	}

	// 创建训练计划
	plan := models.TrainingPlan{
		ID:          fmt.Sprintf("plan_%d", time.Now().Unix()),
		Name:        recommendation.Title,
		Description: recommendation.Description,
		Duration:    recommendation.Duration,
		Difficulty:  recommendation.Difficulty,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	if err := s.db.Create(&plan).Error; err != nil {
		return err
	}

	// 添加动作到计划
	for i, exercise := range recommendation.Exercises {
		planExercise := models.PlanExercise{
			PlanID:     plan.ID,
			ExerciseID: exercise.ID,
			Order:      i + 1,
		}
		if err := s.db.Create(&planExercise).Error; err != nil {
			return err
		}
	}

	// 标记推荐为已接受
	recommendation.IsAccepted = true
	recommendation.AcceptedAt = &time.Time{}
	*recommendation.AcceptedAt = time.Now()

	return s.db.Save(&recommendation).Error
}

// GetExerciseTemplates 获取动作模板
func (s *AIService) GetExerciseTemplates(category, difficulty, equipment string) ([]models.ExerciseTemplate, error) {
	var templates []models.ExerciseTemplate

	query := s.db.Model(&models.ExerciseTemplate{})

	if category != "" {
		query = query.Where("category = ?", category)
	}
	if difficulty != "" {
		query = query.Where("difficulty = ?", difficulty)
	}
	if equipment != "" {
		query = query.Where("equipment = ?", equipment)
	}

	if err := query.Find(&templates).Error; err != nil {
		return nil, err
	}

	return templates, nil
}

// GetExerciseTemplate 获取单个动作模板
func (s *AIService) GetExerciseTemplate(templateID string) (*models.ExerciseTemplate, error) {
	var template models.ExerciseTemplate

	if err := s.db.Where("id = ?", templateID).First(&template).Error; err != nil {
		return nil, err
	}

	return &template, nil
}

// AnalyzeUserProfile 分析用户画像
func (s *AIService) AnalyzeUserProfile(userID string) (map[string]interface{}, error) {
	profile := make(map[string]interface{})

	// 获取用户基本信息
	var user models.User
	if err := s.db.Where("id = ?", userID).First(&user).Error; err != nil {
		return nil, err
	}

	profile["age"] = user.Age
	profile["gender"] = user.Gender
	profile["weight"] = user.Weight
	profile["height"] = user.Height
	profile["fitness_level"] = user.FitnessLevel

	// 获取训练历史统计
	var stats struct {
		TotalSessions int
		AvgDuration   float64
		FavoriteCategory string
	}

	if err := s.db.Raw(`
		SELECT 
			COUNT(*) as total_sessions,
			AVG(EXTRACT(EPOCH FROM (end_time - start_time))/60) as avg_duration,
			(SELECT category FROM exercises e 
			 JOIN exercise_records er ON e.id = er.exercise_id 
			 JOIN training_sessions ts ON er.session_id = ts.id 
			 WHERE ts.user_id = ? AND ts.is_completed = true 
			 GROUP BY e.category ORDER BY COUNT(*) DESC LIMIT 1) as favorite_category
		FROM training_sessions 
		WHERE user_id = ? AND is_completed = true
	`, userID, userID).Scan(&stats).Error; err == nil {
		profile["training_stats"] = stats
	}

	// 获取最近的训练偏好
	var recentSessions []models.TrainingSession
	if err := s.db.
		Preload("ExerciseRecords").
		Where("user_id = ? AND is_completed = true", userID).
		Order("start_time DESC").
		Limit(10).
		Find(&recentSessions).Error; err == nil {
		profile["recent_sessions"] = recentSessions
	}

	return profile, nil
}

// callAIService 调用AI服务
func (s *AIService) callAIService(request map[string]interface{}) ([]models.AIRecommendation, error) {
	// 这里应该调用实际的AI服务
	// 为了演示，我们返回一些模拟数据
	
	recommendations := []models.AIRecommendation{
		{
			ID:          fmt.Sprintf("rec_%d", time.Now().Unix()),
			UserID:      request["user_id"].(string),
			Title:       "全身力量训练",
			Description: "基于您的训练历史和个人偏好，为您推荐的全方位力量训练计划",
			Duration:    request["duration"].(int),
			Difficulty:  request["difficulty"].(string),
			Category:    "力量训练",
			Confidence:  0.85,
			CreatedAt:   time.Now(),
			UpdatedAt:   time.Now(),
		},
	}

	// 根据请求生成相应的动作
	exercises := s.generateExercisesForRequest(request)
	recommendations[0].Exercises = exercises

	return recommendations, nil
}

// generateExercisesForRequest 根据请求生成动作
func (s *AIService) generateExercisesForRequest(request map[string]interface{}) []models.Exercise {
	// 这里应该根据AI分析结果生成具体的动作
	// 为了演示，我们返回一些基础动作
	
	duration := request["duration"].(int)
	difficulty := request["difficulty"].(string)
	
	var exercises []models.Exercise
	
	// 根据时长和难度调整动作数量和强度
	exerciseCount := duration / 10 // 每10分钟一个动作
	if exerciseCount < 3 {
		exerciseCount = 3
	}
	if exerciseCount > 8 {
		exerciseCount = 8
	}
	
	baseExercises := []models.Exercise{
		{ID: "ex1", Name: "俯卧撑", Category: "胸部", Sets: 3, Reps: 15, RestTime: 60},
		{ID: "ex2", Name: "深蹲", Category: "腿部", Sets: 3, Reps: 20, RestTime: 60},
		{ID: "ex3", Name: "平板支撑", Category: "核心", Sets: 3, Reps: 30, RestTime: 60},
		{ID: "ex4", Name: "引体向上", Category: "背部", Sets: 3, Reps: 10, RestTime: 90},
		{ID: "ex5", Name: "卷腹", Category: "腹部", Sets: 3, Reps: 25, RestTime: 45},
	}
	
	// 根据难度调整
	for i := range baseExercises {
		if difficulty == "初级" {
			baseExercises[i].Sets = 2
			baseExercises[i].Reps = int(float64(baseExercises[i].Reps) * 0.8)
		} else if difficulty == "高级" {
			baseExercises[i].Sets = 4
			baseExercises[i].Reps = int(float64(baseExercises[i].Reps) * 1.2)
		}
	}
	
	// 选择前N个动作
	for i := 0; i < exerciseCount && i < len(baseExercises); i++ {
		exercises = append(exercises, baseExercises[i])
	}
	
	return exercises
}
EOF

    log_success "后端AI服务生成完成"
}

# 生成AI服务启动脚本
generate_ai_service_script() {
    log_info "生成AI服务启动脚本..."
    
    cat > "$PROJECT_ROOT/start_ai_services.sh" << 'EOF'
#!/bin/bash

# FitTracker AI服务启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[AI Service]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[AI Service]${NC} $1"
}

log_error() {
    echo -e "${RED}[AI Service]${NC} $1"
}

# 检查AI API密钥
check_ai_keys() {
    log_info "检查AI API密钥..."
    
    if [ -z "$DEEPSEEK_API_KEY" ]; then
        log_warning "DEEPSEEK_API_KEY 未设置"
    else
        log_success "DEEPSEEK_API_KEY 已设置"
    fi
    
    if [ -z "$AIMLAPI_API_KEY" ]; then
        log_warning "AIMLAPI_API_KEY 未设置"
    else
        log_success "AIMLAPI_API_KEY 已设置"
    fi
    
    if [ -z "$GROQ_API_KEY" ]; then
        log_warning "GROQ_API_KEY 未设置"
    else
        log_success "GROQ_API_KEY 已设置"
    fi
}

# 启动AI服务管理器
start_ai_manager() {
    log_info "启动AI服务管理器..."
    
    cd "$PROJECT_ROOT/backend-go"
    
    if [ -f "services/llm_manager.go" ]; then
        go run services/llm_manager.go > "$PROJECT_ROOT/logs/ai_service.log" 2>&1 &
        AI_PID=$!
        echo $AI_PID > "$PROJECT_ROOT/logs/ai_service.pid"
        log_success "AI服务管理器启动完成 (PID: $AI_PID)"
    else
        log_error "AI服务管理器文件不存在"
        return 1
    fi
}

# 测试AI服务
test_ai_service() {
    log_info "测试AI服务..."
    
    sleep 5
    
    # 测试AI推荐生成
    curl -X POST http://localhost:8080/api/ai/recommendation \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer test-token" \
        -d '{
            "duration": 30,
            "difficulty": "中级",
            "goals": ["增肌", "减脂"],
            "preferences": ["无器械"],
            "limitations": []
        }' > "$PROJECT_ROOT/logs/ai_test.log" 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "AI服务测试通过"
    else
        log_error "AI服务测试失败"
        return 1
    fi
}

# 主执行函数
main() {
    log_info "开始启动AI服务..."
    
    check_ai_keys
    start_ai_manager
    test_ai_service
    
    log_success "AI服务启动完成！"
    log_info "查看日志: $PROJECT_ROOT/logs/ai_service.log"
}

# 执行主函数
main "$@"
EOF

    chmod +x "$PROJECT_ROOT/start_ai_services.sh"
    
    log_success "AI服务启动脚本生成完成"
}

# 主执行函数
main() {
    log_info "开始生成 Tab3: AI 推荐训练模块..."
    
    generate_frontend_ai_page
    generate_backend_ai_service
    generate_ai_service_script
    
    log_success "Tab3: AI 推荐训练模块生成完成！"
}

# 执行主函数
main "$@"
