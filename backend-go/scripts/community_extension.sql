-- FitTracker 社区功能扩展脚本
-- 为兴趣社区功能添加新的表结构和索引

-- 1. 扩展用户表，添加社区相关字段
ALTER TABLE users ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS fitness_tags TEXT; -- JSON数组存储健身偏好标签
ALTER TABLE users ADD COLUMN IF NOT EXISTS fitness_goal VARCHAR(100); -- 健身目标
ALTER TABLE users ADD COLUMN IF NOT EXISTS location VARCHAR(100); -- 位置信息
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE; -- 是否认证用户
ALTER TABLE users ADD COLUMN IF NOT EXISTS followers_count INTEGER DEFAULT 0; -- 粉丝数
ALTER TABLE users ADD COLUMN IF NOT EXISTS following_count INTEGER DEFAULT 0; -- 关注数

-- 2. 扩展动态表，支持更多内容类型
ALTER TABLE posts ADD COLUMN IF NOT EXISTS video_url TEXT; -- 视频链接
ALTER TABLE posts ADD COLUMN IF NOT EXISTS tags TEXT; -- JSON数组存储话题标签
ALTER TABLE posts ADD COLUMN IF NOT EXISTS location VARCHAR(100); -- 发布位置
ALTER TABLE posts ADD COLUMN IF NOT EXISTS workout_data JSONB; -- 关联的训练数据
ALTER TABLE posts ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT FALSE; -- 是否精选
ALTER TABLE posts ADD COLUMN IF NOT EXISTS view_count INTEGER DEFAULT 0; -- 浏览次数
ALTER TABLE posts ADD COLUMN IF NOT EXISTS share_count INTEGER DEFAULT 0; -- 分享次数

-- 3. 创建话题表
CREATE TABLE IF NOT EXISTS topics (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(100), -- 话题图标
    color VARCHAR(20), -- 话题颜色
    posts_count INTEGER DEFAULT 0, -- 相关动态数量
    followers_count INTEGER DEFAULT 0, -- 关注话题的用户数
    is_hot BOOLEAN DEFAULT FALSE, -- 是否热门话题
    is_official BOOLEAN DEFAULT FALSE -- 是否官方话题
);

-- 4. 创建动态-话题关联表
CREATE TABLE IF NOT EXISTS post_topics (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    topic_id INTEGER NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
    
    UNIQUE(post_id, topic_id)
);

-- 5. 扩展评论表，支持多级回复
ALTER TABLE comments ADD COLUMN IF NOT EXISTS parent_id INTEGER REFERENCES comments(id) ON DELETE CASCADE;
ALTER TABLE comments ADD COLUMN IF NOT EXISTS reply_to_user_id INTEGER REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE comments ADD COLUMN IF NOT EXISTS likes_count INTEGER DEFAULT 0;
ALTER TABLE comments ADD COLUMN IF NOT EXISTS replies_count INTEGER DEFAULT 0;

-- 6. 创建收藏表
CREATE TABLE IF NOT EXISTS favorites (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    
    UNIQUE(user_id, post_id)
);

-- 7. 创建分享表
CREATE TABLE IF NOT EXISTS shares (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    share_type VARCHAR(20) DEFAULT 'community', -- 分享类型：community, external
    share_platform VARCHAR(50) -- 分享平台
);

-- 8. 创建用户标签表
CREATE TABLE IF NOT EXISTS user_tags (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tag_name VARCHAR(50) NOT NULL,
    tag_type VARCHAR(20) NOT NULL, -- 标签类型：fitness_goal, interest, skill
    
    UNIQUE(user_id, tag_name, tag_type)
);

-- 9. 创建挑战赛扩展表
ALTER TABLE challenges ADD COLUMN IF NOT EXISTS cover_image TEXT; -- 挑战封面图
ALTER TABLE challenges ADD COLUMN IF NOT EXISTS rules TEXT; -- 挑战规则
ALTER TABLE challenges ADD COLUMN IF NOT EXISTS rewards TEXT; -- 奖励说明
ALTER TABLE challenges ADD COLUMN IF NOT EXISTS tags TEXT; -- JSON数组存储标签
ALTER TABLE challenges ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT FALSE; -- 是否精选
ALTER TABLE challenges ADD COLUMN IF NOT EXISTS max_participants INTEGER; -- 最大参与人数
ALTER TABLE challenges ADD COLUMN IF NOT EXISTS entry_fee DECIMAL(10,2) DEFAULT 0; -- 参与费用

-- 10. 扩展挑战参与者表
ALTER TABLE challenge_participants ADD COLUMN IF NOT EXISTS joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE challenge_participants ADD COLUMN IF NOT EXISTS last_checkin_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE challenge_participants ADD COLUMN IF NOT EXISTS checkin_count INTEGER DEFAULT 0; -- 打卡次数
ALTER TABLE challenge_participants ADD COLUMN IF NOT EXISTS total_calories INTEGER DEFAULT 0; -- 总消耗卡路里
ALTER TABLE challenge_participants ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'active'; -- 状态：active, completed, dropped
ALTER TABLE challenge_participants ADD COLUMN IF NOT EXISTS rank INTEGER; -- 排名

-- 11. 创建挑战打卡记录表
CREATE TABLE IF NOT EXISTS challenge_checkins (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id INTEGER NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    participant_id INTEGER NOT NULL REFERENCES challenge_participants(id) ON DELETE CASCADE,
    
    checkin_date DATE NOT NULL,
    content TEXT, -- 打卡内容
    images TEXT, -- JSON数组存储图片
    calories INTEGER DEFAULT 0, -- 消耗卡路里
    duration INTEGER DEFAULT 0, -- 运动时长（分钟）
    notes TEXT, -- 备注
    
    UNIQUE(user_id, challenge_id, checkin_date)
);

-- 12. 创建通知表
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- 通知类型：like, comment, follow, challenge, etc.
    title VARCHAR(200) NOT NULL,
    content TEXT,
    data JSONB, -- 额外数据
    is_read BOOLEAN DEFAULT FALSE,
    related_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    related_post_id INTEGER REFERENCES posts(id) ON DELETE SET NULL,
    related_challenge_id INTEGER REFERENCES challenges(id) ON DELETE SET NULL
);

-- 13. 创建浏览记录表
CREATE TABLE IF NOT EXISTS post_views (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL, -- 可为空，支持匿名浏览
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    ip_address INET, -- IP地址
    user_agent TEXT -- 用户代理
);

-- 14. 创建搜索记录表
CREATE TABLE IF NOT EXISTS search_logs (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    query VARCHAR(200) NOT NULL,
    search_type VARCHAR(20) NOT NULL, -- 搜索类型：post, user, topic, challenge
    results_count INTEGER DEFAULT 0,
    ip_address INET
);

-- 创建索引
-- 用户相关索引
CREATE INDEX IF NOT EXISTS idx_users_fitness_tags ON users USING gin(fitness_tags);
CREATE INDEX IF NOT EXISTS idx_users_location ON users(location);
CREATE INDEX IF NOT EXISTS idx_users_followers_count ON users(followers_count DESC);

-- 动态相关索引
CREATE INDEX IF NOT EXISTS idx_posts_tags ON posts USING gin(tags);
CREATE INDEX IF NOT EXISTS idx_posts_workout_data ON posts USING gin(workout_data);
CREATE INDEX IF NOT EXISTS idx_posts_is_featured ON posts(is_featured);
CREATE INDEX IF NOT EXISTS idx_posts_view_count ON posts(view_count DESC);
CREATE INDEX IF NOT EXISTS idx_posts_hot_score ON posts((likes_count + comments_count * 2 + view_count * 0.1) DESC);

-- 话题相关索引
CREATE INDEX IF NOT EXISTS idx_topics_name ON topics(name);
CREATE INDEX IF NOT EXISTS idx_topics_is_hot ON topics(is_hot);
CREATE INDEX IF NOT EXISTS idx_topics_posts_count ON topics(posts_count DESC);

-- 评论相关索引
CREATE INDEX IF NOT EXISTS idx_comments_parent_id ON comments(parent_id);
CREATE INDEX IF NOT EXISTS idx_comments_likes_count ON comments(likes_count DESC);

-- 挑战相关索引
CREATE INDEX IF NOT EXISTS idx_challenges_is_featured ON challenges(is_featured);
CREATE INDEX IF NOT EXISTS idx_challenges_tags ON challenges USING gin(tags);
CREATE INDEX IF NOT EXISTS idx_challenge_participants_rank ON challenge_participants(rank);
CREATE INDEX IF NOT EXISTS idx_challenge_checkins_date ON challenge_checkins(checkin_date);

-- 通知相关索引
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);

-- 浏览记录索引
CREATE INDEX IF NOT EXISTS idx_post_views_post_id ON post_views(post_id);
CREATE INDEX IF NOT EXISTS idx_post_views_user_id ON post_views(user_id);

-- 搜索记录索引
CREATE INDEX IF NOT EXISTS idx_search_logs_query ON search_logs(query);
CREATE INDEX IF NOT EXISTS idx_search_logs_type ON search_logs(search_type);

-- 创建触发器函数
-- 更新话题动态数量
CREATE OR REPLACE FUNCTION update_topic_posts_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE topics SET posts_count = posts_count + 1 WHERE id = NEW.topic_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE topics SET posts_count = posts_count - 1 WHERE id = OLD.topic_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_topic_posts_count_trigger
    AFTER INSERT OR DELETE ON post_topics
    FOR EACH ROW EXECUTE FUNCTION update_topic_posts_count();

-- 更新用户关注数统计
CREATE OR REPLACE FUNCTION update_user_follow_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
        UPDATE users SET following_count = following_count + 1 WHERE id = NEW.follower_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE users SET followers_count = followers_count - 1 WHERE id = OLD.following_id;
        UPDATE users SET following_count = following_count - 1 WHERE id = OLD.follower_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_follow_stats_trigger
    AFTER INSERT OR DELETE ON follows
    FOR EACH ROW EXECUTE FUNCTION update_user_follow_stats();

-- 更新动态浏览次数
CREATE OR REPLACE FUNCTION update_post_view_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET view_count = view_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_post_view_count_trigger
    AFTER INSERT ON post_views
    FOR EACH ROW EXECUTE FUNCTION update_post_view_count();

-- 更新评论回复数
CREATE OR REPLACE FUNCTION update_comment_replies_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.parent_id IS NOT NULL THEN
            UPDATE comments SET replies_count = replies_count + 1 WHERE id = NEW.parent_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.parent_id IS NOT NULL THEN
            UPDATE comments SET replies_count = replies_count - 1 WHERE id = OLD.parent_id;
        END IF;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_comment_replies_count_trigger
    AFTER INSERT OR DELETE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_comment_replies_count();

-- 插入初始话题数据
INSERT INTO topics (name, description, icon, color, is_official) VALUES
('健身打卡', '分享你的健身日常，记录每一次进步', 'fitness_center', '#FF6B35', true),
('减脂日记', '减脂路上的点点滴滴，一起加油', 'trending_down', '#4CAF50', true),
('增肌计划', '增肌训练分享，肌肉成长的见证', 'trending_up', '#FF9800', true),
('健康饮食', '健康饮食搭配，营养均衡生活', 'restaurant', '#2196F3', true),
('晨跑', '晨跑爱好者聚集地，迎接美好一天', 'directions_run', '#9C27B0', true),
('瑜伽', '瑜伽练习分享，身心平衡', 'self_improvement', '#E91E63', true),
('力量训练', '力量训练技巧分享，突破极限', 'fitness_center', '#795548', true),
('马拉松', '马拉松训练和比赛分享', 'directions_run', '#607D8B', true),
('游泳', '游泳技巧和训练分享', 'pool', '#00BCD4', true),
('骑行', '骑行路线和装备分享', 'directions_bike', '#4CAF50', true)
ON CONFLICT (name) DO NOTHING;

-- 创建视图
-- 热门动态视图
CREATE OR REPLACE VIEW hot_posts AS
SELECT 
    p.*,
    u.username,
    u.avatar,
    u.fitness_goal,
    (p.likes_count + p.comments_count * 2 + p.view_count * 0.1 + 
     CASE WHEN p.is_featured THEN 50 ELSE 0 END) as hot_score
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE p.is_public = true AND p.deleted_at IS NULL
ORDER BY hot_score DESC, p.created_at DESC;

-- 用户统计视图
CREATE OR REPLACE VIEW user_community_stats AS
SELECT 
    u.id,
    u.username,
    u.avatar,
    u.followers_count,
    u.following_count,
    COUNT(DISTINCT p.id) as posts_count,
    COUNT(DISTINCT l.id) as total_likes_received,
    COUNT(DISTINCT c.id) as total_comments_received,
    COALESCE(SUM(p.likes_count), 0) as total_likes_on_posts,
    COALESCE(SUM(p.view_count), 0) as total_views_on_posts
FROM users u
LEFT JOIN posts p ON u.id = p.user_id AND p.deleted_at IS NULL
LEFT JOIN likes l ON p.id = l.post_id
LEFT JOIN comments c ON p.id = c.post_id
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.username, u.avatar, u.followers_count, u.following_count;

-- 挑战排行榜视图
CREATE OR REPLACE VIEW challenge_leaderboard AS
SELECT 
    cp.*,
    u.username,
    u.avatar,
    c.name as challenge_name,
    c.type as challenge_type,
    ROW_NUMBER() OVER (PARTITION BY cp.challenge_id ORDER BY cp.checkin_count DESC, cp.total_calories DESC) as rank
FROM challenge_participants cp
JOIN users u ON cp.user_id = u.id
JOIN challenges c ON cp.challenge_id = c.id
WHERE cp.status = 'active' AND c.is_active = true
ORDER BY cp.challenge_id, rank;

-- 完成初始化
SELECT 'FitTracker 社区功能扩展完成！' as message;
