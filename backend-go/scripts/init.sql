-- FitTracker 数据库初始化脚本
-- 创建数据库和用户

-- 创建数据库
CREATE DATABASE fittracker;

-- 创建用户
CREATE USER fittracker WITH PASSWORD 'fittracker123';

-- 授权
GRANT ALL PRIVILEGES ON DATABASE fittracker TO fittracker;

-- 连接到数据库
\c fittracker;

-- 授权schema权限
GRANT ALL ON SCHEMA public TO fittracker;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO fittracker;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO fittracker;

-- 设置默认权限
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO fittracker;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO fittracker;

-- 创建扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 创建索引优化
-- 用户表索引
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- 动态表索引
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at);
CREATE INDEX IF NOT EXISTS idx_posts_is_public ON posts(is_public);
CREATE INDEX IF NOT EXISTS idx_posts_workout_type ON posts(workout_type);

-- 点赞表索引
CREATE INDEX IF NOT EXISTS idx_post_likes_user_id ON post_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_post_id ON post_likes(post_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_post_likes_user_post ON post_likes(user_id, post_id);

-- 评论表索引
CREATE INDEX IF NOT EXISTS idx_post_comments_user_id ON post_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_post_comments_post_id ON post_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_post_comments_parent_id ON post_comments(parent_id);
CREATE INDEX IF NOT EXISTS idx_post_comments_created_at ON post_comments(created_at);

-- 关注表索引
CREATE INDEX IF NOT EXISTS idx_follows_user_id ON follows(user_id);
CREATE INDEX IF NOT EXISTS idx_follows_following_id ON follows(following_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_follows_user_following ON follows(user_id, following_id);

-- 训练计划表索引
CREATE INDEX IF NOT EXISTS idx_workout_plans_user_id ON workout_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_plans_is_public ON workout_plans(is_public);
CREATE INDEX IF NOT EXISTS idx_workout_plans_is_active ON workout_plans(is_active);
CREATE INDEX IF NOT EXISTS idx_workout_plans_created_at ON workout_plans(created_at);

-- 训练会话表索引
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_plan_id ON workout_sessions(plan_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_date ON workout_sessions(date);

-- 训练动作表索引
CREATE INDEX IF NOT EXISTS idx_workout_exercises_session_id ON workout_exercises(session_id);
CREATE INDEX IF NOT EXISTS idx_workout_exercises_category ON workout_exercises(category);

-- 打卡记录表索引
CREATE INDEX IF NOT EXISTS idx_check_ins_user_id ON check_ins(user_id);
CREATE INDEX IF NOT EXISTS idx_check_ins_date ON check_ins(date);
CREATE UNIQUE INDEX IF NOT EXISTS idx_check_ins_user_date ON check_ins(user_id, date);

-- AI模型表索引
CREATE INDEX IF NOT EXISTS idx_ai_models_name ON ai_models(name);
CREATE INDEX IF NOT EXISTS idx_ai_models_provider ON ai_models(provider);
CREATE INDEX IF NOT EXISTS idx_ai_models_is_active ON ai_models(is_active);

-- AI请求表索引
CREATE INDEX IF NOT EXISTS idx_ai_requests_user_id ON ai_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_requests_model_id ON ai_requests(model_id);
CREATE INDEX IF NOT EXISTS idx_ai_requests_request_type ON ai_requests(request_type);
CREATE INDEX IF NOT EXISTS idx_ai_requests_status ON ai_requests(status);
CREATE INDEX IF NOT EXISTS idx_ai_requests_created_at ON ai_requests(created_at);

-- 插入示例数据
INSERT INTO users (username, email, password, nickname, bio, fitness_goal, experience, is_active, is_verified, created_at, updated_at) VALUES
('admin', 'admin@fittracker.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '管理员', 'FitTracker管理员账户', '增肌', '高级', true, true, NOW(), NOW()),
('testuser1', 'user1@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '健身达人', '热爱健身的普通用户', '减脂', '中级', true, false, NOW(), NOW()),
('testuser2', 'user2@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '新手小白', '刚开始健身的新手', '塑形', '初级', true, false, NOW(), NOW());

-- 插入AI模型配置
INSERT INTO ai_models (name, provider, model_name, api_key, is_active, created_at, updated_at) VALUES
('腾讯混元', 'tencent', 'hunyuan-lite', 'sk-O5tVxVeCGTtSgPlaHMuPe9CdmgEUuy2d79yK5rf5Rp5qsI3m', true, NOW(), NOW()),
('DeepSeek', 'deepseek', 'deepseek-chat', 'sk-c4a84c8bbff341cbb3006ecaf84030fe', true, NOW(), NOW()),
('Groq', 'groq', 'llama3-8b-8192', 'your-groq-api-key', false, NOW(), NOW());

-- 创建触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为相关表添加更新时间触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_post_comments_updated_at BEFORE UPDATE ON post_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workout_plans_updated_at BEFORE UPDATE ON workout_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workout_sessions_updated_at BEFORE UPDATE ON workout_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workout_exercises_updated_at BEFORE UPDATE ON workout_exercises FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_check_ins_updated_at BEFORE UPDATE ON check_ins FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ai_models_updated_at BEFORE UPDATE ON ai_models FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ai_requests_updated_at BEFORE UPDATE ON ai_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 创建全文搜索索引
CREATE INDEX IF NOT EXISTS idx_posts_content_fts ON posts USING gin(to_tsvector('chinese', content));
CREATE INDEX IF NOT EXISTS idx_post_comments_content_fts ON post_comments USING gin(to_tsvector('chinese', content));
CREATE INDEX IF NOT EXISTS idx_workout_plans_title_fts ON workout_plans USING gin(to_tsvector('chinese', title));
CREATE INDEX IF NOT EXISTS idx_workout_plans_description_fts ON workout_plans USING gin(to_tsvector('chinese', description));

-- 创建复合索引
CREATE INDEX IF NOT EXISTS idx_posts_user_created ON posts(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_public_created ON posts(is_public, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_date ON workout_sessions(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_check_ins_user_date ON check_ins(user_id, date DESC);

-- 创建统计视图
CREATE OR REPLACE VIEW user_stats AS
SELECT 
    u.id,
    u.username,
    u.nickname,
    COUNT(DISTINCT p.id) as post_count,
    COUNT(DISTINCT f1.id) as follower_count,
    COUNT(DISTINCT f2.id) as following_count,
    COUNT(DISTINCT wp.id) as workout_plan_count,
    COUNT(DISTINCT ws.id) as workout_session_count,
    COUNT(DISTINCT ci.id) as check_in_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id AND p.is_public = true
LEFT JOIN follows f1 ON u.id = f1.following_id
LEFT JOIN follows f2 ON u.id = f2.user_id
LEFT JOIN workout_plans wp ON u.id = wp.user_id
LEFT JOIN workout_sessions ws ON u.id = ws.user_id
LEFT JOIN check_ins ci ON u.id = ci.user_id
GROUP BY u.id, u.username, u.nickname;

-- 创建热门动态视图
CREATE OR REPLACE VIEW popular_posts AS
SELECT 
    p.*,
    u.username,
    u.nickname,
    u.avatar,
    COUNT(DISTINCT pl.id) as like_count,
    COUNT(DISTINCT pc.id) as comment_count,
    (COUNT(DISTINCT pl.id) * 2 + COUNT(DISTINCT pc.id)) as popularity_score
FROM posts p
JOIN users u ON p.user_id = u.id
LEFT JOIN post_likes pl ON p.id = pl.post_id
LEFT JOIN post_comments pc ON p.id = pc.post_id
WHERE p.is_public = true
GROUP BY p.id, u.username, u.nickname, u.avatar
ORDER BY popularity_score DESC, p.created_at DESC;

-- 创建训练统计视图
CREATE OR REPLACE VIEW workout_stats AS
SELECT 
    u.id as user_id,
    u.username,
    COUNT(DISTINCT ws.id) as total_sessions,
    COALESCE(SUM(ws.duration), 0) as total_duration,
    COALESCE(SUM(ws.calories), 0) as total_calories,
    COUNT(DISTINCT ci.id) as check_in_days,
    COALESCE(AVG(ws.duration), 0) as avg_duration
FROM users u
LEFT JOIN workout_sessions ws ON u.id = ws.user_id
LEFT JOIN check_ins ci ON u.id = ci.user_id
GROUP BY u.id, u.username;

-- 授权视图权限
GRANT SELECT ON user_stats TO fittracker;
GRANT SELECT ON popular_posts TO fittracker;
GRANT SELECT ON workout_stats TO fittracker;

-- 完成初始化
SELECT 'FitTracker database initialized successfully!' as message;