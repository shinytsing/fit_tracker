#!/bin/bash

# FitTracker 模块生成器 - Tab1: 今日训练计划
# 自动生成训练计划相关的前端和后端代码

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
    echo -e "${BLUE}[Tab1 Generator]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[Tab1 Generator]${NC} $1"
}

log_error() {
    echo -e "${RED}[Tab1 Generator]${NC} $1"
}

# 生成前端训练计划页面
generate_frontend_training_page() {
    log_info "生成前端训练计划页面..."
    
    mkdir -p "$FRONTEND_DIR/lib/features/training/presentation/pages"
    mkdir -p "$FRONTEND_DIR/lib/features/training/presentation/widgets"
    mkdir -p "$FRONTEND_DIR/lib/features/training/domain/models"
    mkdir -p "$FRONTEND_DIR/lib/features/training/data/repositories"
    
    # 训练计划模型
    cat > "$FRONTEND_DIR/lib/features/training/domain/models/training_models.dart" << 'EOF'
import 'package:json_annotation/json_annotation.dart';

part 'training_models.g.dart';

@JsonSerializable()
class TrainingPlan {
  final String id;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final int duration; // 分钟
  final String difficulty;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;

  TrainingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.duration,
    required this.difficulty,
    required this.createdAt,
    this.completedAt,
    this.isCompleted = false,
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) =>
      _$TrainingPlanFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingPlanToJson(this);
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
  });

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}

@JsonSerializable()
class TrainingSession {
  final String id;
  final String planId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<ExerciseRecord> exerciseRecords;
  final int totalCalories;
  final bool isCompleted;

  TrainingSession({
    required this.id,
    required this.planId,
    required this.startTime,
    this.endTime,
    required this.exerciseRecords,
    required this.totalCalories,
    this.isCompleted = false,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingSessionToJson(this);
}

@JsonSerializable()
class ExerciseRecord {
  final String exerciseId;
  final String exerciseName;
  final List<SetRecord> sets;
  final int totalReps;
  final int totalWeight;

  ExerciseRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.totalReps,
    required this.totalWeight,
  });

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) =>
      _$ExerciseRecordFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseRecordToJson(this);
}

@JsonSerializable()
class SetRecord {
  final int setNumber;
  final int reps;
  final int weight;
  final int restTime;

  SetRecord({
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.restTime,
  });

  factory SetRecord.fromJson(Map<String, dynamic> json) =>
      _$SetRecordFromJson(json);
  Map<String, dynamic> toJson() => _$SetRecordToJson(this);
}
EOF

    # 训练计划页面
    cat > "$FRONTEND_DIR/lib/features/training/presentation/pages/training_page.dart" << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/training_provider.dart';
import '../widgets/training_plan_card.dart';
import '../widgets/exercise_list.dart';
import '../widgets/training_timer.dart';

class TrainingPage extends ConsumerStatefulWidget {
  const TrainingPage({super.key});

  @override
  ConsumerState<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends ConsumerState<TrainingPage>
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
    final trainingState = ref.watch(trainingProvider);
    final todayPlan = ref.watch(todayTrainingPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日训练'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '今日计划', icon: Icon(Icons.today)),
            Tab(text: '进行中', icon: Icon(Icons.play_arrow)),
            Tab(text: '历史记录', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 今日计划
          _buildTodayPlanTab(todayPlan),
          // 进行中
          _buildActiveTrainingTab(),
          // 历史记录
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildTodayPlanTab(AsyncValue<TrainingPlan?> todayPlan) {
    return todayPlan.when(
      data: (plan) {
        if (plan == null) {
          return _buildNoPlanWidget();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrainingPlanCard(plan: plan),
              const SizedBox(height: 16),
              const Text(
                '训练动作',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ExerciseList(exercises: plan.exercises),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('加载失败: $error'),
      ),
    );
  }

  Widget _buildActiveTrainingTab() {
    final activeSession = ref.watch(activeTrainingSessionProvider);
    
    return activeSession.when(
      data: (session) {
        if (session == null) {
          return const Center(
            child: Text('没有进行中的训练'),
          );
        }
        return Column(
          children: [
            TrainingTimer(session: session),
            Expanded(
              child: ExerciseList(
                exercises: session.exerciseRecords
                    .map((record) => Exercise(
                          id: record.exerciseId,
                          name: record.exerciseName,
                          description: '',
                          category: '',
                          sets: record.sets.length,
                          reps: record.totalReps,
                          restTime: 60,
                        ))
                    .toList(),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('加载失败: $error'),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final history = ref.watch(trainingHistoryProvider);
    
    return history.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return const Center(
            child: Text('暂无训练记录'),
          );
        }
        return ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text('训练计划 ${session.planId}'),
                subtitle: Text(
                  '${session.startTime.day}/${session.startTime.month} '
                  '${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: Text('${session.totalCalories} 卡路里'),
                onTap: () {
                  // 查看训练详情
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('加载失败: $error'),
      ),
    );
  }

  Widget _buildNoPlanWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '今日暂无训练计划',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // 生成AI训练计划
              ref.read(trainingProvider.notifier).generateAITrainingPlan();
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('生成AI训练计划'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final todayPlan = ref.watch(todayTrainingPlanProvider);
    
    return todayPlan.when(
      data: (plan) {
        if (plan == null) return const SizedBox.shrink();
        
        return FloatingActionButton.extended(
          onPressed: () {
            // 开始训练
            ref.read(trainingProvider.notifier).startTraining(plan.id);
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('开始训练'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
EOF

    log_success "前端训练计划页面生成完成"
}

# 生成后端训练计划 API
generate_backend_training_api() {
    log_info "生成后端训练计划 API..."
    
    mkdir -p "$BACKEND_DIR/internal/handlers"
    mkdir -p "$BACKEND_DIR/internal/services"
    mkdir -p "$BACKEND_DIR/internal/models"
    
    # 训练计划模型
    cat > "$BACKEND_DIR/internal/models/training.go" << 'EOF'
package models

import (
	"time"
	"gorm.io/gorm"
)

// TrainingPlan 训练计划
type TrainingPlan struct {
	ID          string     `json:"id" gorm:"primaryKey"`
	Name        string     `json:"name" gorm:"not null"`
	Description string     `json:"description"`
	Exercises   []Exercise `json:"exercises" gorm:"many2many:plan_exercises"`
	Duration    int        `json:"duration"` // 分钟
	Difficulty  string     `json:"difficulty"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// Exercise 训练动作
type Exercise struct {
	ID          string `json:"id" gorm:"primaryKey"`
	Name        string `json:"name" gorm:"not null"`
	Description string `json:"description"`
	Category    string `json:"category"`
	Sets        int    `json:"sets"`
	Reps        int    `json:"reps"`
	RestTime    int    `json:"rest_time"` // 秒
	ImageURL    string `json:"image_url"`
	VideoURL    string `json:"video_url"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// TrainingSession 训练会话
type TrainingSession struct {
	ID              string           `json:"id" gorm:"primaryKey"`
	UserID          string           `json:"user_id" gorm:"not null"`
	PlanID          string           `json:"plan_id" gorm:"not null"`
	StartTime       time.Time        `json:"start_time"`
	EndTime         *time.Time       `json:"end_time"`
	ExerciseRecords []ExerciseRecord `json:"exercise_records" gorm:"foreignKey:SessionID"`
	TotalCalories   int              `json:"total_calories"`
	IsCompleted     bool             `json:"is_completed"`
	CreatedAt       time.Time        `json:"created_at"`
	UpdatedAt       time.Time        `json:"updated_at"`
	DeletedAt       gorm.DeletedAt   `json:"-" gorm:"index"`
}

// ExerciseRecord 动作记录
type ExerciseRecord struct {
	ID           string     `json:"id" gorm:"primaryKey"`
	SessionID    string     `json:"session_id" gorm:"not null"`
	ExerciseID   string     `json:"exercise_id" gorm:"not null"`
	ExerciseName string     `json:"exercise_name"`
	Sets         []SetRecord `json:"sets" gorm:"foreignKey:RecordID"`
	TotalReps    int        `json:"total_reps"`
	TotalWeight  int        `json:"total_weight"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
}

// SetRecord 组次记录
type SetRecord struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	RecordID  string    `json:"record_id" gorm:"not null"`
	SetNumber int       `json:"set_number"`
	Reps      int       `json:"reps"`
	Weight    int       `json:"weight"`
	RestTime  int       `json:"rest_time"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// PlanExercise 计划动作关联
type PlanExercise struct {
	PlanID     string `json:"plan_id" gorm:"primaryKey"`
	ExerciseID string `json:"exercise_id" gorm:"primaryKey"`
	Order      int    `json:"order"`
}
EOF

    # 训练计划处理器
    cat > "$BACKEND_DIR/internal/handlers/training_handler.go" << 'EOF'
package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"fittracker/backend/internal/models"
	"fittracker/backend/internal/services"
)

type TrainingHandler struct {
	trainingService *services.TrainingService
}

func NewTrainingHandler(trainingService *services.TrainingService) *TrainingHandler {
	return &TrainingHandler{
		trainingService: trainingService,
	}
}

// GetTodayTrainingPlan 获取今日训练计划
func (h *TrainingHandler) GetTodayTrainingPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	plan, err := h.trainingService.GetTodayTrainingPlan(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": plan})
}

// StartTraining 开始训练
func (h *TrainingHandler) StartTraining(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req struct {
		PlanID string `json:"plan_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	session, err := h.trainingService.StartTraining(userID, req.PlanID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": session})
}

// CompleteTraining 完成训练
func (h *TrainingHandler) CompleteTraining(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	sessionID := c.Param("session_id")
	if sessionID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "会话ID不能为空"})
		return
	}

	err := h.trainingService.CompleteTraining(sessionID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "训练完成"})
}

// GetTrainingHistory 获取训练历史
func (h *TrainingHandler) GetTrainingHistory(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	sessions, total, err := h.trainingService.GetTrainingHistory(userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": sessions,
		"total": total,
		"page": page,
		"limit": limit,
	})
}

// GenerateAITrainingPlan 生成AI训练计划
func (h *TrainingHandler) GenerateAITrainingPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req struct {
		Duration   int    `json:"duration"`   // 训练时长（分钟）
		Difficulty string `json:"difficulty"` // 难度等级
		Goals      []string `json:"goals"`    // 训练目标
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	plan, err := h.trainingService.GenerateAITrainingPlan(userID, req.Duration, req.Difficulty, req.Goals)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": plan})
}

// RecordExercise 记录训练动作
func (h *TrainingHandler) RecordExercise(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req struct {
		SessionID  string `json:"session_id" binding:"required"`
		ExerciseID string `json:"exercise_id" binding:"required"`
		Sets       []models.SetRecord `json:"sets" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.trainingService.RecordExercise(req.SessionID, req.ExerciseID, req.Sets)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "记录成功"})
}
EOF

    log_success "后端训练计划 API 生成完成"
}

# 生成数据库初始化脚本
generate_database_init() {
    log_info "生成数据库初始化脚本..."
    
    mkdir -p "$BACKEND_DIR/scripts"
    
    cat > "$BACKEND_DIR/scripts/init.sql" << 'EOF'
-- FitTracker 数据库初始化脚本

-- 创建训练计划表
CREATE TABLE IF NOT EXISTS training_plans (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    duration INTEGER NOT NULL,
    difficulty VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- 创建训练动作表
CREATE TABLE IF NOT EXISTS exercises (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    sets INTEGER NOT NULL,
    reps INTEGER NOT NULL,
    rest_time INTEGER NOT NULL,
    image_url VARCHAR(500),
    video_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- 创建计划动作关联表
CREATE TABLE IF NOT EXISTS plan_exercises (
    plan_id VARCHAR(36),
    exercise_id VARCHAR(36),
    order_index INTEGER,
    PRIMARY KEY (plan_id, exercise_id),
    FOREIGN KEY (plan_id) REFERENCES training_plans(id),
    FOREIGN KEY (exercise_id) REFERENCES exercises(id)
);

-- 创建训练会话表
CREATE TABLE IF NOT EXISTS training_sessions (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    plan_id VARCHAR(36) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NULL,
    total_calories INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (plan_id) REFERENCES training_plans(id)
);

-- 创建动作记录表
CREATE TABLE IF NOT EXISTS exercise_records (
    id VARCHAR(36) PRIMARY KEY,
    session_id VARCHAR(36) NOT NULL,
    exercise_id VARCHAR(36) NOT NULL,
    exercise_name VARCHAR(255) NOT NULL,
    total_reps INTEGER DEFAULT 0,
    total_weight INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES training_sessions(id),
    FOREIGN KEY (exercise_id) REFERENCES exercises(id)
);

-- 创建组次记录表
CREATE TABLE IF NOT EXISTS set_records (
    id VARCHAR(36) PRIMARY KEY,
    record_id VARCHAR(36) NOT NULL,
    set_number INTEGER NOT NULL,
    reps INTEGER NOT NULL,
    weight INTEGER NOT NULL,
    rest_time INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id) REFERENCES exercise_records(id)
);

-- 插入示例数据
INSERT INTO exercises (id, name, description, category, sets, reps, rest_time) VALUES
('ex1', '俯卧撑', '标准俯卧撑动作', '胸部', 3, 15, 60),
('ex2', '深蹲', '标准深蹲动作', '腿部', 3, 20, 60),
('ex3', '平板支撑', '核心力量训练', '核心', 3, 30, 60),
('ex4', '引体向上', '背部力量训练', '背部', 3, 10, 90),
('ex5', '卷腹', '腹部肌肉训练', '腹部', 3, 25, 45);

INSERT INTO training_plans (id, name, description, duration, difficulty) VALUES
('plan1', '基础全身训练', '适合初学者的全身训练计划', 30, '初级'),
('plan2', '力量提升训练', '专注于力量提升的训练计划', 45, '中级'),
('plan3', '高强度训练', '高强度的全身训练计划', 60, '高级');

INSERT INTO plan_exercises (plan_id, exercise_id, order_index) VALUES
('plan1', 'ex1', 1),
('plan1', 'ex2', 2),
('plan1', 'ex3', 3),
('plan2', 'ex1', 1),
('plan2', 'ex2', 2),
('plan2', 'ex3', 3),
('plan2', 'ex4', 4),
('plan3', 'ex1', 1),
('plan3', 'ex2', 2),
('plan3', 'ex3', 3),
('plan3', 'ex4', 4),
('plan3', 'ex5', 5);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_training_sessions_user_id ON training_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_training_sessions_plan_id ON training_sessions(plan_id);
CREATE INDEX IF NOT EXISTS idx_exercise_records_session_id ON exercise_records(session_id);
CREATE INDEX IF NOT EXISTS idx_set_records_record_id ON set_records(record_id);
EOF

    log_success "数据库初始化脚本生成完成"
}

# 主执行函数
main() {
    log_info "开始生成 Tab1: 今日训练计划模块..."
    
    generate_frontend_training_page
    generate_backend_training_api
    generate_database_init
    
    log_success "Tab1: 今日训练计划模块生成完成！"
}

# 执行主函数
main "$@"
