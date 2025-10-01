-- FitTracker PostgreSQL 数据库初始化脚本

-- 创建扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 用户表
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nickname VARCHAR(50),
    bio TEXT,
    avatar VARCHAR(500),
    fitness_tags TEXT,
    fitness_goal VARCHAR(100),
    location VARCHAR(100),
    is_verified BOOLEAN DEFAULT FALSE,
    followers_count INT DEFAULT 0,
    following_count INT DEFAULT 0,
    total_workouts INT DEFAULT 0,
    total_checkins INT DEFAULT 0,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 训练计划表
CREATE TABLE training_plans (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    user_id VARCHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    duration INT DEFAULT 0,
    calories INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    ai_generated BOOLEAN DEFAULT FALSE,
    ai_generated_reason TEXT,
    actual_duration INT DEFAULT 0,
    actual_calories INT DEFAULT 0,
    notes TEXT,
    rating INT DEFAULT 0,
    points_earned INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 训练动作表
CREATE TABLE training_exercises (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    plan_id VARCHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    difficulty VARCHAR(20) DEFAULT 'beginner',
    muscle_groups JSONB,
    equipment JSONB,
    video_url VARCHAR(500),
    image_url VARCHAR(500),
    instructions TEXT,
    order_index INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (plan_id) REFERENCES training_plans(id) ON DELETE CASCADE
);

-- 动作组数表
CREATE TABLE exercise_sets (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    exercise_id VARCHAR(36) NOT NULL,
    set_number INT NOT NULL,
    reps INT NOT NULL,
    weight DECIMAL(5,2) DEFAULT 0,
    duration INT DEFAULT 0,
    distance DECIMAL(5,2) DEFAULT 0,
    rest_time INT DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (exercise_id) REFERENCES training_exercises(id) ON DELETE CASCADE
);

-- 打卡记录表
CREATE TABLE check_ins (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    user_id VARCHAR(36) NOT NULL,
    date DATE NOT NULL,
    type VARCHAR(20) DEFAULT 'daily',
    description TEXT,
    images JSONB,
    location VARCHAR(200),
    mood VARCHAR(20),
    weather VARCHAR(50),
    points_earned INT DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE (user_id, date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 成就系统表
CREATE TABLE achievements (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    category VARCHAR(20) DEFAULT 'training',
    condition_type VARCHAR(20) NOT NULL,
    condition_value INT NOT NULL,
    condition_data JSONB,
    reward_points INT DEFAULT 0,
    reward_badge VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 用户成就记录表
CREATE TABLE user_achievements (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    user_id VARCHAR(36) NOT NULL,
    achievement_id VARCHAR(36) NOT NULL,
    progress INT DEFAULT 0,
    max_progress INT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP NULL,
    reward_claimed BOOLEAN DEFAULT FALSE,
    reward_claimed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE (user_id, achievement_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE
);

-- 动作模板库表
CREATE TABLE exercise_templates (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    difficulty VARCHAR(20) DEFAULT 'beginner',
    muscle_groups JSONB,
    equipment JSONB,
    video_url VARCHAR(500),
    image_url VARCHAR(500),
    instructions TEXT,
    default_sets JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    usage_count INT DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入默认成就数据
INSERT INTO achievements (id, name, description, icon, category, condition_type, condition_value, reward_points, reward_badge) VALUES
('ach_001', '训练新手', '完成第一次训练', 'trophy', 'training', 'count', 1, 100, 'newbie'),
('ach_002', '坚持一周', '连续训练7天', 'fire', 'training', 'streak', 7, 500, 'week_warrior'),
('ach_003', '力量达人', '完成100次力量训练', 'dumbbell', 'training', 'count', 100, 1000, 'power_master'),
('ach_004', '打卡达人', '连续打卡30天', 'calendar', 'checkin', 'streak', 30, 2000, 'checkin_master'),
('ach_005', '卡路里燃烧者', '累计消耗10000卡路里', 'fire', 'training', 'total', 10000, 1500, 'calorie_burner');

-- 插入默认动作模板数据
INSERT INTO exercise_templates (id, name, description, category, difficulty, muscle_groups, equipment, instructions, default_sets) VALUES
('ex_001', '俯卧撑', '经典的自重胸肌训练动作', '胸肌', 'beginner', '["胸大肌", "肱三头肌", "核心"]', '["自重"]', '保持身体挺直，双手与肩同宽，下降至胸部接近地面，然后推起', '[{"reps": 10, "weight": 0, "rest_time": 60}, {"reps": 10, "weight": 0, "rest_time": 60}, {"reps": 8, "weight": 0, "rest_time": 90}]'),
('ex_002', '深蹲', '全身力量训练的基础动作', '腿部', 'beginner', '["股四头肌", "臀大肌", "核心"]', '["自重"]', '双脚与肩同宽，下蹲至大腿与地面平行，然后站起', '[{"reps": 15, "weight": 0, "rest_time": 60}, {"reps": 12, "weight": 0, "rest_time": 60}, {"reps": 10, "weight": 0, "rest_time": 90}]'),
('ex_003', '平板支撑', '核心力量训练动作', '核心', 'beginner', '["核心", "肩部", "背部"]', '["自重"]', '保持身体挺直，前臂支撑，保持稳定', '[{"reps": 1, "weight": 0, "duration": 30, "rest_time": 60}, {"reps": 1, "weight": 0, "duration": 30, "rest_time": 60}, {"reps": 1, "weight": 0, "duration": 30, "rest_time": 90}]');

-- 创建索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_training_plans_user_date ON training_plans(user_id, date);
CREATE INDEX idx_training_plans_status ON training_plans(status);
CREATE INDEX idx_training_exercises_plan_id ON training_exercises(plan_id);
CREATE INDEX idx_exercise_sets_exercise_id ON exercise_sets(exercise_id);
CREATE INDEX idx_check_ins_user_date ON check_ins(user_id, date);
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_exercise_templates_category ON exercise_templates(category);
