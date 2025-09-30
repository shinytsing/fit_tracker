package repositories

import (
	"fittracker/backend/internal/domain/models"

	"gorm.io/gorm"
)

// userRepository 用户仓储实现
type userRepository struct {
	db *gorm.DB
}

// NewUserRepository 创建用户仓储
func NewUserRepository(db *gorm.DB) UserRepository {
	return &userRepository{db: db}
}

func (r *userRepository) Create(user *models.User) error {
	return r.db.Create(user).Error
}

func (r *userRepository) GetByID(id uint) (*models.User, error) {
	var user models.User
	err := r.db.First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) GetByEmail(email string) (*models.User, error) {
	var user models.User
	err := r.db.Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) GetByUsername(username string) (*models.User, error) {
	var user models.User
	err := r.db.Where("username = ?", username).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) Update(user *models.User) error {
	return r.db.Save(user).Error
}

func (r *userRepository) Delete(id uint) error {
	return r.db.Delete(&models.User{}, id).Error
}

func (r *userRepository) GetStats(userID uint) (*models.UserStats, error) {
	var stats models.UserStats

	// 获取训练记录统计
	var totalWorkouts int64
	r.db.Model(&models.Workout{}).Where("user_id = ?", userID).Count(&totalWorkouts)
	stats.TotalWorkouts = int(totalWorkouts)

	// 获取签到记录统计
	var totalCheckins int64
	r.db.Model(&models.Checkin{}).Where("user_id = ?", userID).Count(&totalCheckins)
	stats.TotalCheckins = int(totalCheckins)

	// 获取关注者数量
	var followersCount int64
	r.db.Model(&models.Follow{}).Where("following_id = ?", userID).Count(&followersCount)
	stats.FollowersCount = int(followersCount)

	// 获取关注数量
	var followingCount int64
	r.db.Model(&models.Follow{}).Where("follower_id = ?", userID).Count(&followingCount)
	stats.FollowingCount = int(followingCount)

	stats.UserID = userID
	return &stats, nil
}

// workoutRepository 训练记录仓储实现
type workoutRepository struct {
	db *gorm.DB
}

// NewWorkoutRepository 创建训练记录仓储
func NewWorkoutRepository(db *gorm.DB) WorkoutRepository {
	return &workoutRepository{db: db}
}

func (r *workoutRepository) Create(workout *models.Workout) error {
	return r.db.Create(workout).Error
}

func (r *workoutRepository) GetByID(id uint) (*models.Workout, error) {
	var workout models.Workout
	err := r.db.Preload("User").Preload("Plan").Preload("Exercises").First(&workout, id).Error
	if err != nil {
		return nil, err
	}
	return &workout, nil
}

func (r *workoutRepository) GetByUserID(userID uint, limit, offset int) ([]*models.Workout, error) {
	var workouts []*models.Workout
	err := r.db.Where("user_id = ?", userID).
		Preload("User").Preload("Plan").Preload("Exercises").
		Limit(limit).Offset(offset).
		Order("created_at DESC").
		Find(&workouts).Error
	return workouts, err
}

func (r *workoutRepository) Update(workout *models.Workout) error {
	return r.db.Save(workout).Error
}

func (r *workoutRepository) Delete(id uint) error {
	return r.db.Delete(&models.Workout{}, id).Error
}

// trainingPlanRepository 训练计划仓储实现
type trainingPlanRepository struct {
	db *gorm.DB
}

// NewTrainingPlanRepository 创建训练计划仓储
func NewTrainingPlanRepository(db *gorm.DB) TrainingPlanRepository {
	return &trainingPlanRepository{db: db}
}

func (r *trainingPlanRepository) Create(plan *models.TrainingPlan) error {
	return r.db.Create(plan).Error
}

func (r *trainingPlanRepository) GetByID(id uint) (*models.TrainingPlan, error) {
	var plan models.TrainingPlan
	err := r.db.Preload("Workouts").First(&plan, id).Error
	if err != nil {
		return nil, err
	}
	return &plan, nil
}

func (r *trainingPlanRepository) GetAll(limit, offset int) ([]*models.TrainingPlan, error) {
	var plans []*models.TrainingPlan
	err := r.db.Where("is_public = ?", true).
		Limit(limit).Offset(offset).
		Order("created_at DESC").
		Find(&plans).Error
	return plans, err
}

func (r *trainingPlanRepository) Update(plan *models.TrainingPlan) error {
	return r.db.Save(plan).Error
}

func (r *trainingPlanRepository) Delete(id uint) error {
	return r.db.Delete(&models.TrainingPlan{}, id).Error
}

// exerciseRepository 运动动作仓储实现
type exerciseRepository struct {
	db *gorm.DB
}

// NewExerciseRepository 创建运动动作仓储
func NewExerciseRepository(db *gorm.DB) ExerciseRepository {
	return &exerciseRepository{db: db}
}

func (r *exerciseRepository) Create(exercise *models.Exercise) error {
	return r.db.Create(exercise).Error
}

func (r *exerciseRepository) GetByID(id uint) (*models.Exercise, error) {
	var exercise models.Exercise
	err := r.db.First(&exercise, id).Error
	if err != nil {
		return nil, err
	}
	return &exercise, nil
}

func (r *exerciseRepository) GetByCategory(category string, limit, offset int) ([]*models.Exercise, error) {
	var exercises []*models.Exercise
	query := r.db
	if category != "" {
		query = query.Where("category = ?", category)
	}
	err := query.Limit(limit).Offset(offset).Order("name ASC").Find(&exercises).Error
	return exercises, err
}

func (r *exerciseRepository) Update(exercise *models.Exercise) error {
	return r.db.Save(exercise).Error
}

func (r *exerciseRepository) Delete(id uint) error {
	return r.db.Delete(&models.Exercise{}, id).Error
}

// healthRecordRepository 健康记录仓储实现
type healthRecordRepository struct {
	db *gorm.DB
}

// NewHealthRecordRepository 创建健康记录仓储
func NewHealthRecordRepository(db *gorm.DB) HealthRecordRepository {
	return &healthRecordRepository{db: db}
}

func (r *healthRecordRepository) Create(record *models.HealthRecord) error {
	return r.db.Create(record).Error
}

func (r *healthRecordRepository) GetByID(id uint) (*models.HealthRecord, error) {
	var record models.HealthRecord
	err := r.db.Preload("User").First(&record, id).Error
	if err != nil {
		return nil, err
	}
	return &record, nil
}

func (r *healthRecordRepository) GetByUserIDAndType(userID uint, recordType string, limit, offset int) ([]*models.HealthRecord, error) {
	var records []*models.HealthRecord
	query := r.db.Where("user_id = ?", userID)
	if recordType != "" {
		query = query.Where("type = ?", recordType)
	}
	err := query.Preload("User").
		Limit(limit).Offset(offset).
		Order("date DESC").
		Find(&records).Error
	return records, err
}

func (r *healthRecordRepository) Update(record *models.HealthRecord) error {
	return r.db.Save(record).Error
}

func (r *healthRecordRepository) Delete(id uint) error {
	return r.db.Delete(&models.HealthRecord{}, id).Error
}

// nutritionRecordRepository 营养记录仓储实现
type nutritionRecordRepository struct {
	db *gorm.DB
}

// NewNutritionRecordRepository 创建营养记录仓储
func NewNutritionRecordRepository(db *gorm.DB) NutritionRecordRepository {
	return &nutritionRecordRepository{db: db}
}

func (r *nutritionRecordRepository) Create(record *models.NutritionRecord) error {
	return r.db.Create(record).Error
}

func (r *nutritionRecordRepository) GetByID(id uint) (*models.NutritionRecord, error) {
	var record models.NutritionRecord
	err := r.db.Preload("User").First(&record, id).Error
	if err != nil {
		return nil, err
	}
	return &record, nil
}

func (r *nutritionRecordRepository) GetByUserID(userID uint, limit, offset int) ([]*models.NutritionRecord, error) {
	var records []*models.NutritionRecord
	err := r.db.Where("user_id = ?", userID).
		Preload("User").
		Limit(limit).Offset(offset).
		Order("date DESC").
		Find(&records).Error
	return records, err
}

func (r *nutritionRecordRepository) Update(record *models.NutritionRecord) error {
	return r.db.Save(record).Error
}

func (r *nutritionRecordRepository) Delete(id uint) error {
	return r.db.Delete(&models.NutritionRecord{}, id).Error
}

// checkinRepository 签到记录仓储实现
type checkinRepository struct {
	db *gorm.DB
}

// NewCheckinRepository 创建签到记录仓储
func NewCheckinRepository(db *gorm.DB) CheckinRepository {
	return &checkinRepository{db: db}
}

func (r *checkinRepository) Create(checkin *models.Checkin) error {
	return r.db.Create(checkin).Error
}

func (r *checkinRepository) GetByID(id uint) (*models.Checkin, error) {
	var checkin models.Checkin
	err := r.db.Preload("User").First(&checkin, id).Error
	if err != nil {
		return nil, err
	}
	return &checkin, nil
}

func (r *checkinRepository) GetByUserID(userID uint, limit, offset int) ([]*models.Checkin, error) {
	var checkins []*models.Checkin
	err := r.db.Where("user_id = ?", userID).
		Preload("User").
		Limit(limit).Offset(offset).
		Order("date DESC").
		Find(&checkins).Error
	return checkins, err
}

func (r *checkinRepository) GetStreak(userID uint) (int, error) {
	// 这里需要实现连续签到天数的计算逻辑
	// 简化实现，返回0
	return 0, nil
}

func (r *checkinRepository) Update(checkin *models.Checkin) error {
	return r.db.Save(checkin).Error
}

func (r *checkinRepository) Delete(id uint) error {
	return r.db.Delete(&models.Checkin{}, id).Error
}

// postRepository 动态仓储实现
type postRepository struct {
	db *gorm.DB
}

// NewPostRepository 创建动态仓储
func NewPostRepository(db *gorm.DB) PostRepository {
	return &postRepository{db: db}
}

func (r *postRepository) Create(post *models.Post) error {
	return r.db.Create(post).Error
}

func (r *postRepository) GetByID(id uint) (*models.Post, error) {
	var post models.Post
	err := r.db.Preload("User").Preload("Likes").Preload("Comments").First(&post, id).Error
	if err != nil {
		return nil, err
	}
	return &post, nil
}

func (r *postRepository) GetFeed(userID uint, limit, offset int) ([]*models.Post, error) {
	var posts []*models.Post
	err := r.db.Where("is_public = ?", true).
		Preload("User").Preload("Likes").Preload("Comments").
		Limit(limit).Offset(offset).
		Order("created_at DESC").
		Find(&posts).Error
	return posts, err
}

func (r *postRepository) Update(post *models.Post) error {
	return r.db.Save(post).Error
}

func (r *postRepository) Delete(id uint) error {
	return r.db.Delete(&models.Post{}, id).Error
}

// likeRepository 点赞仓储实现
type likeRepository struct {
	db *gorm.DB
}

// NewLikeRepository 创建点赞仓储
func NewLikeRepository(db *gorm.DB) LikeRepository {
	return &likeRepository{db: db}
}

func (r *likeRepository) Create(like *models.Like) error {
	return r.db.Create(like).Error
}

func (r *likeRepository) GetByUserAndPost(userID, postID uint) (*models.Like, error) {
	var like models.Like
	err := r.db.Where("user_id = ? AND post_id = ?", userID, postID).First(&like).Error
	if err != nil {
		return nil, err
	}
	return &like, nil
}

func (r *likeRepository) DeleteByUserAndPost(userID, postID uint) error {
	return r.db.Where("user_id = ? AND post_id = ?", userID, postID).Delete(&models.Like{}).Error
}

func (r *likeRepository) GetByPostID(postID uint) ([]*models.Like, error) {
	var likes []*models.Like
	err := r.db.Where("post_id = ?", postID).Preload("User").Find(&likes).Error
	return likes, err
}

// commentRepository 评论仓储实现
type commentRepository struct {
	db *gorm.DB
}

// NewCommentRepository 创建评论仓储
func NewCommentRepository(db *gorm.DB) CommentRepository {
	return &commentRepository{db: db}
}

func (r *commentRepository) Create(comment *models.Comment) error {
	return r.db.Create(comment).Error
}

func (r *commentRepository) GetByID(id uint) (*models.Comment, error) {
	var comment models.Comment
	err := r.db.Preload("User").Preload("Post").First(&comment, id).Error
	if err != nil {
		return nil, err
	}
	return &comment, nil
}

func (r *commentRepository) GetByPostID(postID uint, limit, offset int) ([]*models.Comment, error) {
	var comments []*models.Comment
	err := r.db.Where("post_id = ?", postID).
		Preload("User").
		Limit(limit).Offset(offset).
		Order("created_at ASC").
		Find(&comments).Error
	return comments, err
}

func (r *commentRepository) Update(comment *models.Comment) error {
	return r.db.Save(comment).Error
}

func (r *commentRepository) Delete(id uint) error {
	return r.db.Delete(&models.Comment{}, id).Error
}

// followRepository 关注关系仓储实现
type followRepository struct {
	db *gorm.DB
}

// NewFollowRepository 创建关注关系仓储
func NewFollowRepository(db *gorm.DB) FollowRepository {
	return &followRepository{db: db}
}

func (r *followRepository) Create(follow *models.Follow) error {
	return r.db.Create(follow).Error
}

func (r *followRepository) GetByFollowerAndFollowing(followerID, followingID uint) (*models.Follow, error) {
	var follow models.Follow
	err := r.db.Where("follower_id = ? AND following_id = ?", followerID, followingID).First(&follow).Error
	if err != nil {
		return nil, err
	}
	return &follow, nil
}

func (r *followRepository) DeleteByFollowerAndFollowing(followerID, followingID uint) error {
	return r.db.Where("follower_id = ? AND following_id = ?", followerID, followingID).Delete(&models.Follow{}).Error
}

func (r *followRepository) GetFollowers(userID uint, limit, offset int) ([]*models.User, error) {
	var users []*models.User
	err := r.db.Table("users").
		Joins("JOIN follows ON users.id = follows.follower_id").
		Where("follows.following_id = ?", userID).
		Limit(limit).Offset(offset).
		Find(&users).Error
	return users, err
}

func (r *followRepository) GetFollowing(userID uint, limit, offset int) ([]*models.User, error) {
	var users []*models.User
	err := r.db.Table("users").
		Joins("JOIN follows ON users.id = follows.following_id").
		Where("follows.follower_id = ?", userID).
		Limit(limit).Offset(offset).
		Find(&users).Error
	return users, err
}

// challengeRepository 挑战仓储实现
type challengeRepository struct {
	db *gorm.DB
}

// NewChallengeRepository 创建挑战仓储
func NewChallengeRepository(db *gorm.DB) ChallengeRepository {
	return &challengeRepository{db: db}
}

func (r *challengeRepository) Create(challenge *models.Challenge) error {
	return r.db.Create(challenge).Error
}

func (r *challengeRepository) GetByID(id uint) (*models.Challenge, error) {
	var challenge models.Challenge
	err := r.db.Preload("Participants").First(&challenge, id).Error
	if err != nil {
		return nil, err
	}
	return &challenge, nil
}

func (r *challengeRepository) GetAll(limit, offset int) ([]*models.Challenge, error) {
	var challenges []*models.Challenge
	err := r.db.Where("is_active = ?", true).
		Limit(limit).Offset(offset).
		Order("created_at DESC").
		Find(&challenges).Error
	return challenges, err
}

func (r *challengeRepository) Update(challenge *models.Challenge) error {
	return r.db.Save(challenge).Error
}

func (r *challengeRepository) Delete(id uint) error {
	return r.db.Delete(&models.Challenge{}, id).Error
}

func (r *challengeRepository) JoinChallenge(userID, challengeID uint) error {
	participant := &models.ChallengeParticipant{
		UserID:      userID,
		ChallengeID: challengeID,
		Progress:    0,
	}
	return r.db.Create(participant).Error
}

func (r *challengeRepository) GetLeaderboard(challengeID uint) ([]*models.ChallengeParticipant, error) {
	var participants []*models.ChallengeParticipant
	err := r.db.Where("challenge_id = ?", challengeID).
		Preload("User").
		Order("progress DESC").
		Find(&participants).Error
	return participants, err
}
