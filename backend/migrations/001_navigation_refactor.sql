-- 导航重构数据库迁移脚本
-- 按照功能重排表更新数据库结构

-- 1. 更新posts表，添加新的发布类型
ALTER TABLE posts ADD COLUMN IF NOT EXISTS post_type VARCHAR(50) DEFAULT 'dynamic';
ALTER TABLE posts ADD COLUMN IF NOT EXISTS mood_type VARCHAR(50);
ALTER TABLE posts ADD COLUMN IF NOT EXISTS nutrition_data JSONB;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS training_data JSONB;

-- 2. 创建草稿表
CREATE TABLE IF NOT EXISTS drafts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    images JSONB,
    tags JSONB,
    post_type VARCHAR(50) DEFAULT 'dynamic',
    mood_type VARCHAR(50),
    nutrition_data JSONB,
    training_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. 创建教练表
CREATE TABLE IF NOT EXISTS coaches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    certification TEXT,
    experience_years INTEGER DEFAULT 0,
    specialties TEXT[],
    rating DECIMAL(3,2) DEFAULT 0.0,
    total_students INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. 创建经验文章表
CREATE TABLE IF NOT EXISTS experience_articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    coach_id UUID NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    summary TEXT,
    tags TEXT[],
    cover_image_url VARCHAR(500),
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. 创建在线课程表
CREATE TABLE IF NOT EXISTS online_courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    coach_id UUID NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    cover_image_url VARCHAR(500),
    video_url VARCHAR(500),
    duration_minutes INTEGER,
    difficulty_level VARCHAR(50),
    price DECIMAL(10,2) DEFAULT 0.0,
    is_free BOOLEAN DEFAULT FALSE,
    enrollment_count INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0.0,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. 创建课程报名表
CREATE TABLE IF NOT EXISTS course_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES online_courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    progress_percentage DECIMAL(5,2) DEFAULT 0.0,
    UNIQUE(user_id, course_id)
);

-- 7. 创建营养记录表
CREATE TABLE IF NOT EXISTS nutrition_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    meal_type VARCHAR(50), -- breakfast, lunch, dinner, snack
    food_name VARCHAR(255),
    quantity DECIMAL(10,2),
    unit VARCHAR(50),
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

-- 8. 创建饮水记录表
CREATE TABLE IF NOT EXISTS water_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount_ml INTEGER NOT NULL,
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. 创建身体指标记录表
CREATE TABLE IF NOT EXISTS body_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weight DECIMAL(5,2),
    height DECIMAL(5,2),
    bmi DECIMAL(4,2),
    body_fat_percentage DECIMAL(5,2),
    muscle_mass DECIMAL(5,2),
    bone_density DECIMAL(5,2),
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. 创建AI助手对话表
CREATE TABLE IF NOT EXISTS ai_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    conversation_type VARCHAR(50), -- training, nutrition, health
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    context_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_posts_type ON posts(post_type);
CREATE INDEX IF NOT EXISTS idx_drafts_user_id ON drafts(user_id);
CREATE INDEX IF NOT EXISTS idx_coaches_user_id ON coaches(user_id);
CREATE INDEX IF NOT EXISTS idx_coaches_verified ON coaches(is_verified);
CREATE INDEX IF NOT EXISTS idx_articles_coach_id ON experience_articles(coach_id);
CREATE INDEX IF NOT EXISTS idx_articles_published ON experience_articles(is_published);
CREATE INDEX IF NOT EXISTS idx_courses_coach_id ON online_courses(coach_id);
CREATE INDEX IF NOT EXISTS idx_courses_published ON online_courses(is_published);
CREATE INDEX IF NOT EXISTS idx_enrollments_user_id ON course_enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON course_enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_nutrition_user_id ON nutrition_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_nutrition_logged_at ON nutrition_logs(logged_at);
CREATE INDEX IF NOT EXISTS idx_water_user_id ON water_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_water_logged_at ON water_logs(logged_at);
CREATE INDEX IF NOT EXISTS idx_body_metrics_user_id ON body_metrics(user_id);
CREATE INDEX IF NOT EXISTS idx_body_metrics_recorded_at ON body_metrics(recorded_at);
CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_id ON ai_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_conversations_type ON ai_conversations(conversation_type);

-- 12. 更新现有数据
UPDATE posts SET post_type = 'dynamic' WHERE post_type IS NULL;

-- 13. 添加触发器以自动更新updated_at字段
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为所有表添加updated_at触发器
CREATE TRIGGER update_drafts_updated_at BEFORE UPDATE ON drafts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_coaches_updated_at BEFORE UPDATE ON coaches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_articles_updated_at BEFORE UPDATE ON experience_articles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON online_courses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 14. 插入示例数据
INSERT INTO coaches (user_id, certification, experience_years, specialties, rating, total_students, is_verified)
SELECT 
    u.id,
    'ACE Certified Personal Trainer',
    FLOOR(RANDOM() * 10) + 1,
    ARRAY['Weight Training', 'Cardio', 'Nutrition'],
    ROUND((RANDOM() * 2) + 3, 2),
    FLOOR(RANDOM() * 100) + 10,
    TRUE
FROM users u
WHERE u.id NOT IN (SELECT user_id FROM coaches)
LIMIT 5;

-- 15. 创建视图以便于查询
CREATE OR REPLACE VIEW coach_profiles AS
SELECT 
    c.id as coach_id,
    u.username,
    u.avatar_url,
    u.bio,
    c.certification,
    c.experience_years,
    c.specialties,
    c.rating,
    c.total_students,
    c.is_verified
FROM coaches c
JOIN users u ON c.user_id = u.id;

CREATE OR REPLACE VIEW published_articles AS
SELECT 
    ea.id,
    ea.title,
    ea.summary,
    ea.tags,
    ea.cover_image_url,
    ea.view_count,
    ea.like_count,
    cp.username as coach_name,
    cp.avatar_url as coach_avatar
FROM experience_articles ea
JOIN coach_profiles cp ON ea.coach_id = cp.coach_id
WHERE ea.is_published = TRUE;

CREATE OR REPLACE VIEW published_courses AS
SELECT 
    oc.id,
    oc.title,
    oc.description,
    oc.cover_image_url,
    oc.duration_minutes,
    oc.difficulty_level,
    oc.price,
    oc.is_free,
    oc.enrollment_count,
    oc.rating,
    cp.username as coach_name,
    cp.avatar_url as coach_avatar
FROM online_courses oc
JOIN coach_profiles cp ON oc.coach_id = cp.coach_id
WHERE oc.is_published = TRUE;

-- 16. 添加注释
COMMENT ON TABLE drafts IS '用户草稿表，支持编辑、修改、再次发布';
COMMENT ON TABLE coaches IS '教练信息表，包含认证、经验、专业领域等';
COMMENT ON TABLE experience_articles IS '经验文章表，教练分享的专业知识';
COMMENT ON TABLE online_courses IS '在线课程表，教练提供的付费课程';
COMMENT ON TABLE course_enrollments IS '课程报名表，用户报名课程记录';
COMMENT ON TABLE nutrition_logs IS '营养记录表，用户饮食记录';
COMMENT ON TABLE water_logs IS '饮水记录表，用户饮水追踪';
COMMENT ON TABLE body_metrics IS '身体指标表，BMI、体脂率、肌肉量等';
COMMENT ON TABLE ai_conversations IS 'AI助手对话表，训练/营养/健康问答';

COMMENT ON COLUMN posts.post_type IS '发布类型：dynamic, mood, nutrition, training_data, workout';
COMMENT ON COLUMN posts.mood_type IS '心情类型：happy, sad, excited, tired等';
COMMENT ON COLUMN posts.nutrition_data IS '营养数据JSON，包含卡路里、蛋白质等';
COMMENT ON COLUMN posts.training_data IS '训练数据JSON，包含时长、强度等';
