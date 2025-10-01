-- FitTracker 训练模块数据库表设计
-- 包含训练计划、动作、打卡记录、成就系统等表

-- 训练计划表
CREATE TABLE training_plans (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT '训练计划名称',
    description TEXT COMMENT '计划描述',
    date DATE NOT NULL COMMENT '训练日期',
    duration INT DEFAULT 0 COMMENT '预计训练时长（分钟）',
    calories INT DEFAULT 0 COMMENT '预计消耗卡路里',
    status ENUM('pending', 'in_progress', 'completed', 'skipped') DEFAULT 'pending' COMMENT '训练状态',
    ai_generated BOOLEAN DEFAULT FALSE COMMENT '是否AI生成',
    ai_generated_reason TEXT COMMENT 'AI生成理由',
    actual_duration INT DEFAULT 0 COMMENT '实际训练时长',
    actual_calories INT DEFAULT 0 COMMENT '实际消耗卡路里',
    notes TEXT COMMENT '训练备注',
    rating INT DEFAULT 0 COMMENT '训练评分 1-5',
    points_earned INT DEFAULT 0 COMMENT '获得积分',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_date (user_id, date),
    INDEX idx_status (status),
    INDEX idx_ai_generated (ai_generated),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='训练计划表';

-- 训练动作表
CREATE TABLE training_exercises (
    id VARCHAR(36) PRIMARY KEY,
    plan_id VARCHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT '动作名称',
    description TEXT COMMENT '动作描述',
    category VARCHAR(50) NOT NULL COMMENT '动作分类：胸肌、背肌、腿部等',
    difficulty ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner' COMMENT '难度等级',
    muscle_groups JSON COMMENT '目标肌肉群',
    equipment JSON COMMENT '所需器械',
    video_url VARCHAR(500) COMMENT '动作视频URL',
    image_url VARCHAR(500) COMMENT '动作图片URL',
    instructions TEXT COMMENT '动作说明',
    order_index INT DEFAULT 0 COMMENT '动作顺序',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_plan_id (plan_id),
    INDEX idx_category (category),
    INDEX idx_difficulty (difficulty),
    FOREIGN KEY (plan_id) REFERENCES training_plans(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='训练动作表';

-- 动作组数表
CREATE TABLE exercise_sets (
    id VARCHAR(36) PRIMARY KEY,
    exercise_id VARCHAR(36) NOT NULL,
    set_number INT NOT NULL COMMENT '组数编号',
    reps INT NOT NULL COMMENT '次数',
    weight DECIMAL(5,2) DEFAULT 0 COMMENT '重量（kg）',
    duration INT DEFAULT 0 COMMENT '持续时间（秒）',
    distance DECIMAL(5,2) DEFAULT 0 COMMENT '距离（公里）',
    rest_time INT DEFAULT 0 COMMENT '休息时间（秒）',
    completed BOOLEAN DEFAULT FALSE COMMENT '是否完成',
    completed_at TIMESTAMP NULL COMMENT '完成时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_exercise_id (exercise_id),
    INDEX idx_completed (completed),
    FOREIGN KEY (exercise_id) REFERENCES training_exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动作组数表';

-- 打卡记录表
CREATE TABLE check_ins (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    date DATE NOT NULL COMMENT '打卡日期',
    type ENUM('training', 'daily', 'nutrition', 'other') DEFAULT 'daily' COMMENT '打卡类型',
    description TEXT COMMENT '打卡描述',
    images JSON COMMENT '打卡图片URL列表',
    location VARCHAR(200) COMMENT '打卡地点',
    mood ENUM('excellent', 'good', 'normal', 'bad', 'terrible') COMMENT '心情状态',
    weather VARCHAR(50) COMMENT '天气情况',
    points_earned INT DEFAULT 10 COMMENT '获得积分',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_date (user_id, date),
    INDEX idx_user_date_range (user_id, date),
    INDEX idx_type (type),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='打卡记录表';

-- 成就系统表
CREATE TABLE achievements (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '成就名称',
    description TEXT COMMENT '成就描述',
    icon VARCHAR(100) COMMENT '成就图标',
    category ENUM('training', 'checkin', 'social', 'special') DEFAULT 'training' COMMENT '成就分类',
    condition_type ENUM('count', 'streak', 'total', 'custom') NOT NULL COMMENT '达成条件类型',
    condition_value INT NOT NULL COMMENT '达成条件数值',
    condition_data JSON COMMENT '达成条件详细数据',
    reward_points INT DEFAULT 0 COMMENT '奖励积分',
    reward_badge VARCHAR(100) COMMENT '奖励徽章',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_condition_type (condition_type),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='成就系统表';

-- 用户成就记录表
CREATE TABLE user_achievements (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    achievement_id VARCHAR(36) NOT NULL,
    progress INT DEFAULT 0 COMMENT '当前进度',
    max_progress INT NOT NULL COMMENT '最大进度',
    completed BOOLEAN DEFAULT FALSE COMMENT '是否完成',
    completed_at TIMESTAMP NULL COMMENT '完成时间',
    reward_claimed BOOLEAN DEFAULT FALSE COMMENT '奖励是否已领取',
    reward_claimed_at TIMESTAMP NULL COMMENT '奖励领取时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_achievement (user_id, achievement_id),
    INDEX idx_user_completed (user_id, completed),
    INDEX idx_achievement_id (achievement_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户成就记录表';

-- 用户积分记录表
CREATE TABLE user_points (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    points INT NOT NULL COMMENT '积分变化',
    type ENUM('earn', 'spend', 'bonus', 'penalty') NOT NULL COMMENT '积分类型',
    source VARCHAR(100) NOT NULL COMMENT '积分来源',
    source_id VARCHAR(36) COMMENT '来源ID',
    description TEXT COMMENT '积分描述',
    balance_after INT NOT NULL COMMENT '变化后余额',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_source (source),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户积分记录表';

-- 训练统计表（用于快速查询）
CREATE TABLE training_stats (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    stat_date DATE NOT NULL COMMENT '统计日期',
    total_workouts INT DEFAULT 0 COMMENT '总训练次数',
    total_duration INT DEFAULT 0 COMMENT '总训练时长（分钟）',
    total_calories INT DEFAULT 0 COMMENT '总消耗卡路里',
    total_points INT DEFAULT 0 COMMENT '总获得积分',
    checkin_streak INT DEFAULT 0 COMMENT '连续打卡天数',
    longest_streak INT DEFAULT 0 COMMENT '最长连续打卡天数',
    level INT DEFAULT 1 COMMENT '用户等级',
    experience INT DEFAULT 0 COMMENT '经验值',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_date (user_id, stat_date),
    INDEX idx_user_id (user_id),
    INDEX idx_stat_date (stat_date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='训练统计表';

-- 动作模板库表（用于AI推荐和用户选择）
CREATE TABLE exercise_templates (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '动作名称',
    description TEXT COMMENT '动作描述',
    category VARCHAR(50) NOT NULL COMMENT '动作分类',
    difficulty ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner' COMMENT '难度等级',
    muscle_groups JSON COMMENT '目标肌肉群',
    equipment JSON COMMENT '所需器械',
    video_url VARCHAR(500) COMMENT '动作视频URL',
    image_url VARCHAR(500) COMMENT '动作图片URL',
    instructions TEXT COMMENT '动作说明',
    default_sets JSON COMMENT '默认组数设置',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    usage_count INT DEFAULT 0 COMMENT '使用次数',
    rating DECIMAL(3,2) DEFAULT 0 COMMENT '评分',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_difficulty (difficulty),
    INDEX idx_is_active (is_active),
    INDEX idx_usage_count (usage_count),
    INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动作模板库表';

-- 用户训练偏好表
CREATE TABLE user_training_preferences (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    preferred_duration INT DEFAULT 45 COMMENT '偏好训练时长',
    preferred_difficulty ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'intermediate' COMMENT '偏好难度',
    preferred_muscle_groups JSON COMMENT '偏好肌肉群',
    preferred_equipment JSON COMMENT '偏好器械',
    include_cardio BOOLEAN DEFAULT TRUE COMMENT '是否包含有氧',
    rest_time_preference INT DEFAULT 60 COMMENT '偏好休息时间',
    training_frequency INT DEFAULT 3 COMMENT '训练频率（每周次数）',
    goals JSON COMMENT '训练目标',
    limitations JSON COMMENT '身体限制',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户训练偏好表';

-- 训练提醒设置表
CREATE TABLE training_reminders (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    reminder_type ENUM('daily', 'weekly', 'custom') NOT NULL COMMENT '提醒类型',
    reminder_time TIME NOT NULL COMMENT '提醒时间',
    days_of_week JSON COMMENT '提醒星期（1-7）',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    message TEXT COMMENT '提醒消息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_is_active (is_active),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='训练提醒设置表';

-- 插入默认成就数据
INSERT INTO achievements (id, name, description, icon, category, condition_type, condition_value, reward_points, reward_badge) VALUES
('ach_001', '训练新手', '完成第一次训练', 'trophy', 'training', 'count', 1, 100, 'newbie'),
('ach_002', '坚持一周', '连续训练7天', 'fire', 'training', 'streak', 7, 500, 'week_warrior'),
('ach_003', '力量达人', '完成100次力量训练', 'dumbbell', 'training', 'count', 100, 1000, 'power_master'),
('ach_004', '打卡达人', '连续打卡30天', 'calendar', 'checkin', 'streak', 30, 2000, 'checkin_master'),
('ach_005', '卡路里燃烧者', '累计消耗10000卡路里', 'fire', 'training', 'total', 10000, 1500, 'calorie_burner'),
('ach_006', '健身新手', '完成10次训练', 'star', 'training', 'count', 10, 300, 'fitness_starter'),
('ach_007', '月度冠军', '一个月内完成20次训练', 'medal', 'training', 'count', 20, 800, 'monthly_champion'),
('ach_008', '早起鸟', '连续7天早上训练', 'sunrise', 'training', 'streak', 7, 400, 'early_bird');

-- 插入默认动作模板数据
INSERT INTO exercise_templates (id, name, description, category, difficulty, muscle_groups, equipment, instructions, default_sets) VALUES
('ex_001', '俯卧撑', '经典的自重胸肌训练动作', '胸肌', 'beginner', '["胸大肌", "肱三头肌", "核心"]', '["自重"]', '保持身体挺直，双手与肩同宽，下降至胸部接近地面，然后推起', '[{"reps": 10, "weight": 0, "rest_time": 60}, {"reps": 10, "weight": 0, "rest_time": 60}, {"reps": 8, "weight": 0, "rest_time": 90}]'),
('ex_002', '深蹲', '全身力量训练的基础动作', '腿部', 'beginner', '["股四头肌", "臀大肌", "核心"]', '["自重"]', '双脚与肩同宽，下蹲至大腿与地面平行，然后站起', '[{"reps": 15, "weight": 0, "rest_time": 60}, {"reps": 12, "weight": 0, "rest_time": 60}, {"reps": 10, "weight": 0, "rest_time": 90}]'),
('ex_003', '平板支撑', '核心力量训练动作', '核心', 'beginner', '["核心", "肩部", "背部"]', '["自重"]', '保持身体挺直，前臂支撑，保持稳定', '[{"reps": 1, "weight": 0, "duration": 30, "rest_time": 60}, {"reps": 1, "weight": 0, "duration": 30, "rest_time": 60}, {"reps": 1, "weight": 0, "duration": 30, "rest_time": 90}]'),
('ex_004', '引体向上', '背部力量训练动作', '背肌', 'intermediate', '["背阔肌", "肱二头肌", "后三角肌"]', '["单杠"]', '双手正握单杠，身体悬垂，向上拉至下巴过杠', '[{"reps": 8, "weight": 0, "rest_time": 90}, {"reps": 6, "weight": 0, "rest_time": 90}, {"reps": 5, "weight": 0, "rest_time": 120}]'),
('ex_005', '平板卧推', '经典胸肌力量训练', '胸肌', 'intermediate', '["胸大肌", "三角肌前束", "肱三头肌"]', '["杠铃", "卧推凳"]', '平躺在卧推凳上，双手握杠铃，下降至胸部，然后推起', '[{"reps": 12, "weight": 60, "rest_time": 60}, {"reps": 10, "weight": 70, "rest_time": 60}, {"reps": 8, "weight": 80, "rest_time": 90}]');
