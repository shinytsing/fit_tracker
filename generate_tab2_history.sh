#!/bin/bash

# FitTracker 模块生成器 - Tab2: 训练历史
# 自动生成训练历史相关的前端和后端代码

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
    echo -e "${BLUE}[Tab2 Generator]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[Tab2 Generator]${NC} $1"
}

log_error() {
    echo -e "${RED}[Tab2 Generator]${NC} $1"
}

# 生成前端训练历史页面
generate_frontend_history_page() {
    log_info "生成前端训练历史页面..."
    
    mkdir -p "$FRONTEND_DIR/lib/features/history/presentation/pages"
    mkdir -p "$FRONTEND_DIR/lib/features/history/presentation/widgets"
    mkdir -p "$FRONTEND_DIR/lib/features/history/domain/models"
    mkdir -p "$FRONTEND_DIR/lib/features/history/data/repositories"
    
    # 训练历史模型
    cat > "$FRONTEND_DIR/lib/features/history/domain/models/history_models.dart" << 'EOF'
import 'package:json_annotation/json_annotation.dart';

part 'history_models.g.dart';

@JsonSerializable()
class TrainingHistory {
  final String id;
  final String planId;
  final String planName;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // 分钟
  final int totalCalories;
  final List<ExerciseRecord> exerciseRecords;
  final bool isCompleted;
  final String difficulty;

  TrainingHistory({
    required this.id,
    required this.planId,
    required this.planName,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.totalCalories,
    required this.exerciseRecords,
    required this.isCompleted,
    required this.difficulty,
  });

  factory TrainingHistory.fromJson(Map<String, dynamic> json) =>
      _$TrainingHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingHistoryToJson(this);
}

@JsonSerializable()
class ExerciseRecord {
  final String exerciseId;
  final String exerciseName;
  final List<SetRecord> sets;
  final int totalReps;
  final int totalWeight;
  final String category;

  ExerciseRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.totalReps,
    required this.totalWeight,
    required this.category,
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

@JsonSerializable()
class TrainingStats {
  final int totalSessions;
  final int totalDuration; // 分钟
  final int totalCalories;
  final double averageDuration;
  final int longestStreak;
  final int currentStreak;
  final Map<String, int> categoryStats;
  final List<WeeklyStats> weeklyStats;

  TrainingStats({
    required this.totalSessions,
    required this.totalDuration,
    required this.totalCalories,
    required this.averageDuration,
    required this.longestStreak,
    required this.currentStreak,
    required this.categoryStats,
    required this.weeklyStats,
  });

  factory TrainingStats.fromJson(Map<String, dynamic> json) =>
      _$TrainingStatsFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingStatsToJson(this);
}

@JsonSerializable()
class WeeklyStats {
  final DateTime weekStart;
  final int sessions;
  final int duration;
  final int calories;

  WeeklyStats({
    required this.weekStart,
    required this.sessions,
    required this.duration,
    required this.calories,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) =>
      _$WeeklyStatsFromJson(json);
  Map<String, dynamic> toJson() => _$WeeklyStatsToJson(this);
}
EOF

    # 训练历史页面
    cat > "$FRONTEND_DIR/lib/features/history/presentation/pages/history_page.dart" << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/history_provider.dart';
import '../widgets/history_stats_card.dart';
import '../widgets/history_chart.dart';
import '../widgets/history_list.dart';
import '../widgets/session_detail_dialog.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage>
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
        title: const Text('训练历史'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(trainingHistoryProvider);
              ref.refresh(trainingStatsProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '统计', icon: Icon(Icons.analytics)),
            Tab(text: '图表', icon: Icon(Icons.show_chart)),
            Tab(text: '记录', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(),
          _buildChartTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final stats = ref.watch(trainingStatsProvider);
    
    return stats.when(
      data: (stats) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 总体统计
              HistoryStatsCard(
                title: '总体统计',
                stats: {
                  '总训练次数': '${stats.totalSessions}',
                  '总训练时长': '${stats.totalDuration} 分钟',
                  '总消耗卡路里': '${stats.totalCalories}',
                  '平均训练时长': '${stats.averageDuration.toStringAsFixed(1)} 分钟',
                },
              ),
              const SizedBox(height: 16),
              
              // 连续训练
              HistoryStatsCard(
                title: '连续训练',
                stats: {
                  '当前连续': '${stats.currentStreak} 天',
                  '最长连续': '${stats.longestStreak} 天',
                },
              ),
              const SizedBox(height: 16),
              
              // 分类统计
              HistoryStatsCard(
                title: '训练分类',
                stats: stats.categoryStats.map(
                  (key, value) => MapEntry(key, '$value 次'),
                ),
              ),
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

  Widget _buildChartTab() {
    final stats = ref.watch(trainingStatsProvider);
    
    return stats.when(
      data: (stats) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 周训练时长图表
              HistoryChart(
                title: '周训练时长',
                data: stats.weeklyStats.map((w) => FlSpot(
                  w.weekStart.millisecondsSinceEpoch.toDouble(),
                  w.duration.toDouble(),
                )).toList(),
              ),
              const SizedBox(height: 16),
              
              // 周训练次数图表
              HistoryChart(
                title: '周训练次数',
                data: stats.weeklyStats.map((w) => FlSpot(
                  w.weekStart.millisecondsSinceEpoch.toDouble(),
                  w.sessions.toDouble(),
                )).toList(),
              ),
              const SizedBox(height: 16),
              
              // 周消耗卡路里图表
              HistoryChart(
                title: '周消耗卡路里',
                data: stats.weeklyStats.map((w) => FlSpot(
                  w.weekStart.millisecondsSinceEpoch.toDouble(),
                  w.calories.toDouble(),
                )).toList(),
              ),
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

  Widget _buildHistoryTab() {
    final history = ref.watch(trainingHistoryProvider);
    
    return history.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '暂无训练记录',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return HistoryList(
          sessions: sessions,
          onSessionTap: (session) {
            showDialog(
              context: context,
              builder: (context) => SessionDetailDialog(session: session),
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
}
EOF

    log_success "前端训练历史页面生成完成"
}

# 生成后端训练历史 API
generate_backend_history_api() {
    log_info "生成后端训练历史 API..."
    
    # 训练历史处理器
    cat > "$BACKEND_DIR/internal/handlers/history_handler.go" << 'EOF'
package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"fittracker/backend/internal/services"
)

type HistoryHandler struct {
	historyService *services.HistoryService
}

func NewHistoryHandler(historyService *services.HistoryService) *HistoryHandler {
	return &HistoryHandler{
		historyService: historyService,
	}
}

// GetTrainingHistory 获取训练历史
func (h *HistoryHandler) GetTrainingHistory(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	sessions, total, err := h.historyService.GetTrainingHistory(userID, page, limit, startDate, endDate)
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

// GetTrainingStats 获取训练统计
func (h *HistoryHandler) GetTrainingStats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	stats, err := h.historyService.GetTrainingStats(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": stats})
}

// GetSessionDetail 获取训练会话详情
func (h *HistoryHandler) GetSessionDetail(c *gin.Context) {
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

	session, err := h.historyService.GetSessionDetail(userID, sessionID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": session})
}

// ExportTrainingData 导出训练数据
func (h *HistoryHandler) ExportTrainingData(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	format := c.DefaultQuery("format", "json")
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	data, err := h.historyService.ExportTrainingData(userID, format, startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Header("Content-Type", "application/octet-stream")
	c.Header("Content-Disposition", "attachment; filename=training_data."+format)
	c.Data(http.StatusOK, "application/octet-stream", data)
}

// GetWeeklyStats 获取周统计
func (h *HistoryHandler) GetWeeklyStats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	weeks, _ := strconv.Atoi(c.DefaultQuery("weeks", "12"))

	stats, err := h.historyService.GetWeeklyStats(userID, weeks)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": stats})
}

// GetCategoryStats 获取分类统计
func (h *HistoryHandler) GetCategoryStats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	stats, err := h.historyService.GetCategoryStats(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": stats})
}
EOF

    # 训练历史服务
    cat > "$BACKEND_DIR/internal/services/history_service.go" << 'EOF'
package services

import (
	"encoding/json"
	"fmt"
	"time"

	"fittracker/backend/internal/models"
	"gorm.io/gorm"
)

type HistoryService struct {
	db *gorm.DB
}

func NewHistoryService(db *gorm.DB) *HistoryService {
	return &HistoryService{db: db}
}

// GetTrainingHistory 获取训练历史
func (s *HistoryService) GetTrainingHistory(userID string, page, limit int, startDate, endDate string) ([]models.TrainingSession, int64, error) {
	var sessions []models.TrainingSession
	var total int64

	query := s.db.Where("user_id = ?", userID)

	// 日期过滤
	if startDate != "" {
		if start, err := time.Parse("2006-01-02", startDate); err == nil {
			query = query.Where("start_time >= ?", start)
		}
	}
	if endDate != "" {
		if end, err := time.Parse("2006-01-02", endDate); err == nil {
			query = query.Where("start_time <= ?", end.Add(24*time.Hour))
		}
	}

	// 获取总数
	if err := query.Model(&models.TrainingSession{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	offset := (page - 1) * limit
	if err := query.
		Preload("ExerciseRecords").
		Preload("ExerciseRecords.Sets").
		Order("start_time DESC").
		Offset(offset).
		Limit(limit).
		Find(&sessions).Error; err != nil {
		return nil, 0, err
	}

	return sessions, total, nil
}

// GetTrainingStats 获取训练统计
func (s *HistoryService) GetTrainingStats(userID string) (*models.TrainingStats, error) {
	var stats models.TrainingStats

	// 基础统计
	var result struct {
		TotalSessions int
		TotalDuration int
		TotalCalories int
		AvgDuration   float64
	}

	if err := s.db.Model(&models.TrainingSession{}).
		Select("COUNT(*) as total_sessions, SUM(EXTRACT(EPOCH FROM (end_time - start_time))/60) as total_duration, SUM(total_calories) as total_calories, AVG(EXTRACT(EPOCH FROM (end_time - start_time))/60) as avg_duration").
		Where("user_id = ? AND is_completed = ?", userID, true).
		Scan(&result).Error; err != nil {
		return nil, err
	}

	stats.TotalSessions = result.TotalSessions
	stats.TotalDuration = result.TotalDuration
	stats.TotalCalories = result.TotalCalories
	stats.AverageDuration = result.AvgDuration

	// 连续训练统计
	longestStreak, currentStreak, err := s.calculateStreaks(userID)
	if err != nil {
		return nil, err
	}
	stats.LongestStreak = longestStreak
	stats.CurrentStreak = currentStreak

	// 分类统计
	categoryStats, err := s.getCategoryStats(userID)
	if err != nil {
		return nil, err
	}
	stats.CategoryStats = categoryStats

	// 周统计
	weeklyStats, err := s.getWeeklyStats(userID, 12)
	if err != nil {
		return nil, err
	}
	stats.WeeklyStats = weeklyStats

	return &stats, nil
}

// GetSessionDetail 获取训练会话详情
func (s *HistoryService) GetSessionDetail(userID, sessionID string) (*models.TrainingSession, error) {
	var session models.TrainingSession

	if err := s.db.
		Preload("ExerciseRecords").
		Preload("ExerciseRecords.Sets").
		Where("id = ? AND user_id = ?", sessionID, userID).
		First(&session).Error; err != nil {
		return nil, err
	}

	return &session, nil
}

// ExportTrainingData 导出训练数据
func (s *HistoryService) ExportTrainingData(userID, format, startDate, endDate string) ([]byte, error) {
	sessions, _, err := s.GetTrainingHistory(userID, 1, 1000, startDate, endDate)
	if err != nil {
		return nil, err
	}

	switch format {
	case "json":
		return json.MarshalIndent(sessions, "", "  ")
	case "csv":
		return s.exportToCSV(sessions), nil
	default:
		return nil, fmt.Errorf("不支持的导出格式: %s", format)
	}
}

// GetWeeklyStats 获取周统计
func (s *HistoryService) GetWeeklyStats(userID string, weeks int) ([]models.WeeklyStats, error) {
	var stats []models.WeeklyStats

	// 获取最近N周的数据
	endDate := time.Now()
	startDate := endDate.AddDate(0, 0, -weeks*7)

	var results []struct {
		WeekStart time.Time
		Sessions  int
		Duration  int
		Calories  int
	}

	if err := s.db.Raw(`
		SELECT 
			DATE_TRUNC('week', start_time) as week_start,
			COUNT(*) as sessions,
			SUM(EXTRACT(EPOCH FROM (end_time - start_time))/60) as duration,
			SUM(total_calories) as calories
		FROM training_sessions 
		WHERE user_id = ? AND is_completed = ? AND start_time >= ?
		GROUP BY DATE_TRUNC('week', start_time)
		ORDER BY week_start
	`, userID, true, startDate).Scan(&results).Error; err != nil {
		return nil, err
	}

	for _, result := range results {
		stats = append(stats, models.WeeklyStats{
			WeekStart: result.WeekStart,
			Sessions:  result.Sessions,
			Duration:  result.Duration,
			Calories:  result.Calories,
		})
	}

	return stats, nil
}

// GetCategoryStats 获取分类统计
func (s *HistoryService) GetCategoryStats(userID string) (map[string]int, error) {
	var results []struct {
		Category string
		Count    int
	}

	if err := s.db.Raw(`
		SELECT e.category, COUNT(*) as count
		FROM training_sessions ts
		JOIN exercise_records er ON ts.id = er.session_id
		JOIN exercises e ON er.exercise_id = e.id
		WHERE ts.user_id = ? AND ts.is_completed = ?
		GROUP BY e.category
		ORDER BY count DESC
	`, userID, true).Scan(&results).Error; err != nil {
		return nil, err
	}

	stats := make(map[string]int)
	for _, result := range results {
		stats[result.Category] = result.Count
	}

	return stats, nil
}

// calculateStreaks 计算连续训练天数
func (s *HistoryService) calculateStreaks(userID string) (int, int, error) {
	var sessions []struct {
		Date time.Time
	}

	if err := s.db.Raw(`
		SELECT DISTINCT DATE(start_time) as date
		FROM training_sessions
		WHERE user_id = ? AND is_completed = ?
		ORDER BY date DESC
	`, userID, true).Scan(&sessions).Error; err != nil {
		return 0, 0, err
	}

	if len(sessions) == 0 {
		return 0, 0, nil
	}

	longestStreak := 0
	currentStreak := 0
	tempStreak := 1

	// 计算最长连续天数
	for i := 1; i < len(sessions); i++ {
		if sessions[i-1].Date.Sub(sessions[i].Date).Hours() <= 24 {
			tempStreak++
		} else {
			if tempStreak > longestStreak {
				longestStreak = tempStreak
			}
			tempStreak = 1
		}
	}
	if tempStreak > longestStreak {
		longestStreak = tempStreak
	}

	// 计算当前连续天数
	today := time.Now().Truncate(24 * time.Hour)
	currentStreak = 0
	for i, session := range sessions {
		if i == 0 {
			if session.Date.Equal(today) || session.Date.Equal(today.Add(-24*time.Hour)) {
				currentStreak = 1
			} else {
				break
			}
		} else {
			if sessions[i-1].Date.Sub(session.Date).Hours() <= 24 {
				currentStreak++
			} else {
				break
			}
		}
	}

	return longestStreak, currentStreak, nil
}

// exportToCSV 导出为CSV格式
func (s *HistoryService) exportToCSV(sessions []models.TrainingSession) []byte {
	csv := "训练日期,训练计划,开始时间,结束时间,训练时长(分钟),消耗卡路里,是否完成\n"
	
	for _, session := range sessions {
		csv += fmt.Sprintf("%s,%s,%s,%s,%d,%d,%t\n",
			session.StartTime.Format("2006-01-02"),
			session.PlanID,
			session.StartTime.Format("15:04:05"),
			session.EndTime.Format("15:04:05"),
			int(session.EndTime.Sub(session.StartTime).Minutes()),
			session.TotalCalories,
			session.IsCompleted,
		)
	}
	
	return []byte(csv)
}
EOF

    log_success "后端训练历史 API 生成完成"
}

# 主执行函数
main() {
    log_info "开始生成 Tab2: 训练历史模块..."
    
    generate_frontend_history_page
    generate_backend_history_api
    
    log_success "Tab2: 训练历史模块生成完成！"
}

# 执行主函数
main "$@"
