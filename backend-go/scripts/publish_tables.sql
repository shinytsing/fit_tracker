-- FitTracker 发布模块数据库表设计
-- 包含发布统计、定时发布、媒体文件、发布分析等表

-- 发布统计表
CREATE TABLE publish_stats (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    stat_date DATE NOT NULL COMMENT '统计日期',
    posts_count INT DEFAULT 0 COMMENT '发布动态数',
    checkins_count INT DEFAULT 0 COMMENT '打卡次数',
    workouts_count INT DEFAULT 0 COMMENT '训练记录数',
    nutrition_count INT DEFAULT 0 COMMENT '营养记录数',
    likes_received INT DEFAULT 0 COMMENT '收到点赞数',
    comments_received INT DEFAULT 0 COMMENT '收到评论数',
    shares_received INT DEFAULT 0 COMMENT '收到分享数',
    views_received INT DEFAULT 0 COMMENT '收到浏览数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_date (user_id, stat_date),
    INDEX idx_user_id (user_id),
    INDEX idx_stat_date (stat_date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='发布统计表';

-- 媒体文件表
CREATE TABLE media_files (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    filename VARCHAR(255) NOT NULL COMMENT '文件名',
    original_filename VARCHAR(255) NOT NULL COMMENT '原始文件名',
    file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
    file_url VARCHAR(500) NOT NULL COMMENT '文件URL',
    file_type ENUM('image', 'video', 'audio') NOT NULL COMMENT '文件类型',
    mime_type VARCHAR(100) NOT NULL COMMENT 'MIME类型',
    file_size BIGINT NOT NULL COMMENT '文件大小（字节）',
    width INT DEFAULT 0 COMMENT '宽度（图片/视频）',
    height INT DEFAULT 0 COMMENT '高度（图片/视频）',
    duration INT DEFAULT 0 COMMENT '时长（秒，视频/音频）',
    thumbnail_url VARCHAR(500) COMMENT '缩略图URL',
    status ENUM('uploading', 'processing', 'ready', 'failed') DEFAULT 'uploading' COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_file_type (file_type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='媒体文件表';

-- 定时发布表
CREATE TABLE scheduled_posts (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    content TEXT NOT NULL COMMENT '发布内容',
    media JSON COMMENT '媒体文件列表',
    topics JSON COMMENT '话题标签列表',
    location VARCHAR(200) COMMENT '位置信息',
    workout_data JSON COMMENT '训练记录数据',
    check_in_data JSON COMMENT '打卡数据',
    nutrition_data JSON COMMENT '营养数据',
    is_anonymous BOOLEAN DEFAULT FALSE COMMENT '是否匿名发布',
    visibility ENUM('public', 'friends', 'private') DEFAULT 'public' COMMENT '可见性',
    tags JSON COMMENT '标签列表',
    scheduled_at TIMESTAMP NOT NULL COMMENT '定时发布时间',
    status ENUM('pending', 'published', 'cancelled', 'failed') DEFAULT 'pending' COMMENT '状态',
    published_at TIMESTAMP NULL COMMENT '实际发布时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_scheduled_at (scheduled_at),
    INDEX idx_status (status),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='定时发布表';

-- 转发记录表
CREATE TABLE reposts (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL COMMENT '转发者ID',
    original_post_id VARCHAR(36) NOT NULL COMMENT '原动态ID',
    content TEXT COMMENT '转发时的附加内容',
    visibility ENUM('public', 'friends', 'private') DEFAULT 'public' COMMENT '可见性',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_original_post_id (original_post_id),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (original_post_id) REFERENCES posts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='转发记录表';

-- 发布分析表
CREATE TABLE publish_analytics (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    post_id VARCHAR(36) NOT NULL,
    post_type ENUM('text', 'image', 'video', 'workout', 'checkin', 'nutrition') NOT NULL COMMENT '动态类型',
    publish_date DATE NOT NULL COMMENT '发布日期',
    views_count INT DEFAULT 0 COMMENT '浏览数',
    likes_count INT DEFAULT 0 COMMENT '点赞数',
    comments_count INT DEFAULT 0 COMMENT '评论数',
    shares_count INT DEFAULT 0 COMMENT '分享数',
    engagement_rate DECIMAL(5,2) DEFAULT 0 COMMENT '互动率',
    reach_count INT DEFAULT 0 COMMENT '触达数',
    impression_count INT DEFAULT 0 COMMENT '曝光数',
    click_count INT DEFAULT 0 COMMENT '点击数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_post (user_id, post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_post_id (post_id),
    INDEX idx_post_type (post_type),
    INDEX idx_publish_date (publish_date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='发布分析表';

-- 发布模板表
CREATE TABLE publish_templates (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT '模板名称',
    description TEXT COMMENT '模板描述',
    template_type ENUM('text', 'image', 'video', 'workout', 'checkin', 'nutrition') NOT NULL COMMENT '模板类型',
    content TEXT COMMENT '模板内容',
    media JSON COMMENT '模板媒体',
    topics JSON COMMENT '模板话题',
    tags JSON COMMENT '模板标签',
    is_public BOOLEAN DEFAULT FALSE COMMENT '是否公开',
    usage_count INT DEFAULT 0 COMMENT '使用次数',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_template_type (template_type),
    INDEX idx_is_public (is_public),
    INDEX idx_is_active (is_active),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='发布模板表';

-- 发布草稿表
CREATE TABLE post_drafts (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    title VARCHAR(200) COMMENT '草稿标题',
    content TEXT COMMENT '草稿内容',
    media JSON COMMENT '草稿媒体',
    topics JSON COMMENT '草稿话题',
    location VARCHAR(200) COMMENT '位置信息',
    workout_data JSON COMMENT '训练数据',
    check_in_data JSON COMMENT '打卡数据',
    nutrition_data JSON COMMENT '营养数据',
    tags JSON COMMENT '标签',
    visibility ENUM('public', 'friends', 'private') DEFAULT 'public' COMMENT '可见性',
    is_anonymous BOOLEAN DEFAULT FALSE COMMENT '是否匿名',
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_last_modified (last_modified),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='发布草稿表';

-- 发布设置表
CREATE TABLE publish_settings (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    auto_add_location BOOLEAN DEFAULT FALSE COMMENT '自动添加位置',
    default_visibility ENUM('public', 'friends', 'private') DEFAULT 'public' COMMENT '默认可见性',
    auto_save_draft BOOLEAN DEFAULT TRUE COMMENT '自动保存草稿',
    draft_save_interval INT DEFAULT 30 COMMENT '草稿保存间隔（秒）',
    enable_scheduled_posts BOOLEAN DEFAULT TRUE COMMENT '启用定时发布',
    max_scheduled_posts INT DEFAULT 10 COMMENT '最大定时发布数',
    enable_analytics BOOLEAN DEFAULT TRUE COMMENT '启用分析统计',
    notification_settings JSON COMMENT '通知设置',
    privacy_settings JSON COMMENT '隐私设置',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='发布设置表';

-- 发布标签表
CREATE TABLE publish_tags (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE COMMENT '标签名称',
    description TEXT COMMENT '标签描述',
    color VARCHAR(7) DEFAULT '#007AFF' COMMENT '标签颜色',
    usage_count INT DEFAULT 0 COMMENT '使用次数',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_name (name),
    INDEX idx_usage_count (usage_count),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='发布标签表';

-- 用户标签关联表
CREATE TABLE user_publish_tags (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    tag_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_tag (user_id, tag_id),
    INDEX idx_user_id (user_id),
    INDEX idx_tag_id (tag_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES publish_tags(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户标签关联表';

-- 发布提醒表
CREATE TABLE publish_reminders (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    reminder_type ENUM('daily', 'weekly', 'custom') NOT NULL COMMENT '提醒类型',
    reminder_time TIME NOT NULL COMMENT '提醒时间',
    days_of_week JSON COMMENT '提醒星期（1-7）',
    message TEXT COMMENT '提醒消息',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    last_triggered TIMESTAMP NULL COMMENT '最后触发时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_is_active (is_active),
    INDEX idx_reminder_time (reminder_time),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='发布提醒表';

-- 插入默认发布标签数据
INSERT INTO publish_tags (id, name, description, color, usage_count) VALUES
('tag_001', '健身打卡', '健身相关动态', '#FF6B6B', 1250),
('tag_002', '减脂塑形', '减脂塑形相关', '#4ECDC4', 980),
('tag_003', '增肌增重', '增肌增重相关', '#45B7D1', 756),
('tag_004', '营养饮食', '营养饮食相关', '#96CEB4', 654),
('tag_005', '瑜伽冥想', '瑜伽冥想相关', '#FFEAA7', 432),
('tag_006', '跑步有氧', '跑步有氧相关', '#DDA0DD', 321),
('tag_007', '力量训练', '力量训练相关', '#98D8C8', 289),
('tag_008', '健身新手', '健身新手相关', '#F7DC6F', 198),
('tag_009', '日常分享', '日常生活分享', '#BB8FCE', 156),
('tag_010', '心情记录', '心情状态记录', '#85C1E9', 134);

-- 插入默认发布模板数据
INSERT INTO publish_templates (id, user_id, name, description, template_type, content, topics, is_public, usage_count) VALUES
('template_001', 'admin', '健身打卡模板', '标准的健身打卡模板', 'checkin', '今天完成了{workout_name}训练，感觉很棒！\n\n训练时长：{duration}分钟\n消耗卡路里：{calories}卡\n训练感受：{feeling}', '["健身打卡", "训练记录"]', TRUE, 500),
('template_002', 'admin', '减脂分享模板', '减脂经验分享模板', 'text', '分享我的减脂心得：\n\n1. 控制饮食，减少高热量食物\n2. 坚持有氧运动\n3. 保证充足睡眠\n4. 保持积极心态\n\n大家一起加油！', '["减脂塑形", "经验分享"]', TRUE, 300),
('template_003', 'admin', '营养记录模板', '营养饮食记录模板', 'nutrition', '今日营养记录：\n\n早餐：{breakfast}\n午餐：{lunch}\n晚餐：{dinner}\n\n总热量：{total_calories}卡\n蛋白质：{protein}g\n碳水化合物：{carbs}g\n脂肪：{fat}g', '["营养饮食", "健康生活"]', TRUE, 200);
