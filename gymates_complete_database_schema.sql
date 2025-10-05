-- =====================================================
-- Gymates 完整数据库模型设计
-- PostgreSQL 15+ 兼容
-- 创建时间: 2025-01-03
-- 描述: 包含用户、社区、训练、健身房、搭子、消息、统计系统
-- =====================================================

-- 启用UUID扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. 用户系统 (User System)
-- =====================================================

-- 用户表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    bio TEXT,
    fitness_goal VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- 身体基本信息
    height DECIMAL(5,2), -- 身高(cm)
    weight DECIMAL(5,2), -- 体重(kg)
    age INTEGER,
    gender VARCHAR(10), -- male, female, other
    birth_date DATE,
    
    -- 健身偏好
    workout_frequency INTEGER DEFAULT 0, -- 每周训练次数
    preferred_workout_time VARCHAR(20), -- morning, afternoon, evening, night
    experience_level VARCHAR(20) DEFAULT 'beginner', -- beginner, intermediate, advanced
    preferred_gym_types JSONB DEFAULT '[]', -- 偏好健身房类型
    
    -- 隐私设置
    profile_visibility VARCHAR(20) DEFAULT 'public', -- public, friends, private
    location_visibility BOOLEAN DEFAULT TRUE,
    workout_data_visibility BOOLEAN DEFAULT TRUE
);

-- 用户关注关系表
CREATE TABLE user_follows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(follower_id, following_id),
    CHECK(follower_id != following_id)
);

-- 用户设置表
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 通知设置
    push_notifications BOOLEAN DEFAULT TRUE,
    email_notifications BOOLEAN DEFAULT TRUE,
    sms_notifications BOOLEAN DEFAULT FALSE,
    comment_notifications BOOLEAN DEFAULT TRUE,
    like_notifications BOOLEAN DEFAULT TRUE,
    follow_notifications BOOLEAN DEFAULT TRUE,
    buddy_request_notifications BOOLEAN DEFAULT TRUE,
    
    -- 隐私设置
    show_online_status BOOLEAN DEFAULT TRUE,
    allow_friend_requests BOOLEAN DEFAULT TRUE,
    allow_buddy_requests BOOLEAN DEFAULT TRUE,
    
    -- 训练设置
    default_workout_duration INTEGER DEFAULT 60, -- 默认训练时长(分钟)
    auto_save_workouts BOOLEAN DEFAULT TRUE,
    track_calories BOOLEAN DEFAULT TRUE,
    
    -- 单位设置
    weight_unit VARCHAR(10) DEFAULT 'kg', -- kg, lb
    height_unit VARCHAR(10) DEFAULT 'cm', -- cm, ft
    distance_unit VARCHAR(10) DEFAULT 'km', -- km, mile
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- =====================================================
-- 2. 社区系统 (Community System)
-- =====================================================

-- 动态表
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    images JSONB DEFAULT '[]',
    video_url VARCHAR(500),
    post_type VARCHAR(50) DEFAULT 'dynamic', -- dynamic, mood, nutrition, training, achievement
    mood_type VARCHAR(50), -- happy, sad, excited, tired, motivated
    location VARCHAR(200),
    tags JSONB DEFAULT '[]',
    
    -- 训练相关数据
    training_data JSONB, -- 训练记录数据
    nutrition_data JSONB, -- 营养数据
    
    -- 统计信息
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    
    -- 状态
    is_public BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    is_pinned BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- 动态点赞表
CREATE TABLE post_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, post_id)
);

-- 动态评论表
CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES post_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- 评论点赞表
CREATE TABLE comment_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    comment_id UUID NOT NULL REFERENCES post_comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, comment_id)
);

-- 动态分享表
CREATE TABLE post_shares (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    share_type VARCHAR(20) DEFAULT 'repost', -- repost, link, story
    share_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. 训练系统 (Training System)
-- =====================================================

-- 训练计划表
CREATE TABLE training_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    plan_type VARCHAR(50) NOT NULL, -- strength, cardio, flexibility, mixed
    difficulty_level VARCHAR(20) DEFAULT 'beginner', -- beginner, intermediate, advanced
    duration_weeks INTEGER DEFAULT 4,
    frequency_per_week INTEGER DEFAULT 3,
    is_public BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 训练计划详情表
CREATE TABLE training_plan_details (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES training_plans(id) ON DELETE CASCADE,
    week_number INTEGER NOT NULL,
    day_number INTEGER NOT NULL, -- 1-7 (周一-周日)
    workout_name VARCHAR(255) NOT NULL,
    exercises JSONB NOT NULL, -- 包含动作、组数、次数、重量等
    duration_minutes INTEGER,
    rest_days JSONB DEFAULT '[]', -- 休息日
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 训练记录表
CREATE TABLE workout_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES training_plans(id) ON DELETE SET NULL,
    session_name VARCHAR(255) NOT NULL,
    workout_type VARCHAR(50) NOT NULL, -- strength, cardio, yoga, etc.
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    calories_burned INTEGER,
    exercises_completed JSONB, -- 完成的动作记录
    notes TEXT,
    mood_before VARCHAR(20), -- 训练前心情
    mood_after VARCHAR(20), -- 训练后心情
    difficulty_rating INTEGER CHECK (difficulty_rating >= 1 AND difficulty_rating <= 10),
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 营养记录表
CREATE TABLE nutrition_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    meal_type VARCHAR(50) NOT NULL, -- breakfast, lunch, dinner, snack
    food_name VARCHAR(255) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(50) NOT NULL, -- g, ml, cup, piece
    calories DECIMAL(10,2),
    protein DECIMAL(10,2),
    carbs DECIMAL(10,2),
    fat DECIMAL(10,2),
    fiber DECIMAL(10,2),
    sugar DECIMAL(10,2),
    sodium DECIMAL(10,2),
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 饮水记录表
CREATE TABLE water_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount_ml INTEGER NOT NULL,
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 4. 健身房系统 (Gym System)
-- =====================================================

-- 健身房表
CREATE TABLE gyms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    description TEXT,
    phone VARCHAR(50),
    website VARCHAR(255),
    email VARCHAR(100),
    
    -- 营业时间 (JSON格式)
    opening_hours JSONB NOT NULL, -- {"monday": "06:00-22:00", "tuesday": "06:00-22:00", ...}
    
    -- 设施信息 (JSON格式)
    facilities JSONB DEFAULT '{}', -- {"pool": true, "sauna": true, "parking": true, ...}
    
    -- 图片和媒体
    images JSONB DEFAULT '[]',
    logo_url VARCHAR(500),
    
    -- 价格信息
    membership_fee DECIMAL(10,2),
    daily_fee DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'CNY',
    
    -- 状态信息
    owner_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    verification_status VARCHAR(20) DEFAULT 'pending', -- pending, verified, rejected
    
    -- 统计信息
    member_count INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 健身房设施表
CREATE TABLE gym_facilities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    facility_name VARCHAR(100) NOT NULL,
    facility_type VARCHAR(50) NOT NULL, -- equipment, amenity, service
    description TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    capacity INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 健身房营业时间表
CREATE TABLE gym_opening_hours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=Sunday, 1=Monday, ...
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    is_closed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(gym_id, day_of_week)
);

-- 健身房评价表
CREATE TABLE gym_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    content TEXT,
    images JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(gym_id, user_id)
);

-- =====================================================
-- 5. 搭子系统 (Buddy System)
-- =====================================================

-- 健身房折扣表 (先创建，因为被其他表引用)
CREATE TABLE gym_discounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    discount_name VARCHAR(255) NOT NULL,
    min_group_size INTEGER NOT NULL CHECK (min_group_size >= 2),
    max_group_size INTEGER CHECK (max_group_size >= min_group_size),
    discount_percent INTEGER CHECK (discount_percent > 0 AND discount_percent <= 100),
    discount_type VARCHAR(20) DEFAULT 'percentage', -- percentage, fixed_amount
    discount_amount DECIMAL(10,2),
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_until TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT,
    terms_conditions TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 搭子群组表
CREATE TABLE gym_buddy_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    leader_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    group_name VARCHAR(100) NOT NULL,
    description TEXT,
    goal VARCHAR(100), -- 增肌, 减脂, 塑形, 力量, 有氧
    scheduled_time TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER DEFAULT 60,
    max_members INTEGER DEFAULT 10,
    current_members INTEGER DEFAULT 1,
    experience_level VARCHAR(20) DEFAULT 'beginner',
    status VARCHAR(20) DEFAULT 'active', -- active, completed, cancelled, full
    discount_applied_id UUID REFERENCES gym_discounts(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 搭子成员表
CREATE TABLE gym_buddy_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES gym_buddy_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member', -- leader, member
    status VARCHAR(20) DEFAULT 'active', -- active, left, removed
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    left_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(group_id, user_id)
);


-- 搭子申请表
CREATE TABLE gym_buddy_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES gym_buddy_groups(id) ON DELETE CASCADE,
    requester_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending', -- pending, accepted, rejected, cancelled
    request_message TEXT,
    response_message TEXT,
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    responded_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(group_id, requester_user_id)
);

-- =====================================================
-- 6. 消息系统 (Message System)
-- =====================================================

-- 会话表
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_type VARCHAR(20) NOT NULL, -- direct, group, buddy_group
    title VARCHAR(255), -- 群聊名称
    description TEXT, -- 群聊描述
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_message_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 会话成员表
CREATE TABLE conversation_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member', -- admin, member
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    left_at TIMESTAMP WITH TIME ZONE,
    last_read_at TIMESTAMP WITH TIME ZONE,
    is_muted BOOLEAN DEFAULT FALSE,
    UNIQUE(conversation_id, user_id)
);

-- 消息表
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message_type VARCHAR(20) DEFAULT 'text', -- text, image, video, file, system
    content TEXT,
    attachment_url VARCHAR(500),
    attachment_type VARCHAR(50),
    attachment_size BIGINT,
    reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL,
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 消息已读状态表
CREATE TABLE message_read_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(message_id, user_id)
);

-- =====================================================
-- 7. 统计系统 (Statistics System)
-- =====================================================

-- 身体指标表
CREATE TABLE body_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weight DECIMAL(5,2),
    height DECIMAL(5,2),
    bmi DECIMAL(4,2),
    body_fat_percentage DECIMAL(5,2),
    muscle_mass DECIMAL(5,2),
    bone_density DECIMAL(5,2),
    waist_circumference DECIMAL(5,2),
    chest_circumference DECIMAL(5,2),
    arm_circumference DECIMAL(5,2),
    thigh_circumference DECIMAL(5,2),
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 训练统计表
CREATE TABLE training_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    total_workouts INTEGER DEFAULT 0,
    total_duration_minutes INTEGER DEFAULT 0,
    total_calories_burned INTEGER DEFAULT 0,
    workout_types JSONB DEFAULT '{}', -- {"strength": 2, "cardio": 1}
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- 营养统计表
CREATE TABLE nutrition_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    total_calories DECIMAL(10,2) DEFAULT 0,
    total_protein DECIMAL(10,2) DEFAULT 0,
    total_carbs DECIMAL(10,2) DEFAULT 0,
    total_fat DECIMAL(10,2) DEFAULT 0,
    total_fiber DECIMAL(10,2) DEFAULT 0,
    total_sugar DECIMAL(10,2) DEFAULT 0,
    total_sodium DECIMAL(10,2) DEFAULT 0,
    water_intake_ml INTEGER DEFAULT 0,
    meal_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- 成就表
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_type VARCHAR(50) NOT NULL, -- workout_streak, weight_loss, distance, etc.
    achievement_name VARCHAR(255) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI对话记录表
CREATE TABLE ai_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    conversation_type VARCHAR(50) NOT NULL, -- training, nutrition, health, general
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    context_data JSONB, -- 对话上下文
    session_id UUID, -- 会话ID
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 8. 索引创建
-- =====================================================

-- 用户系统索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_user_follows_follower_id ON user_follows(follower_id);
CREATE INDEX idx_user_follows_following_id ON user_follows(following_id);
CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);

-- 社区系统索引
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at);
CREATE INDEX idx_posts_post_type ON posts(post_type);
CREATE INDEX idx_posts_is_public ON posts(is_public);
CREATE INDEX idx_post_likes_user_id ON post_likes(user_id);
CREATE INDEX idx_post_likes_post_id ON post_likes(post_id);
CREATE INDEX idx_post_comments_user_id ON post_comments(user_id);
CREATE INDEX idx_post_comments_post_id ON post_comments(post_id);
CREATE INDEX idx_post_comments_parent_id ON post_comments(parent_id);

-- 训练系统索引
CREATE INDEX idx_training_plans_user_id ON training_plans(user_id);
CREATE INDEX idx_training_plans_is_active ON training_plans(is_active);
CREATE INDEX idx_training_plan_details_plan_id ON training_plan_details(plan_id);
CREATE INDEX idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX idx_workout_sessions_start_time ON workout_sessions(start_time);
CREATE INDEX idx_nutrition_logs_user_id ON nutrition_logs(user_id);
CREATE INDEX idx_nutrition_logs_logged_at ON nutrition_logs(logged_at);
CREATE INDEX idx_water_logs_user_id ON water_logs(user_id);
CREATE INDEX idx_water_logs_logged_at ON water_logs(logged_at);

-- 健身房系统索引
CREATE INDEX idx_gyms_name ON gyms(name);
CREATE INDEX idx_gyms_location ON gyms(latitude, longitude);
CREATE INDEX idx_gyms_is_active ON gyms(is_active);
CREATE INDEX idx_gyms_is_verified ON gyms(is_verified);
CREATE INDEX idx_gym_facilities_gym_id ON gym_facilities(gym_id);
CREATE INDEX idx_gym_opening_hours_gym_id ON gym_opening_hours(gym_id);
CREATE INDEX idx_gym_reviews_gym_id ON gym_reviews(gym_id);
CREATE INDEX idx_gym_reviews_user_id ON gym_reviews(user_id);

-- 搭子系统索引
CREATE INDEX idx_gym_buddy_groups_gym_id ON gym_buddy_groups(gym_id);
CREATE INDEX idx_gym_buddy_groups_leader_user_id ON gym_buddy_groups(leader_user_id);
CREATE INDEX idx_gym_buddy_groups_status ON gym_buddy_groups(status);
CREATE INDEX idx_gym_buddy_members_group_id ON gym_buddy_members(group_id);
CREATE INDEX idx_gym_buddy_members_user_id ON gym_buddy_members(user_id);
CREATE INDEX idx_gym_discounts_gym_id ON gym_discounts(gym_id);
CREATE INDEX idx_gym_discounts_is_active ON gym_discounts(is_active);
CREATE INDEX idx_gym_buddy_requests_group_id ON gym_buddy_requests(group_id);
CREATE INDEX idx_gym_buddy_requests_requester_user_id ON gym_buddy_requests(requester_user_id);

-- 消息系统索引
CREATE INDEX idx_conversations_type ON conversations(conversation_type);
CREATE INDEX idx_conversations_last_message_at ON conversations(last_message_at);
CREATE INDEX idx_conversation_members_conversation_id ON conversation_members(conversation_id);
CREATE INDEX idx_conversation_members_user_id ON conversation_members(user_id);
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_message_read_status_message_id ON message_read_status(message_id);
CREATE INDEX idx_message_read_status_user_id ON message_read_status(user_id);

-- 统计系统索引
CREATE INDEX idx_body_metrics_user_id ON body_metrics(user_id);
CREATE INDEX idx_body_metrics_recorded_at ON body_metrics(recorded_at);
CREATE INDEX idx_training_statistics_user_id ON training_statistics(user_id);
CREATE INDEX idx_training_statistics_date ON training_statistics(date);
CREATE INDEX idx_nutrition_statistics_user_id ON nutrition_statistics(user_id);
CREATE INDEX idx_nutrition_statistics_date ON nutrition_statistics(date);
CREATE INDEX idx_achievements_user_id ON achievements(user_id);
CREATE INDEX idx_achievements_earned_at ON achievements(earned_at);
CREATE INDEX idx_ai_conversations_user_id ON ai_conversations(user_id);
CREATE INDEX idx_ai_conversations_conversation_type ON ai_conversations(conversation_type);

-- JSONB 字段索引 (GIN索引)
CREATE INDEX idx_posts_images ON posts USING GIN (images);
CREATE INDEX idx_posts_tags ON posts USING GIN (tags);
CREATE INDEX idx_posts_training_data ON posts USING GIN (training_data);
CREATE INDEX idx_posts_nutrition_data ON posts USING GIN (nutrition_data);
CREATE INDEX idx_training_plan_details_exercises ON training_plan_details USING GIN (exercises);
CREATE INDEX idx_workout_sessions_exercises_completed ON workout_sessions USING GIN (exercises_completed);
CREATE INDEX idx_gyms_opening_hours ON gyms USING GIN (opening_hours);
CREATE INDEX idx_gyms_facilities ON gyms USING GIN (facilities);
CREATE INDEX idx_gyms_images ON gyms USING GIN (images);
CREATE INDEX idx_ai_conversations_context_data ON ai_conversations USING GIN (context_data);

-- =====================================================
-- 9. 触发器函数
-- =====================================================

-- 更新时间戳触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为所有有updated_at字段的表创建触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON user_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_post_comments_updated_at BEFORE UPDATE ON post_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_training_plans_updated_at BEFORE UPDATE ON training_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workout_sessions_updated_at BEFORE UPDATE ON workout_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_gyms_updated_at BEFORE UPDATE ON gyms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_gym_reviews_updated_at BEFORE UPDATE ON gym_reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_gym_buddy_groups_updated_at BEFORE UPDATE ON gym_buddy_groups FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_gym_discounts_updated_at BEFORE UPDATE ON gym_discounts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 更新统计信息的触发器函数
CREATE OR REPLACE FUNCTION update_post_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF TG_TABLE_NAME = 'post_likes' THEN
            UPDATE posts SET like_count = like_count + 1 WHERE id = NEW.post_id;
        ELSIF TG_TABLE_NAME = 'post_comments' THEN
            UPDATE posts SET comment_count = comment_count + 1 WHERE id = NEW.post_id;
        ELSIF TG_TABLE_NAME = 'post_shares' THEN
            UPDATE posts SET share_count = share_count + 1 WHERE id = NEW.post_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF TG_TABLE_NAME = 'post_likes' THEN
            UPDATE posts SET like_count = like_count - 1 WHERE id = OLD.post_id;
        ELSIF TG_TABLE_NAME = 'post_comments' THEN
            UPDATE posts SET comment_count = comment_count - 1 WHERE id = OLD.post_id;
        ELSIF TG_TABLE_NAME = 'post_shares' THEN
            UPDATE posts SET share_count = share_count - 1 WHERE id = OLD.post_id;
        END IF;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- 创建统计更新触发器
CREATE TRIGGER update_post_like_count AFTER INSERT OR DELETE ON post_likes FOR EACH ROW EXECUTE FUNCTION update_post_stats();
CREATE TRIGGER update_post_comment_count AFTER INSERT OR DELETE ON post_comments FOR EACH ROW EXECUTE FUNCTION update_post_stats();
CREATE TRIGGER update_post_share_count AFTER INSERT OR DELETE ON post_shares FOR EACH ROW EXECUTE FUNCTION update_post_stats();

-- =====================================================
-- 10. 视图创建
-- =====================================================

-- 用户基本信息视图
CREATE OR REPLACE VIEW user_profiles AS
SELECT 
    u.id,
    u.username,
    u.email,
    u.avatar_url,
    u.bio,
    u.fitness_goal,
    u.height,
    u.weight,
    u.age,
    u.gender,
    u.experience_level,
    u.created_at,
    COUNT(DISTINCT f1.follower_id) as follower_count,
    COUNT(DISTINCT f2.following_id) as following_count
FROM users u
LEFT JOIN user_follows f1 ON u.id = f1.following_id
LEFT JOIN user_follows f2 ON u.id = f2.follower_id
WHERE u.is_active = TRUE AND u.deleted_at IS NULL
GROUP BY u.id;

-- 健身房详细信息视图
CREATE OR REPLACE VIEW gym_details AS
SELECT 
    g.id,
    g.name,
    g.address,
    g.latitude,
    g.longitude,
    g.description,
    g.phone,
    g.website,
    g.opening_hours,
    g.facilities,
    g.images,
    g.membership_fee,
    g.daily_fee,
    g.currency,
    g.is_verified,
    g.is_active,
    g.member_count,
    g.rating,
    g.review_count,
    COUNT(DISTINCT gbg.id) as active_buddy_groups
FROM gyms g
LEFT JOIN gym_buddy_groups gbg ON g.id = gbg.gym_id AND gbg.status = 'active'
WHERE g.is_active = TRUE
GROUP BY g.id;

-- 搭子群组详细信息视图
CREATE OR REPLACE VIEW buddy_group_details AS
SELECT 
    gbg.id,
    gbg.group_name,
    gbg.description,
    gbg.goal,
    gbg.scheduled_time,
    gbg.duration_minutes,
    gbg.max_members,
    gbg.current_members,
    gbg.status,
    g.name as gym_name,
    g.address as gym_address,
    u.username as leader_username,
    u.avatar_url as leader_avatar,
    gd.discount_percent,
    gd.discount_amount
FROM gym_buddy_groups gbg
JOIN gyms g ON gbg.gym_id = g.id
JOIN users u ON gbg.leader_user_id = u.id
LEFT JOIN gym_discounts gd ON gbg.discount_applied_id = gd.id
WHERE gbg.status = 'active';

-- 训练统计视图
CREATE OR REPLACE VIEW user_training_summary AS
SELECT 
    u.id as user_id,
    u.username,
    COUNT(DISTINCT ws.id) as total_workouts,
    COALESCE(SUM(ws.duration_minutes), 0) as total_duration_minutes,
    COALESCE(SUM(ws.calories_burned), 0) as total_calories_burned,
    COUNT(DISTINCT tp.id) as total_plans,
    MAX(ws.start_time) as last_workout_date
FROM users u
LEFT JOIN workout_sessions ws ON u.id = ws.user_id AND ws.is_completed = TRUE
LEFT JOIN training_plans tp ON u.id = tp.user_id
WHERE u.is_active = TRUE
GROUP BY u.id, u.username;

-- =====================================================
-- 11. 数据约束和检查
-- =====================================================

-- 添加额外的约束
ALTER TABLE users ADD CONSTRAINT chk_users_age CHECK (age >= 0 AND age <= 150);
ALTER TABLE users ADD CONSTRAINT chk_users_height CHECK (height > 0 AND height <= 300);
ALTER TABLE users ADD CONSTRAINT chk_users_weight CHECK (weight > 0 AND weight <= 500);
ALTER TABLE users ADD CONSTRAINT chk_users_gender CHECK (gender IN ('male', 'female', 'other'));

ALTER TABLE posts ADD CONSTRAINT chk_posts_like_count CHECK (like_count >= 0);
ALTER TABLE posts ADD CONSTRAINT chk_posts_comment_count CHECK (comment_count >= 0);
ALTER TABLE posts ADD CONSTRAINT chk_posts_share_count CHECK (share_count >= 0);

ALTER TABLE training_plans ADD CONSTRAINT chk_training_plans_duration CHECK (duration_weeks > 0);
ALTER TABLE training_plans ADD CONSTRAINT chk_training_plans_frequency CHECK (frequency_per_week > 0 AND frequency_per_week <= 7);

ALTER TABLE workout_sessions ADD CONSTRAINT chk_workout_sessions_duration CHECK (duration_minutes > 0);
ALTER TABLE workout_sessions ADD CONSTRAINT chk_workout_sessions_calories CHECK (calories_burned >= 0);

ALTER TABLE nutrition_logs ADD CONSTRAINT chk_nutrition_logs_quantity CHECK (quantity > 0);
ALTER TABLE nutrition_logs ADD CONSTRAINT chk_nutrition_logs_calories CHECK (calories >= 0);

ALTER TABLE water_logs ADD CONSTRAINT chk_water_logs_amount CHECK (amount_ml > 0);

ALTER TABLE gym_buddy_groups ADD CONSTRAINT chk_buddy_groups_max_members CHECK (max_members > 0);
ALTER TABLE gym_buddy_groups ADD CONSTRAINT chk_buddy_groups_current_members CHECK (current_members >= 0 AND current_members <= max_members);

ALTER TABLE gym_discounts ADD CONSTRAINT chk_gym_discounts_min_group_size CHECK (min_group_size >= 2);
ALTER TABLE gym_discounts ADD CONSTRAINT chk_gym_discounts_max_group_size CHECK (max_group_size IS NULL OR max_group_size >= min_group_size);

ALTER TABLE body_metrics ADD CONSTRAINT chk_body_metrics_weight CHECK (weight > 0 AND weight <= 500);
ALTER TABLE body_metrics ADD CONSTRAINT chk_body_metrics_height CHECK (height > 0 AND height <= 300);
ALTER TABLE body_metrics ADD CONSTRAINT chk_body_metrics_bmi CHECK (bmi >= 0 AND bmi <= 100);

-- =====================================================
-- 12. 注释
-- =====================================================

-- 表注释
COMMENT ON TABLE users IS '用户基本信息表';
COMMENT ON TABLE user_follows IS '用户关注关系表';
COMMENT ON TABLE user_settings IS '用户设置表';
COMMENT ON TABLE posts IS '社区动态表';
COMMENT ON TABLE post_likes IS '动态点赞表';
COMMENT ON TABLE post_comments IS '动态评论表';
COMMENT ON TABLE training_plans IS '训练计划表';
COMMENT ON TABLE workout_sessions IS '训练记录表';
COMMENT ON TABLE nutrition_logs IS '营养记录表';
COMMENT ON TABLE gyms IS '健身房信息表';
COMMENT ON TABLE gym_buddy_groups IS '搭子群组表';
COMMENT ON TABLE gym_buddy_members IS '搭子成员表';
COMMENT ON TABLE gym_discounts IS '健身房折扣表';
COMMENT ON TABLE conversations IS '会话表';
COMMENT ON TABLE messages IS '消息表';
COMMENT ON TABLE body_metrics IS '身体指标表';
COMMENT ON TABLE training_statistics IS '训练统计表';
COMMENT ON TABLE nutrition_statistics IS '营养统计表';
COMMENT ON TABLE achievements IS '成就表';
COMMENT ON TABLE ai_conversations IS 'AI对话记录表';

-- 字段注释
COMMENT ON COLUMN users.fitness_goal IS '健身目标：增肌、减脂、塑形、力量、有氧等';
COMMENT ON COLUMN users.experience_level IS '健身经验等级：beginner、intermediate、advanced';
COMMENT ON COLUMN posts.post_type IS '动态类型：dynamic、mood、nutrition、training、achievement';
COMMENT ON COLUMN posts.mood_type IS '心情类型：happy、sad、excited、tired、motivated等';
COMMENT ON COLUMN training_plans.plan_type IS '训练计划类型：strength、cardio、flexibility、mixed';
COMMENT ON COLUMN workout_sessions.workout_type IS '训练类型：strength、cardio、yoga等';
COMMENT ON COLUMN gym_buddy_groups.goal IS '搭子目标：增肌、减脂、塑形、力量、有氧';
COMMENT ON COLUMN gym_buddy_groups.status IS '群组状态：active、completed、cancelled、full';
COMMENT ON COLUMN conversations.conversation_type IS '会话类型：direct、group、buddy_group';
COMMENT ON COLUMN messages.message_type IS '消息类型：text、image、video、file、system';

-- =====================================================
-- 数据库设计完成
-- =====================================================
