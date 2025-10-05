package services

import (
	"fmt"
	"time"

	"gymates/internal/models"
	"gymates/pkg/logger"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// CommunityService 社区服务
type CommunityService struct {
	db *gorm.DB
}

// NewCommunityService 创建社区服务实例
func NewCommunityService(db *gorm.DB) *CommunityService {
	return &CommunityService{db: db}
}

// GetPosts 获取社区动态列表
func (s *CommunityService) GetPosts(userID string, skip, limit int, postType string) ([]models.PostResponse, error) {
	var posts []models.Post
	var responses []models.PostResponse

	// 使用原始SQL查询来避免GORM的字段映射问题
	sql := `
		SELECT id, user_id, content, type, images, video_url, tags, location, 
		       like_count, comment_count, share_count, is_featured, is_pinned, 
		       created_at, updated_at
		FROM posts
	`

	args := []interface{}{}

	// 根据类型筛选
	if postType != "" && postType != "all" {
		sql += " WHERE type = ?"
		args = append(args, postType)
	}

	// 排序：置顶 > 精选 > 时间
	sql += " ORDER BY is_pinned DESC, is_featured DESC, created_at DESC"

	// 分页
	sql += " LIMIT ? OFFSET ?"
	args = append(args, limit, skip)

	if err := s.db.Raw(sql, args...).Scan(&posts).Error; err != nil {
		return nil, fmt.Errorf("获取动态列表失败: %v", err)
	}

	for _, post := range posts {
		// 检查当前用户是否点赞
		var likeCount int64
		s.db.Model(&models.PostLike{}).Where("post_id = ? AND user_id = ?", post.ID, userID).Count(&likeCount)

		response := models.PostResponse{
			ID:           post.ID,
			UserID:       post.UserID,
			Content:      post.Content,
			Type:         post.Type,
			Images:       post.Images,
			VideoURL:     post.VideoURL,
			Tags:         post.Tags,
			Location:     post.Location,
			WorkoutData:  post.WorkoutData,
			LikeCount:    post.LikeCount,
			CommentCount: post.CommentCount,
			ShareCount:   post.ShareCount,
			IsLiked:      likeCount > 0,
			IsFeatured:   post.IsFeatured,
			IsPinned:     post.IsPinned,
			CreatedAt:    post.CreatedAt,
			UpdatedAt:    post.UpdatedAt,
			User:         post.User,
			Comments:     post.Comments,
		}
		responses = append(responses, response)
	}

	return responses, nil
}

// CreatePost 创建社区动态
func (s *CommunityService) CreatePost(userID string, requestData models.CreatePostRequest) (*models.PostResponse, error) {
	// 创建动态
	post := models.Post{
		ID:          uuid.New().String(),
		UserID:      userID,
		Content:     requestData.Content,
		Type:        requestData.Type,
		Images:      requestData.Images,
		VideoURL:    requestData.VideoURL,
		Tags:        requestData.Tags,
		Location:    requestData.Location,
		WorkoutData: requestData.WorkoutData,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	if err := s.db.Create(&post).Error; err != nil {
		return nil, fmt.Errorf("创建动态失败: %v", err)
	}

	// 获取用户信息
	var user models.User
	s.db.First(&user, "id = ?", userID)

	response := &models.PostResponse{
		ID:           post.ID,
		UserID:       post.UserID,
		Content:      post.Content,
		Type:         post.Type,
		Images:       post.Images,
		VideoURL:     post.VideoURL,
		Tags:         post.Tags,
		Location:     post.Location,
		WorkoutData:  post.WorkoutData,
		LikeCount:    post.LikeCount,
		CommentCount: post.CommentCount,
		ShareCount:   post.ShareCount,
		IsLiked:      false,
		IsFeatured:   post.IsFeatured,
		IsPinned:     post.IsPinned,
		CreatedAt:    post.CreatedAt,
		UpdatedAt:    post.UpdatedAt,
		User:         user,
		Comments:     []models.Comment{},
	}

	return response, nil
}

// GetPost 获取动态详情
func (s *CommunityService) GetPost(postID string, userID string) (*models.PostResponse, error) {
	var post models.Post
	if err := s.db.Preload("User").Preload("Comments").Preload("Likes").
		First(&post, "id = ?", postID).Error; err != nil {
		return nil, fmt.Errorf("动态不存在: %v", err)
	}

	// 检查当前用户是否点赞
	var likeCount int64
	s.db.Model(&models.PostLike{}).Where("post_id = ? AND user_id = ?", post.ID, userID).Count(&likeCount)

	response := &models.PostResponse{
		ID:           post.ID,
		UserID:       post.UserID,
		Content:      post.Content,
		Type:         post.Type,
		Images:       post.Images,
		VideoURL:     post.VideoURL,
		Tags:         post.Tags,
		Location:     post.Location,
		WorkoutData:  post.WorkoutData,
		LikeCount:    post.LikeCount,
		CommentCount: post.CommentCount,
		ShareCount:   post.ShareCount,
		IsLiked:      likeCount > 0,
		IsFeatured:   post.IsFeatured,
		IsPinned:     post.IsPinned,
		CreatedAt:    post.CreatedAt,
		UpdatedAt:    post.UpdatedAt,
		User:         post.User,
		Comments:     post.Comments,
	}

	return response, nil
}

// UpdatePost 更新动态
func (s *CommunityService) UpdatePost(postID string, userID string, requestData models.UpdatePostRequest) (*models.PostResponse, error) {
	var post models.Post
	if err := s.db.First(&post, "id = ? AND user_id = ?", postID, userID).Error; err != nil {
		return nil, fmt.Errorf("动态不存在或无权限: %v", err)
	}

	// 更新字段
	if requestData.Content != "" {
		post.Content = requestData.Content
	}
	if requestData.Images != nil {
		post.Images = requestData.Images
	}
	if requestData.VideoURL != "" {
		post.VideoURL = requestData.VideoURL
	}
	if requestData.Tags != nil {
		post.Tags = requestData.Tags
	}
	if requestData.Location != "" {
		post.Location = requestData.Location
	}
	if requestData.WorkoutData != nil {
		post.WorkoutData = requestData.WorkoutData
	}
	post.UpdatedAt = time.Now()

	if err := s.db.Save(&post).Error; err != nil {
		return nil, fmt.Errorf("更新动态失败: %v", err)
	}

	// 获取用户信息
	var user models.User
	s.db.First(&user, "id = ?", userID)

	response := &models.PostResponse{
		ID:           post.ID,
		UserID:       post.UserID,
		Content:      post.Content,
		Type:         post.Type,
		Images:       post.Images,
		VideoURL:     post.VideoURL,
		Tags:         post.Tags,
		Location:     post.Location,
		WorkoutData:  post.WorkoutData,
		LikeCount:    post.LikeCount,
		CommentCount: post.CommentCount,
		ShareCount:   post.ShareCount,
		IsLiked:      false,
		IsFeatured:   post.IsFeatured,
		IsPinned:     post.IsPinned,
		CreatedAt:    post.CreatedAt,
		UpdatedAt:    post.UpdatedAt,
		User:         user,
		Comments:     []models.Comment{},
	}

	return response, nil
}

// DeletePost 删除动态
func (s *CommunityService) DeletePost(postID string, userID string) error {
	var post models.Post
	if err := s.db.First(&post, "id = ? AND user_id = ?", postID, userID).Error; err != nil {
		return fmt.Errorf("动态不存在或无权限: %v", err)
	}

	// 开始事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 删除相关数据
	if err := tx.Where("post_id = ?", postID).Delete(&models.PostLike{}).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("删除点赞记录失败: %v", err)
	}

	if err := tx.Where("post_id = ?", postID).Delete(&models.Comment{}).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("删除评论失败: %v", err)
	}

	if err := tx.Delete(&post).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("删除动态失败: %v", err)
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		return fmt.Errorf("提交事务失败: %v", err)
	}

	logger.Info.Printf("动态删除成功: post_id=%s, user_id=%s", postID, userID)

	return nil
}

// LikePost 点赞动态
func (s *CommunityService) LikePost(postID string, userID string) error {
	// 检查是否已经点赞
	var existingLike models.PostLike
	if err := s.db.Where("post_id = ? AND user_id = ?", postID, userID).First(&existingLike).Error; err == nil {
		return fmt.Errorf("已经点赞过了")
	}

	// 开始事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 创建点赞记录
	like := models.PostLike{
		ID:        uuid.New().String(),
		PostID:    postID,
		UserID:    userID,
		CreatedAt: time.Now(),
	}

	if err := tx.Create(&like).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("创建点赞记录失败: %v", err)
	}

	// 更新动态点赞数
	if err := tx.Model(&models.Post{}).Where("id = ?", postID).UpdateColumn("like_count", gorm.Expr("like_count + 1")).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("更新点赞数失败: %v", err)
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		return fmt.Errorf("提交事务失败: %v", err)
	}

	return nil
}

// UnlikePost 取消点赞动态
func (s *CommunityService) UnlikePost(postID string, userID string) error {
	// 检查是否已经点赞
	var existingLike models.PostLike
	if err := s.db.Where("post_id = ? AND user_id = ?", postID, userID).First(&existingLike).Error; err != nil {
		return fmt.Errorf("还没有点赞")
	}

	// 开始事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 删除点赞记录
	if err := tx.Delete(&existingLike).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("删除点赞记录失败: %v", err)
	}

	// 更新动态点赞数
	if err := tx.Model(&models.Post{}).Where("id = ?", postID).UpdateColumn("like_count", gorm.Expr("like_count - 1")).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("更新点赞数失败: %v", err)
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		return fmt.Errorf("提交事务失败: %v", err)
	}

	return nil
}

// CreateComment 创建评论
func (s *CommunityService) CreateComment(postID string, userID string, requestData models.CreateCommentRequest) (*models.CommentResponse, error) {
	// 创建评论
	comment := models.Comment{
		ID:        uuid.New().String(),
		PostID:    postID,
		UserID:    userID,
		Content:   requestData.Content,
		ParentID:  requestData.ParentID,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := s.db.Create(&comment).Error; err != nil {
		return nil, fmt.Errorf("创建评论失败: %v", err)
	}

	// 更新动态评论数
	if err := s.db.Model(&models.Post{}).Where("id = ?", postID).UpdateColumn("comment_count", gorm.Expr("comment_count + 1")).Error; err != nil {
		return nil, fmt.Errorf("更新评论数失败: %v", err)
	}

	// 获取用户信息
	var user models.User
	s.db.First(&user, "id = ?", userID)

	response := &models.CommentResponse{
		ID:        comment.ID,
		PostID:    comment.PostID,
		UserID:    comment.UserID,
		Content:   comment.Content,
		ParentID:  comment.ParentID,
		LikeCount: comment.LikeCount,
		CreatedAt: comment.CreatedAt,
		UpdatedAt: comment.UpdatedAt,
		User:      user,
		Replies:   []models.CommentResponse{},
	}

	return response, nil
}

// GetComments 获取评论列表
func (s *CommunityService) GetComments(postID string, skip, limit int) ([]models.CommentResponse, error) {
	var comments []models.Comment
	var responses []models.CommentResponse

	if err := s.db.Preload("User").Preload("Replies").
		Where("post_id = ? AND parent_id = ''", postID).
		Order("created_at DESC").
		Offset(skip).Limit(limit).Find(&comments).Error; err != nil {
		return nil, fmt.Errorf("获取评论列表失败: %v", err)
	}

	for _, comment := range comments {
		response := models.CommentResponse{
			ID:        comment.ID,
			PostID:    comment.PostID,
			UserID:    comment.UserID,
			Content:   comment.Content,
			ParentID:  comment.ParentID,
			LikeCount: comment.LikeCount,
			CreatedAt: comment.CreatedAt,
			UpdatedAt: comment.UpdatedAt,
			User:      comment.User,
			Replies:   []models.CommentResponse{},
		}
		responses = append(responses, response)
	}

	return responses, nil
}

// GetTrendingPosts 获取热门动态
func (s *CommunityService) GetTrendingPosts(userID string, skip, limit int) ([]models.PostResponse, error) {
	var posts []models.Post
	var responses []models.PostResponse

	// 热门算法：点赞数 + 评论数 + 分享数，按时间权重排序
	query := s.db.Preload("User").Preload("Comments").Preload("Likes").
		Where("created_at >= ?", time.Now().AddDate(0, 0, -7)). // 最近7天
		Order("(like_count * 2 + comment_count * 3 + share_count) DESC, created_at DESC")

	if err := query.Offset(skip).Limit(limit).Find(&posts).Error; err != nil {
		return nil, fmt.Errorf("获取热门动态失败: %v", err)
	}

	for _, post := range posts {
		// 检查当前用户是否点赞
		var likeCount int64
		s.db.Model(&models.PostLike{}).Where("post_id = ? AND user_id = ?", post.ID, userID).Count(&likeCount)

		response := models.PostResponse{
			ID:           post.ID,
			UserID:       post.UserID,
			Content:      post.Content,
			Type:         post.Type,
			Images:       post.Images,
			VideoURL:     post.VideoURL,
			Tags:         post.Tags,
			Location:     post.Location,
			WorkoutData:  post.WorkoutData,
			LikeCount:    post.LikeCount,
			CommentCount: post.CommentCount,
			ShareCount:   post.ShareCount,
			IsLiked:      likeCount > 0,
			IsFeatured:   post.IsFeatured,
			IsPinned:     post.IsPinned,
			CreatedAt:    post.CreatedAt,
			UpdatedAt:    post.UpdatedAt,
			User:         post.User,
			Comments:     post.Comments,
		}
		responses = append(responses, response)
	}

	return responses, nil
}

// GetRecommendedCoaches 获取推荐教练
func (s *CommunityService) GetRecommendedCoaches(userID string, skip, limit int) ([]models.User, error) {
	var coaches []models.User

	// 模拟推荐教练数据（实际应该基于算法推荐）
	if err := s.db.Where("is_verified = ?", true).
		Order("follower_count DESC").
		Offset(skip).Limit(limit).Find(&coaches).Error; err != nil {
		return nil, fmt.Errorf("获取推荐教练失败: %v", err)
	}

	return coaches, nil
}
