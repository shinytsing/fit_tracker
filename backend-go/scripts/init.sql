-- FitTracker 数据库初始化脚本
-- 创建数据库和表结构

-- 创建数据库（如果不存在）
-- CREATE DATABASE fittracker;

-- 使用数据库
-- \c fittracker;

-- 创建扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    avatar TEXT,
    bio TEXT,
    
    -- 用户统计
    total_workouts INTEGER DEFAULT 0,
    total_checkins INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0
);

-- 训练计划表
CREATE TABLE IF NOT EXISTS training_plans (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    difficulty VARCHAR(20) NOT NULL,
    duration INTEGER,
    is_public BOOLEAN DEFAULT FALSE,
    is_ai BOOLEAN DEFAULT FALSE
);

-- 运动动作表
CREATE TABLE IF NOT EXISTS exercises (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    muscle_groups TEXT,
    equipment VARCHAR(100),
    difficulty VARCHAR(20),
    instructions TEXT,
    video_url TEXT,
    image_url TEXT
);

-- 训练记录表
CREATE TABLE IF NOT EXISTS workouts (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id INTEGER REFERENCES training_plans(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    duration INTEGER,
    calories INTEGER,
    difficulty VARCHAR(20),
    notes TEXT,
    rating DECIMAL(3,2)
);

-- 训练记录-运动动作关联表
CREATE TABLE IF NOT EXISTS workout_exercises (
    workout_id INTEGER NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    sets INTEGER DEFAULT 1,
    reps INTEGER,
    duration INTEGER,
    weight DECIMAL(8,2),
    rest_time INTEGER,
    order_index INTEGER DEFAULT 0,
    PRIMARY KEY (workout_id, exercise_id)
);

-- 签到记录表
CREATE TABLE IF NOT EXISTS checkins (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    type VARCHAR(50) NOT NULL,
    notes TEXT,
    mood VARCHAR(20),
    energy INTEGER CHECK (energy >= 1 AND energy <= 10),
    motivation INTEGER CHECK (motivation >= 1 AND motivation <= 10),
    
    UNIQUE(user_id, date)
);

-- 健康记录表
CREATE TABLE IF NOT EXISTS health_records (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    type VARCHAR(50) NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20),
    notes TEXT
);

-- 社区动态表
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    images TEXT,
    type VARCHAR(50),
    is_public BOOLEAN DEFAULT TRUE,
    
    -- 统计信息
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0
);

-- 点赞表
CREATE TABLE IF NOT EXISTS likes (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    
    UNIQUE(user_id, post_id)
);

-- 评论表
CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    content TEXT NOT NULL
);

-- 关注关系表
CREATE TABLE IF NOT EXISTS follows (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    follower_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    UNIQUE(follower_id, following_id),
    CHECK(follower_id != following_id)
);

-- 挑战表
CREATE TABLE IF NOT EXISTS challenges (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    difficulty VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- 统计信息
    participants_count INTEGER DEFAULT 0
);

-- 挑战参与者表
CREATE TABLE IF NOT EXISTS challenge_participants (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id INTEGER NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    
    UNIQUE(user_id, challenge_id)
);

-- 营养记录表
CREATE TABLE IF NOT EXISTS nutrition_records (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    meal_type VARCHAR(20) NOT NULL,
    food_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20),
    calories DECIMAL(10,2),
    protein DECIMAL(10,2),
    carbs DECIMAL(10,2),
    fat DECIMAL(10,2),
    fiber DECIMAL(10,2),
    sugar DECIMAL(10,2),
    sodium DECIMAL(10,2),
    notes TEXT
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON users(deleted_at);

CREATE INDEX IF NOT EXISTS idx_workouts_user_id ON workouts(user_id);
CREATE INDEX IF NOT EXISTS idx_workouts_plan_id ON workouts(plan_id);
CREATE INDEX IF NOT EXISTS idx_workouts_created_at ON workouts(created_at);

CREATE INDEX IF NOT EXISTS idx_checkins_user_id ON checkins(user_id);
CREATE INDEX IF NOT EXISTS idx_checkins_date ON checkins(date);
CREATE INDEX IF NOT EXISTS idx_checkins_user_date ON checkins(user_id, date);

CREATE INDEX IF NOT EXISTS idx_health_records_user_id ON health_records(user_id);
CREATE INDEX IF NOT EXISTS idx_health_records_date ON health_records(date);
CREATE INDEX IF NOT EXISTS idx_health_records_type ON health_records(type);

CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at);
CREATE INDEX IF NOT EXISTS idx_posts_is_public ON posts(is_public);

CREATE INDEX IF NOT EXISTS idx_likes_user_id ON likes(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_post_id ON likes(post_id);

CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);

CREATE INDEX IF NOT EXISTS idx_follows_follower_id ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following_id ON follows(following_id);

CREATE INDEX IF NOT EXISTS idx_challenges_is_active ON challenges(is_active);
CREATE INDEX IF NOT EXISTS idx_challenges_start_date ON challenges(start_date);
CREATE INDEX IF NOT EXISTS idx_challenges_end_date ON challenges(end_date);

CREATE INDEX IF NOT EXISTS idx_challenge_participants_user_id ON challenge_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_participants_challenge_id ON challenge_participants(challenge_id);

CREATE INDEX IF NOT EXISTS idx_nutrition_records_user_id ON nutrition_records(user_id);
CREATE INDEX IF NOT EXISTS idx_nutrition_records_date ON nutrition_records(date);
CREATE INDEX IF NOT EXISTS idx_nutrition_records_meal_type ON nutrition_records(meal_type);

-- 创建触发器函数用于自动更新 updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为所有表添加 updated_at 触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_training_plans_updated_at BEFORE UPDATE ON training_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_exercises_updated_at BEFORE UPDATE ON exercises FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workouts_updated_at BEFORE UPDATE ON workouts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_checkins_updated_at BEFORE UPDATE ON checkins FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_health_records_updated_at BEFORE UPDATE ON health_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_likes_updated_at BEFORE UPDATE ON likes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_follows_updated_at BEFORE UPDATE ON follows FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_challenges_updated_at BEFORE UPDATE ON challenges FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_challenge_participants_updated_at BEFORE UPDATE ON challenge_participants FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_nutrition_records_updated_at BEFORE UPDATE ON nutrition_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 插入初始数据
INSERT INTO exercises (name, description, category, muscle_groups, equipment, difficulty, instructions) VALUES
('俯卧撑', '经典的上肢力量训练动作', '力量训练', '胸肌,三头肌,肩部', '无器械', '初级', '1. 俯卧撑姿势，双手与肩同宽\n2. 保持身体挺直，核心收紧\n3. 下降至胸部接近地面\n4. 推起至起始位置'),
('深蹲', '下肢力量训练的基础动作', '力量训练', '股四头肌,臀肌,腘绳肌', '无器械', '初级', '1. 双脚与肩同宽站立\n2. 下蹲至大腿与地面平行\n3. 保持背部挺直\n4. 起身至起始位置'),
('平板支撑', '核心力量训练动作', '核心训练', '腹肌,背部,肩部', '无器械', '初级', '1. 俯卧撑姿势，前臂着地\n2. 保持身体挺直\n3. 收紧核心肌群\n4. 保持姿势30-60秒'),
('引体向上', '背部力量训练动作', '力量训练', '背阔肌,二头肌,肩部', '单杠', '中级', '1. 双手正握单杠\n2. 身体悬垂\n3. 上拉至下巴过杠\n4. 缓慢下降'),
('硬拉', '全身力量训练动作', '力量训练', '背部,臀肌,腘绳肌,核心', '杠铃', '高级', '1. 双脚与肩同宽站立\n2. 弯腰抓握杠铃\n3. 保持背部挺直\n4. 起身至直立位置');

INSERT INTO training_plans (name, description, type, difficulty, duration, is_public) VALUES
('新手入门计划', '适合健身新手的4周训练计划', '全身训练', '初级', 4, true),
('增肌训练计划', '8周增肌训练计划', '力量训练', '中级', 8, true),
('减脂训练计划', '6周减脂训练计划', '有氧训练', '中级', 6, true),
('核心强化计划', '4周核心肌群强化计划', '核心训练', '初级', 4, true),
('HIIT训练计划', '高强度间歇训练计划', '有氧训练', '高级', 4, true);

-- 创建视图
CREATE OR REPLACE VIEW user_stats AS
SELECT 
    u.id as user_id,
    u.total_workouts,
    u.total_checkins,
    u.current_streak,
    u.longest_streak,
    COALESCE(SUM(w.calories), 0) as total_calories,
    COALESCE(AVG(w.rating), 0) as average_rating,
    (SELECT COUNT(*) FROM follows WHERE following_id = u.id) as followers_count,
    (SELECT COUNT(*) FROM follows WHERE follower_id = u.id) as following_count
FROM users u
LEFT JOIN workouts w ON u.id = w.user_id AND w.deleted_at IS NULL
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.total_workouts, u.total_checkins, u.current_streak, u.longest_streak;

-- 创建函数
CREATE OR REPLACE FUNCTION update_post_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF TG_TABLE_NAME = 'likes' THEN
            UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
        ELSIF TG_TABLE_NAME = 'comments' THEN
            UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF TG_TABLE_NAME = 'likes' THEN
            UPDATE posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
        ELSIF TG_TABLE_NAME = 'comments' THEN
            UPDATE posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
        END IF;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
CREATE TRIGGER update_post_likes_count 
    AFTER INSERT OR DELETE ON likes 
    FOR EACH ROW EXECUTE FUNCTION update_post_stats();

CREATE TRIGGER update_post_comments_count 
    AFTER INSERT OR DELETE ON comments 
    FOR EACH ROW EXECUTE FUNCTION update_post_stats();

-- 创建挑战参与者计数触发器
CREATE OR REPLACE FUNCTION update_challenge_participants_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE challenges SET participants_count = participants_count + 1 WHERE id = NEW.challenge_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE challenges SET participants_count = participants_count - 1 WHERE id = OLD.challenge_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_challenge_participants_count_trigger
    AFTER INSERT OR DELETE ON challenge_participants
    FOR EACH ROW EXECUTE FUNCTION update_challenge_participants_count();

-- 创建用户统计更新触发器
CREATE OR REPLACE FUNCTION update_user_workout_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users SET total_workouts = total_workouts + 1 WHERE id = NEW.user_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE users SET total_workouts = total_workouts - 1 WHERE id = OLD.user_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_workout_stats_trigger
    AFTER INSERT OR DELETE ON workouts
    FOR EACH ROW EXECUTE FUNCTION update_user_workout_stats();

CREATE OR REPLACE FUNCTION update_user_checkin_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users SET total_checkins = total_checkins + 1 WHERE id = NEW.user_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE users SET total_checkins = total_checkins - 1 WHERE id = OLD.user_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_checkin_stats_trigger
    AFTER INSERT OR DELETE ON checkins
    FOR EACH ROW EXECUTE FUNCTION update_user_checkin_stats();

-- 创建全文搜索索引
CREATE INDEX IF NOT EXISTS idx_posts_content_fts ON posts USING gin(to_tsvector('chinese', content));
CREATE INDEX IF NOT EXISTS idx_exercises_name_fts ON exercises USING gin(to_tsvector('chinese', name));
CREATE INDEX IF NOT EXISTS idx_training_plans_name_fts ON training_plans USING gin(to_tsvector('chinese', name));

-- 创建复合索引
CREATE INDEX IF NOT EXISTS idx_workouts_user_created ON workouts(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_user_created ON posts(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_checkins_user_date ON checkins(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_nutrition_records_user_date ON nutrition_records(user_id, date DESC);

-- 设置时区
SET timezone = 'Asia/Shanghai';

-- 完成初始化
SELECT 'FitTracker 数据库初始化完成！' as message;
