-- 健身房找搭子系统数据库迁移
-- 创建时间: 2024-01-01
-- 描述: 添加健身房、搭子申请、折扣策略相关表

-- 1. 健身房表
CREATE TABLE IF NOT EXISTS gyms (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION,
    description TEXT,
    phone VARCHAR(50),
    website VARCHAR(255),
    opening_hours JSONB, -- 营业时间 {"monday": "06:00-22:00", ...}
    facilities JSONB, -- 设施 {"pool": true, "sauna": true, ...}
    images JSONB, -- 图片URL数组
    owner_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL, -- 健身房所有者
    is_verified BOOLEAN DEFAULT FALSE, -- 是否认证
    is_active BOOLEAN DEFAULT TRUE, -- 是否营业
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 健身房搭子申请表
CREATE TABLE IF NOT EXISTS gym_join_requests (
    id BIGSERIAL PRIMARY KEY,
    gym_id BIGINT NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(32) DEFAULT 'pending', -- pending/accepted/rejected/cancelled
    goal VARCHAR(100), -- 健身目标: 增肌/减脂/塑形/力量/有氧
    time_slot TIMESTAMP WITH TIME ZONE, -- 期望时间段
    duration_minutes INTEGER DEFAULT 60, -- 训练时长(分钟)
    experience_level VARCHAR(20) DEFAULT 'beginner', -- beginner/intermediate/advanced
    message TEXT, -- 附加消息
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(gym_id, user_id) -- 每个用户每个健身房只能有一个活跃申请
);

-- 3. 健身房折扣策略表
CREATE TABLE IF NOT EXISTS gym_discounts (
    id BIGSERIAL PRIMARY KEY,
    gym_id BIGINT NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    min_group_size INTEGER NOT NULL CHECK (min_group_size >= 2), -- 最少人数
    max_group_size INTEGER CHECK (max_group_size >= min_group_size), -- 最多人数(可选)
    discount_percent INTEGER NOT NULL CHECK (discount_percent > 0 AND discount_percent <= 100), -- 折扣百分比
    discount_type VARCHAR(20) DEFAULT 'percentage', -- percentage/fixed_amount
    discount_amount DECIMAL(10,2), -- 固定折扣金额(当type为fixed_amount时)
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(), -- 生效时间
    valid_until TIMESTAMP WITH TIME ZONE, -- 失效时间
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT, -- 折扣描述
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. 健身房搭子组队表(记录成功的组队)
CREATE TABLE IF NOT EXISTS gym_buddy_groups (
    id BIGSERIAL PRIMARY KEY,
    gym_id BIGINT NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    leader_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- 队长
    group_name VARCHAR(100), -- 组队名称
    goal VARCHAR(100), -- 共同目标
    scheduled_time TIMESTAMP WITH TIME ZONE, -- 约定时间
    duration_minutes INTEGER DEFAULT 60,
    max_members INTEGER DEFAULT 10,
    current_members INTEGER DEFAULT 1, -- 当前成员数
    status VARCHAR(20) DEFAULT 'active', -- active/completed/cancelled
    discount_applied_id BIGINT REFERENCES gym_discounts(id), -- 应用的折扣
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. 搭子组成员表
CREATE TABLE IF NOT EXISTS gym_buddy_members (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL REFERENCES gym_buddy_groups(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member', -- leader/member
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    left_at TIMESTAMP WITH TIME ZONE, -- 离开时间
    status VARCHAR(20) DEFAULT 'active', -- active/left/kicked
    UNIQUE(group_id, user_id)
);

-- 6. 健身房评价表
CREATE TABLE IF NOT EXISTS gym_reviews (
    id BIGSERIAL PRIMARY KEY,
    gym_id BIGINT NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5), -- 1-5星评价
    comment TEXT,
    facilities_rating INTEGER CHECK (facilities_rating >= 1 AND facilities_rating <= 5),
    service_rating INTEGER CHECK (service_rating >= 1 AND service_rating <= 5),
    environment_rating INTEGER CHECK (environment_rating >= 1 AND environment_rating <= 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(gym_id, user_id) -- 每个用户每个健身房只能评价一次
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_gyms_location ON gyms(lat, lng);
CREATE INDEX IF NOT EXISTS idx_gyms_owner ON gyms(owner_user_id);
CREATE INDEX IF NOT EXISTS idx_gyms_active ON gyms(is_active);
CREATE INDEX IF NOT EXISTS idx_gyms_verified ON gyms(is_verified);

CREATE INDEX IF NOT EXISTS idx_gym_join_requests_gym ON gym_join_requests(gym_id);
CREATE INDEX IF NOT EXISTS idx_gym_join_requests_user ON gym_join_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_gym_join_requests_status ON gym_join_requests(status);
CREATE INDEX IF NOT EXISTS idx_gym_join_requests_time ON gym_join_requests(time_slot);

CREATE INDEX IF NOT EXISTS idx_gym_discounts_gym ON gym_discounts(gym_id);
CREATE INDEX IF NOT EXISTS idx_gym_discounts_active ON gym_discounts(is_active);
CREATE INDEX IF NOT EXISTS idx_gym_discounts_valid ON gym_discounts(valid_from, valid_until);

CREATE INDEX IF NOT EXISTS idx_gym_buddy_groups_gym ON gym_buddy_groups(gym_id);
CREATE INDEX IF NOT EXISTS idx_gym_buddy_groups_leader ON gym_buddy_groups(leader_user_id);
CREATE INDEX IF NOT EXISTS idx_gym_buddy_groups_status ON gym_buddy_groups(status);
CREATE INDEX IF NOT EXISTS idx_gym_buddy_groups_time ON gym_buddy_groups(scheduled_time);

CREATE INDEX IF NOT EXISTS idx_gym_buddy_members_group ON gym_buddy_members(group_id);
CREATE INDEX IF NOT EXISTS idx_gym_buddy_members_user ON gym_buddy_members(user_id);
CREATE INDEX IF NOT EXISTS idx_gym_buddy_members_status ON gym_buddy_members(status);

CREATE INDEX IF NOT EXISTS idx_gym_reviews_gym ON gym_reviews(gym_id);
CREATE INDEX IF NOT EXISTS idx_gym_reviews_user ON gym_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_gym_reviews_rating ON gym_reviews(rating);

-- 创建视图：健身房当前搭子数量统计
CREATE OR REPLACE VIEW gym_buddy_stats AS
SELECT 
    g.id as gym_id,
    g.name as gym_name,
    COUNT(DISTINCT CASE WHEN gjr.status = 'accepted' THEN gjr.user_id END) as current_buddies_count,
    COUNT(DISTINCT CASE WHEN gjr.status = 'pending' THEN gjr.user_id END) as pending_requests_count,
    AVG(gr.rating) as average_rating,
    COUNT(gr.id) as review_count
FROM gyms g
LEFT JOIN gym_join_requests gjr ON g.id = gjr.gym_id
LEFT JOIN gym_reviews gr ON g.id = gr.gym_id
WHERE g.is_active = TRUE
GROUP BY g.id, g.name;

-- 创建触发器：自动更新updated_at字段
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_gyms_updated_at BEFORE UPDATE ON gyms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_gym_join_requests_updated_at BEFORE UPDATE ON gym_join_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_gym_discounts_updated_at BEFORE UPDATE ON gym_discounts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_gym_buddy_groups_updated_at BEFORE UPDATE ON gym_buddy_groups FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_gym_reviews_updated_at BEFORE UPDATE ON gym_reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 插入示例数据
INSERT INTO gyms (name, address, lat, lng, description, phone, opening_hours, facilities, is_verified, is_active) VALUES
('超级健身房(北京店)', '北京市朝阳区三里屯街道工体北路8号', 39.9042, 116.4074, '设备齐全的现代化健身房，提供专业教练指导', '010-12345678', '{"monday": "06:00-22:00", "tuesday": "06:00-22:00", "wednesday": "06:00-22:00", "thursday": "06:00-22:00", "friday": "06:00-22:00", "saturday": "08:00-20:00", "sunday": "08:00-20:00"}', '{"pool": true, "sauna": true, "yoga_room": true, "cardio_area": true, "weight_area": true}', true, true),
('健身达人(上海店)', '上海市浦东新区陆家嘴环路1000号', 31.2304, 121.4737, '24小时营业的智能健身房', '021-87654321', '{"monday": "00:00-23:59", "tuesday": "00:00-23:59", "wednesday": "00:00-23:59", "thursday": "00:00-23:59", "friday": "00:00-23:59", "saturday": "00:00-23:59", "sunday": "00:00-23:59"}', '{"cardio_area": true, "weight_area": true, "functional_area": true}', true, true),
('力量训练中心(深圳店)', '深圳市南山区科技园南区深南大道9999号', 22.5431, 114.0579, '专注力量训练的健身房', '0755-11111111', '{"monday": "05:00-23:00", "tuesday": "05:00-23:00", "wednesday": "05:00-23:00", "thursday": "05:00-23:00", "friday": "05:00-23:00", "saturday": "07:00-21:00", "sunday": "07:00-21:00"}', '{"weight_area": true, "powerlifting_area": true, "strongman_area": true}', true, true);

-- 插入示例折扣策略
INSERT INTO gym_discounts (gym_id, min_group_size, max_group_size, discount_percent, description) VALUES
(1, 2, 4, 10, '2-4人组队享受9折优惠'),
(1, 5, 8, 15, '5-8人组队享受85折优惠'),
(1, 9, 15, 20, '9-15人组队享受8折优惠'),
(2, 2, 5, 8, '2-5人组队享受92折优惠'),
(2, 6, 10, 12, '6-10人组队享受88折优惠'),
(3, 2, 3, 5, '2-3人组队享受95折优惠'),
(3, 4, 6, 10, '4-6人组队享受9折优惠');

-- 添加注释
COMMENT ON TABLE gyms IS '健身房信息表';
COMMENT ON TABLE gym_join_requests IS '健身房搭子申请表';
COMMENT ON TABLE gym_discounts IS '健身房折扣策略表';
COMMENT ON TABLE gym_buddy_groups IS '健身房搭子组队表';
COMMENT ON TABLE gym_buddy_members IS '搭子组成员表';
COMMENT ON TABLE gym_reviews IS '健身房评价表';
COMMENT ON VIEW gym_buddy_stats IS '健身房搭子统计视图';
