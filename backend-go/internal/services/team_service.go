package services

import (
	"encoding/json"
	"fmt"
	"time"

	"gymates/internal/models"

	"gorm.io/gorm"
)

type TeamService struct {
	db *gorm.DB
}

func NewTeamService(db *gorm.DB) *TeamService {
	return &TeamService{
		db: db,
	}
}

// CreateTeam 创建搭子团队
func (s *TeamService) CreateTeam(userID uint, req *models.CreateTeamRequest) (*models.Team, error) {
	// 将标签转换为JSON
	tagsJSON, _ := json.Marshal(req.Tags)

	// 创建成员数组，包含创建者
	members := []uint{userID}
	membersJSON, _ := json.Marshal(members)

	team := &models.Team{
		Name:        req.Name,
		Description: req.Description,
		CreatorID:   userID,
		Members:     string(membersJSON),
		MaxMembers:  req.MaxMembers,
		Status:      "active",
		Tags:        string(tagsJSON),
		Location:    req.Location,
		IsPublic:    req.IsPublic,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	if err := s.db.Create(team).Error; err != nil {
		return nil, fmt.Errorf("创建搭子团队失败: %w", err)
	}

	// 预加载创建者信息
	if err := s.db.Preload("Creator").First(team, team.ID).Error; err != nil {
		return nil, fmt.Errorf("获取团队信息失败: %w", err)
	}

	return team, nil
}

// GetTeams 获取搭子团队列表
func (s *TeamService) GetTeams(page, limit int) ([]*models.Team, bool, error) {
	var teams []*models.Team
	offset := (page - 1) * limit

	// 查询公开的团队
	if err := s.db.Where("is_public = ? AND status = ?", true, "active").
		Preload("Creator").
		Order("created_at DESC").
		Limit(limit + 1).
		Offset(offset).
		Find(&teams).Error; err != nil {
		return nil, false, fmt.Errorf("获取搭子团队列表失败: %w", err)
	}

	hasMore := len(teams) > limit
	if hasMore {
		teams = teams[:limit]
	}

	return teams, hasMore, nil
}

// GetTeamByID 根据ID获取团队详情
func (s *TeamService) GetTeamByID(teamID uint) (*models.Team, error) {
	var team models.Team
	if err := s.db.Preload("Creator").First(&team, teamID).Error; err != nil {
		return nil, fmt.Errorf("获取团队详情失败: %w", err)
	}
	return &team, nil
}

// JoinTeam 加入搭子团队
func (s *TeamService) JoinTeam(teamID, userID uint, req *models.JoinTeamRequest) error {
	// 获取团队信息
	var team models.Team
	if err := s.db.First(&team, teamID).Error; err != nil {
		return fmt.Errorf("团队不存在: %w", err)
	}

	// 检查团队状态
	if team.Status != "active" {
		return fmt.Errorf("团队已关闭或已满")
	}

	// 解析现有成员
	var members []uint
	if err := json.Unmarshal([]byte(team.Members), &members); err != nil {
		return fmt.Errorf("解析成员列表失败: %w", err)
	}

	// 检查是否已经是成员
	for _, memberID := range members {
		if memberID == userID {
			return fmt.Errorf("您已经是团队成员")
		}
	}

	// 检查团队是否已满
	if len(members) >= team.MaxMembers {
		return fmt.Errorf("团队已满")
	}

	// 添加新成员
	members = append(members, userID)
	membersJSON, _ := json.Marshal(members)

	// 更新团队
	updates := map[string]interface{}{
		"members":    string(membersJSON),
		"updated_at": time.Now(),
	}

	// 如果团队已满，更新状态
	if len(members) >= team.MaxMembers {
		updates["status"] = "full"
	}

	if err := s.db.Model(&team).Updates(updates).Error; err != nil {
		return fmt.Errorf("加入团队失败: %w", err)
	}

	return nil
}

// GetUserTeams 获取用户参与的团队
func (s *TeamService) GetUserTeams(userID uint, page, limit int) ([]*models.Team, bool, error) {
	var teams []*models.Team
	offset := (page - 1) * limit

	// 查询用户参与的团队（作为创建者或成员）
	if err := s.db.Where("creator_id = ? OR members @> ?", userID, fmt.Sprintf(`[%d]`, userID)).
		Preload("Creator").
		Order("created_at DESC").
		Limit(limit + 1).
		Offset(offset).
		Find(&teams).Error; err != nil {
		return nil, false, fmt.Errorf("获取用户团队列表失败: %w", err)
	}

	hasMore := len(teams) > limit
	if hasMore {
		teams = teams[:limit]
	}

	return teams, hasMore, nil
}

