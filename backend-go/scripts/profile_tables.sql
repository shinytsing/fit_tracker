-- FitTracker 个人中心模块数据库表设计
-- 包含用户资料、统计、成就、设置、活动历史等表

-- 用户资料表（扩展）
CREATE TABLE user_profiles (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    nickname VARCHAR(50) NOT NULL COMMENT '昵称',
    bio TEXT COMMENT '个人简介',
    avatar VARCHAR(500) COMMENT '头像URL',
    gender ENUM('male', 'female', 'other') COMMENT '性别',
    birthday DATE COMMENT '生日',
    height INT COMMENT '身高（厘米）',
    weight INT COMMENT '体重（千克）',
    location VARCHAR(200) COMMENT '所在地',
    phone VARCHAR(20) COMMENT '手机号',
    email VARCHAR(100) COMMENT '邮箱',
    is_public BOOLEAN DEFAULT TRUE COMMENT '是否公开资料',
    allow_follow BOOLEAN DEFAULT TRUE COMMENT '是否允许关注',
    level INT DEFAULT 1 COMMENT '用户等级',
    points INT DEFAULT 0 COMMENT '积分',
    experience INT DEFAULT 0 COMMENT '经验值',
    training_days INT DEFAULT 0 COMMENT '训练天数',
    total_training_minutes INT DEFAULT 0 COMMENT '总训练时长（分钟）',
    completed_workouts INT DEFAULT 0 COMMENT '完成训练次数',
    followers_count INT DEFAULT 0 COMMENT '粉丝数',
    following_count INT DEFAULT 0 COMMENT '关注数',
    likes_count INT DEFAULT 0 COMMENT '获赞数',
    achievements_count INT DEFAULT 0 COMMENT '成就数量',
    is_online BOOLEAN DEFAULT FALSE COMMENT '是否在线',
    last_login_at TIMESTAMP NULL COMMENT '最后登录时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_id (user_id),
    INDEX idx_nickname (nickname),
    INDEX idx_level (level),
    INDEX idx_points (points),
    INDEX idx_training_days (training_days),
    INDEX idx_is_public (is_public),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户资料表';

-- 用户统计表
CREATE TABLE user_stats (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    stat_date DATE NOT NULL COMMENT '统计日期',
    total_training_minutes INT DEFAULT 0 COMMENT '总训练时长（分钟）',
    completed_workouts INT DEFAULT 0 COMMENT '完成训练次数',
    total_calories_burned INT DEFAULT 0 COMMENT '总消耗卡路里',
    current_streak INT DEFAULT 0 COMMENT '当前连续打卡天数',
    max_streak INT DEFAULT 0 COMMENT '最大连续打卡天数',
    average_workout_duration INT DEFAULT 0 COMMENT '平均训练时长（分钟）',
    workout_frequency DECIMAL(3,1) DEFAULT 0.0 COMMENT '训练频率（次/周）',
    max_weight_lifted INT DEFAULT 0 COMMENT '最大举重重量（kg）',
    total_distance_covered DECIMAL(8,2) DEFAULT 0.0 COMMENT '总跑步距离（公里）',
    weekly_workouts INT DEFAULT 0 COMMENT '本周训练次数',
    weekly_minutes INT DEFAULT 0 COMMENT '本周训练时长（分钟）',
    weekly_calories INT DEFAULT 0 COMMENT '本周消耗卡路里',
    monthly_workouts INT DEFAULT 0 COMMENT '本月训练次数',
    monthly_minutes INT DEFAULT 0 COMMENT '本月训练时长（分钟）',
    monthly_calories INT DEFAULT 0 COMMENT '本月消耗卡路里',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_date (user_id, stat_date),
    INDEX idx_user_id (user_id),
    INDEX idx_stat_date (stat_date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户统计表';

-- 成就表
CREATE TABLE achievements (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '成就名称',
    description TEXT COMMENT '成就描述',
    type ENUM('first_workout', 'streak_7', 'streak_30', 'streak_100', 'total_workouts', 'calories_burned', 'weight_lifted', 'distance_covered', 'social', 'challenge', 'level_up') NOT NULL COMMENT '成就类型',
    category VARCHAR(50) NOT NULL COMMENT '成就分类',
    icon VARCHAR(100) COMMENT '成就图标',
    points_reward INT DEFAULT 0 COMMENT '积分奖励',
    badge_reward VARCHAR(100) COMMENT '徽章奖励',
    requirement_value INT NOT NULL COMMENT '达成条件数值',
    requirement_unit VARCHAR(20) COMMENT '达成条件单位',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    is_hidden BOOLEAN DEFAULT FALSE COMMENT '是否隐藏',
    sort_order INT DEFAULT 0 COMMENT '排序',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_type (type),
    INDEX idx_category (category),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='成就表';

-- 用户成就表
CREATE TABLE user_achievements (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    achievement_id VARCHAR(36) NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE COMMENT '是否已完成',
    progress_current INT DEFAULT 0 COMMENT '当前进度',
    progress_target INT DEFAULT 0 COMMENT '目标进度',
    completed_at TIMESTAMP NULL COMMENT '完成时间',
    is_reward_claimed BOOLEAN DEFAULT FALSE COMMENT '是否已领取奖励',
    reward_claimed_at TIMESTAMP NULL COMMENT '奖励领取时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_achievement (user_id, achievement_id),
    INDEX idx_user_id (user_id),
    INDEX idx_achievement_id (achievement_id),
    INDEX idx_is_completed (is_completed),
    INDEX idx_completed_at (completed_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户成就表';

-- 训练计划表
CREATE TABLE training_plans (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT '计划名称',
    description TEXT COMMENT '计划描述',
    type ENUM('ai', 'custom', 'template') NOT NULL COMMENT '计划类型',
    template_id VARCHAR(36) COMMENT '模板ID',
    duration INT DEFAULT 0 COMMENT '计划持续天数',
    frequency INT DEFAULT 0 COMMENT '每周训练次数',
    difficulty ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner' COMMENT '难度等级',
    goals JSON COMMENT '训练目标',
    exercises JSON COMMENT '训练动作',
    status ENUM('draft', 'active', 'completed', 'paused', 'cancelled') DEFAULT 'draft' COMMENT '计划状态',
    start_date DATE COMMENT '开始日期',
    end_date DATE COMMENT '结束日期',
    completed_workouts INT DEFAULT 0 COMMENT '已完成训练次数',
    total_workouts INT DEFAULT 0 COMMENT '总训练次数',
    calories_burned INT DEFAULT 0 COMMENT '消耗卡路里',
    is_public BOOLEAN DEFAULT FALSE COMMENT '是否公开',
    extra JSON COMMENT '额外数据',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_difficulty (difficulty),
    INDEX idx_is_public (is_public),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='训练计划表';

-- 营养计划表
CREATE TABLE nutrition_plans (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT '计划名称',
    description TEXT COMMENT '计划描述',
    target_calories INT DEFAULT 0 COMMENT '目标卡路里',
    target_protein INT DEFAULT 0 COMMENT '目标蛋白质（g）',
    target_carbs INT DEFAULT 0 COMMENT '目标碳水化合物（g）',
    target_fat INT DEFAULT 0 COMMENT '目标脂肪（g）',
    meal_plans JSON COMMENT '餐食计划',
    restrictions JSON COMMENT '饮食限制',
    preferences JSON COMMENT '饮食偏好',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否激活',
    extra JSON COMMENT '额外数据',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_id (user_id),
    INDEX idx_is_active (is_active),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='营养计划表';

-- 用户设置表
CREATE TABLE user_settings (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    setting_key VARCHAR(100) NOT NULL COMMENT '设置键',
    setting_value JSON COMMENT '设置值',
    category VARCHAR(50) COMMENT '设置分类',
    description TEXT COMMENT '设置描述',
    is_public BOOLEAN DEFAULT FALSE COMMENT '是否公开',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_key (user_id, setting_key),
    INDEX idx_user_id (user_id),
    INDEX idx_category (category),
    INDEX idx_is_public (is_public),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户设置表';

-- 活动历史表
CREATE TABLE activity_history (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    type ENUM('workout', 'checkin', 'achievement', 'post', 'comment', 'like', 'follow', 'level_up', 'points_earned') NOT NULL COMMENT '活动类型',
    title VARCHAR(200) NOT NULL COMMENT '活动标题',
    description TEXT COMMENT '活动描述',
    data JSON COMMENT '活动数据',
    related_user_id VARCHAR(36) COMMENT '相关用户ID',
    related_post_id VARCHAR(36) COMMENT '相关动态ID',
    related_achievement_id VARCHAR(36) COMMENT '相关成就ID',
    points_earned INT DEFAULT 0 COMMENT '获得积分',
    is_public BOOLEAN DEFAULT TRUE COMMENT '是否公开',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_created_at (created_at),
    INDEX idx_related_user_id (related_user_id),
    INDEX idx_related_post_id (related_post_id),
    INDEX idx_is_public (is_public),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (related_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (related_post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (related_achievement_id) REFERENCES achievements(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='活动历史表';

-- 关注关系表
CREATE TABLE user_follows (
    id VARCHAR(36) PRIMARY KEY,
    follower_id VARCHAR(36) NOT NULL COMMENT '关注者ID',
    following_id VARCHAR(36) NOT NULL COMMENT '被关注者ID',
    status ENUM('active', 'blocked') DEFAULT 'active' COMMENT '关注状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_follower_following (follower_id, following_id),
    INDEX idx_follower_id (follower_id),
    INDEX idx_following_id (following_id),
    INDEX idx_status (status),
    FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='关注关系表';

-- 用户等级表
CREATE TABLE user_levels (
    id VARCHAR(36) PRIMARY KEY,
    level INT NOT NULL COMMENT '等级',
    name VARCHAR(50) NOT NULL COMMENT '等级名称',
    description TEXT COMMENT '等级描述',
    required_experience INT NOT NULL COMMENT '所需经验值',
    required_points INT NOT NULL COMMENT '所需积分',
    benefits JSON COMMENT '等级权益',
    icon VARCHAR(100) COMMENT '等级图标',
    color VARCHAR(20) COMMENT '等级颜色',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    sort_order INT DEFAULT 0 COMMENT '排序',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_level (level),
    INDEX idx_required_experience (required_experience),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户等级表';

-- 积分记录表
CREATE TABLE points_history (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    type ENUM('earn', 'spend', 'refund', 'expire') NOT NULL COMMENT '积分类型',
    amount INT NOT NULL COMMENT '积分数量',
    reason VARCHAR(200) NOT NULL COMMENT '积分原因',
    description TEXT COMMENT '积分描述',
    related_id VARCHAR(36) COMMENT '相关记录ID',
    related_type VARCHAR(50) COMMENT '相关记录类型',
    balance_after INT NOT NULL COMMENT '操作后余额',
    expires_at TIMESTAMP NULL COMMENT '过期时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_created_at (created_at),
    INDEX idx_expires_at (expires_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='积分记录表';

-- 用户徽章表
CREATE TABLE user_badges (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    badge_name VARCHAR(100) NOT NULL COMMENT '徽章名称',
    badge_icon VARCHAR(100) COMMENT '徽章图标',
    badge_color VARCHAR(20) COMMENT '徽章颜色',
    description TEXT COMMENT '徽章描述',
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '获得时间',
    is_displayed BOOLEAN DEFAULT TRUE COMMENT '是否显示',
    
    INDEX idx_user_id (user_id),
    INDEX idx_badge_name (badge_name),
    INDEX idx_earned_at (earned_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户徽章表';

-- 用户反馈表
CREATE TABLE user_feedback (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    type ENUM('bug', 'feature', 'suggestion', 'complaint', 'other') NOT NULL COMMENT '反馈类型',
    title VARCHAR(200) NOT NULL COMMENT '反馈标题',
    content TEXT NOT NULL COMMENT '反馈内容',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium' COMMENT '优先级',
    status ENUM('pending', 'processing', 'resolved', 'closed') DEFAULT 'pending' COMMENT '状态',
    admin_reply TEXT COMMENT '管理员回复',
    admin_replied_at TIMESTAMP NULL COMMENT '管理员回复时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户反馈表';

-- 插入默认成就数据
INSERT INTO achievements (id, name, description, type, category, icon, points_reward, badge_reward, requirement_value, requirement_unit, is_active, sort_order) VALUES
('ach_001', '初次训练', '完成第一次训练', 'first_workout', 'beginner', 'dumbbell', 10, '新手', 1, '次', TRUE, 1),
('ach_002', '坚持一周', '连续训练7天', 'streak_7', 'consistency', 'calendar-check', 50, '坚持者', 7, '天', TRUE, 2),
('ach_003', '坚持一月', '连续训练30天', 'streak_30', 'consistency', 'calendar-check', 200, '坚持者', 30, '天', TRUE, 3),
('ach_004', '坚持百日', '连续训练100天', 'streak_100', 'consistency', 'calendar-check', 500, '坚持者', 100, '天', TRUE, 4),
('ach_005', '训练达人', '完成100次训练', 'total_workouts', 'achievement', 'trophy', 300, '训练达人', 100, '次', TRUE, 5),
('ach_006', '燃烧卡路里', '累计消耗10000卡路里', 'calories_burned', 'achievement', 'fire', 250, '燃烧者', 10000, '卡', TRUE, 6),
('ach_007', '力量提升', '举起100kg重量', 'weight_lifted', 'strength', 'weight-lifter', 400, '力量者', 100, 'kg', TRUE, 7),
('ach_008', '跑步健将', '累计跑步100公里', 'distance_covered', 'cardio', 'run', 350, '跑步者', 100, '公里', TRUE, 8),
('ach_009', '社交达人', '获得100个赞', 'social', 'social', 'heart', 150, '社交达人', 100, '个', TRUE, 9),
('ach_010', '挑战者', '完成10个挑战', 'challenge', 'challenge', 'flag', 200, '挑战者', 10, '个', TRUE, 10);

-- 插入默认等级数据
INSERT INTO user_levels (id, level, name, description, required_experience, required_points, benefits, icon, color, is_active, sort_order) VALUES
('level_001', 1, '新手', '刚开始健身的新手', 0, 0, '["基础功能"]', 'star', '#4CAF50', TRUE, 1),
('level_002', 2, '入门', '健身入门者', 100, 100, '["基础功能", "查看统计数据"]', 'star', '#2196F3', TRUE, 2),
('level_003', 3, '进阶', '健身进阶者', 500, 500, '["基础功能", "查看统计数据", "创建训练计划"]', 'star', '#FF9800', TRUE, 3),
('level_004', 4, '高级', '健身高级者', 1000, 1000, '["基础功能", "查看统计数据", "创建训练计划", "AI训练计划"]', 'star', '#9C27B0', TRUE, 4),
('level_005', 5, '专家', '健身专家', 2000, 2000, '["基础功能", "查看统计数据", "创建训练计划", "AI训练计划", "高级分析"]', 'star', '#F44336', TRUE, 5),
('level_006', 6, '大师', '健身大师', 5000, 5000, '["基础功能", "查看统计数据", "创建训练计划", "AI训练计划", "高级分析", "专属客服"]', 'star', '#FFD700', TRUE, 6);

-- 插入默认用户设置数据
INSERT INTO user_settings (id, user_id, setting_key, setting_value, category, description, is_public) 
SELECT 
    CONCAT('setting_', u.id, '_', s.key),
    u.id,
    s.key,
    s.value,
    s.category,
    s.description,
    s.is_public
FROM users u
CROSS JOIN (
    SELECT 'notification_workout' as key, 'true' as value, 'notification' as category, '训练通知' as description, FALSE as is_public
    UNION ALL SELECT 'notification_achievement', 'true', 'notification', '成就通知', FALSE
    UNION ALL SELECT 'notification_social', 'true', 'notification', '社交通知', FALSE
    UNION ALL SELECT 'privacy_profile', 'true', 'privacy', '公开个人资料', TRUE
    UNION ALL SELECT 'privacy_workout', 'false', 'privacy', '公开训练记录', TRUE
    UNION ALL SELECT 'privacy_stats', 'false', 'privacy', '公开统计数据', TRUE
    UNION ALL SELECT 'display_units', 'metric', 'display', '显示单位', FALSE
    UNION ALL SELECT 'theme_mode', 'system', 'display', '主题模式', FALSE
    UNION ALL SELECT 'language', 'zh-CN', 'display', '语言设置', FALSE
) s
WHERE NOT EXISTS (
    SELECT 1 FROM user_settings us WHERE us.user_id = u.id AND us.setting_key = s.key
);
