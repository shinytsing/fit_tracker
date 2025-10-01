-- FitTracker 社区模块数据库表设计
-- 包含动态、评论、点赞、关注、话题、挑战等表

-- 动态表
CREATE TABLE posts (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    content TEXT NOT NULL COMMENT '动态内容',
    media JSON COMMENT '媒体文件列表',
    topics JSON COMMENT '话题标签列表',
    location VARCHAR(200) COMMENT '位置信息',
    workout_data JSON COMMENT '训练记录数据',
    check_in_data JSON COMMENT '打卡数据',
    is_anonymous BOOLEAN DEFAULT FALSE COMMENT '是否匿名发布',
    visibility ENUM('public', 'friends', 'private') DEFAULT 'public' COMMENT '可见性',
    tags JSON COMMENT '标签列表',
    status ENUM('draft', 'published', 'deleted', 'hidden') DEFAULT 'published' COMMENT '状态',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    comment_count INT DEFAULT 0 COMMENT '评论数',
    share_count INT DEFAULT 0 COMMENT '分享数',
    view_count INT DEFAULT 0 COMMENT '浏览数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_visibility (visibility),
    INDEX idx_created_at (created_at),
    INDEX idx_topics ((CAST(topics AS CHAR(255) ARRAY))),
    FULLTEXT idx_content (content),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态表';

-- 评论表
CREATE TABLE comments (
    id VARCHAR(36) PRIMARY KEY,
    post_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    content TEXT NOT NULL COMMENT '评论内容',
    parent_id VARCHAR(36) COMMENT '父评论ID（回复评论）',
    reply_to_id VARCHAR(36) COMMENT '回复的用户ID',
    status ENUM('published', 'deleted', 'hidden') DEFAULT 'published' COMMENT '状态',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    reply_count INT DEFAULT 0 COMMENT '回复数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_parent_id (parent_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_to_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- 动态点赞表
CREATE TABLE post_likes (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    post_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_post (user_id, post_id),
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态点赞表';

-- 评论点赞表
CREATE TABLE comment_likes (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    comment_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_comment (user_id, comment_id),
    INDEX idx_comment_id (comment_id),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论点赞表';

-- 动态收藏表
CREATE TABLE post_favorites (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    post_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_post (user_id, post_id),
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态收藏表';

-- 动态分享表
CREATE TABLE post_shares (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    post_id VARCHAR(36) NOT NULL,
    platform VARCHAR(50) NOT NULL COMMENT '分享平台',
    message TEXT COMMENT '分享时的附加消息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_platform (platform),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='动态分享表';

-- 用户关注表
CREATE TABLE user_follows (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL COMMENT '关注者ID',
    target_user_id VARCHAR(36) NOT NULL COMMENT '被关注者ID',
    status ENUM('active', 'inactive') DEFAULT 'active' COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_target (user_id, target_user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_target_user_id (target_user_id),
    INDEX idx_status (status),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户关注表';

-- 用户屏蔽表
CREATE TABLE user_blocks (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL COMMENT '屏蔽者ID',
    target_user_id VARCHAR(36) NOT NULL COMMENT '被屏蔽者ID',
    reason VARCHAR(200) COMMENT '屏蔽原因',
    status ENUM('active', 'inactive') DEFAULT 'active' COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_target (user_id, target_user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_target_user_id (target_user_id),
    INDEX idx_status (status),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户屏蔽表';

-- 话题表
CREATE TABLE topics (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE COMMENT '话题名称',
    description TEXT COMMENT '话题描述',
    post_count INT DEFAULT 0 COMMENT '动态数量',
    follower_count INT DEFAULT 0 COMMENT '关注者数量',
    trend DECIMAL(5,2) DEFAULT 0 COMMENT '热度趋势',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_name (name),
    INDEX idx_post_count (post_count),
    INDEX idx_trend (trend),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='话题表';

-- 话题关注表
CREATE TABLE topic_follows (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    topic_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_topic (user_id, topic_id),
    INDEX idx_user_id (user_id),
    INDEX idx_topic_id (topic_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='话题关注表';

-- 挑战表
CREATE TABLE challenges (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '挑战名称',
    description TEXT COMMENT '挑战描述',
    category VARCHAR(50) NOT NULL COMMENT '挑战分类',
    difficulty ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner' COMMENT '难度等级',
    duration INT NOT NULL COMMENT '挑战时长（天）',
    start_date DATE NOT NULL COMMENT '开始日期',
    end_date DATE NOT NULL COMMENT '结束日期',
    max_participants INT DEFAULT 0 COMMENT '最大参与人数（0表示无限制）',
    current_participants INT DEFAULT 0 COMMENT '当前参与人数',
    rules TEXT COMMENT '挑战规则',
    rewards JSON COMMENT '奖励设置',
    cover_image VARCHAR(500) COMMENT '封面图片',
    status ENUM('upcoming', 'active', 'completed', 'cancelled') DEFAULT 'upcoming' COMMENT '状态',
    created_by VARCHAR(36) NOT NULL COMMENT '创建者ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_difficulty (difficulty),
    INDEX idx_status (status),
    INDEX idx_start_date (start_date),
    INDEX idx_end_date (end_date),
    INDEX idx_created_by (created_by),
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='挑战表';

-- 挑战参与表
CREATE TABLE challenge_participants (
    id VARCHAR(36) PRIMARY KEY,
    challenge_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL COMMENT '完成时间',
    progress INT DEFAULT 0 COMMENT '完成进度（百分比）',
    status ENUM('active', 'completed', 'dropped') DEFAULT 'active' COMMENT '参与状态',
    notes TEXT COMMENT '参与备注',
    
    UNIQUE KEY uk_challenge_user (challenge_id, user_id),
    INDEX idx_challenge_id (challenge_id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='挑战参与表';

-- 举报表
CREATE TABLE reports (
    id VARCHAR(36) PRIMARY KEY,
    reporter_id VARCHAR(36) NOT NULL COMMENT '举报者ID',
    target_type ENUM('post', 'comment', 'user') NOT NULL COMMENT '举报对象类型',
    target_id VARCHAR(36) NOT NULL COMMENT '举报对象ID',
    reason VARCHAR(100) NOT NULL COMMENT '举报原因',
    description TEXT COMMENT '举报描述',
    evidence JSON COMMENT '举报证据（图片等）',
    status ENUM('pending', 'processing', 'resolved', 'rejected') DEFAULT 'pending' COMMENT '处理状态',
    handled_by VARCHAR(36) COMMENT '处理人ID',
    handled_at TIMESTAMP NULL COMMENT '处理时间',
    result TEXT COMMENT '处理结果',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_reporter_id (reporter_id),
    INDEX idx_target_type (target_type),
    INDEX idx_target_id (target_id),
    INDEX idx_status (status),
    INDEX idx_handled_by (handled_by),
    FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (handled_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='举报表';

-- 通知表
CREATE TABLE notifications (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL COMMENT '接收者ID',
    type ENUM('like', 'comment', 'follow', 'mention', 'system', 'challenge') NOT NULL COMMENT '通知类型',
    title VARCHAR(200) NOT NULL COMMENT '通知标题',
    content TEXT COMMENT '通知内容',
    data JSON COMMENT '通知数据',
    is_read BOOLEAN DEFAULT FALSE COMMENT '是否已读',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL COMMENT '阅读时间',
    
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知表';

-- 用户统计表
CREATE TABLE user_stats (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    followers_count INT DEFAULT 0 COMMENT '粉丝数',
    following_count INT DEFAULT 0 COMMENT '关注数',
    posts_count INT DEFAULT 0 COMMENT '动态数',
    likes_received INT DEFAULT 0 COMMENT '收到点赞数',
    comments_received INT DEFAULT 0 COMMENT '收到评论数',
    challenges_completed INT DEFAULT 0 COMMENT '完成挑战数',
    level INT DEFAULT 1 COMMENT '用户等级',
    experience INT DEFAULT 0 COMMENT '经验值',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_id (user_id),
    INDEX idx_followers_count (followers_count),
    INDEX idx_posts_count (posts_count),
    INDEX idx_level (level),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户统计表';

-- 插入默认话题数据
INSERT INTO topics (id, name, description, post_count, trend) VALUES
('topic_001', '健身打卡', '分享你的健身日常', 1250, 15.5),
('topic_002', '减脂塑形', '减脂塑形经验分享', 980, 12.3),
('topic_003', '增肌增重', '增肌增重心得交流', 756, 9.8),
('topic_004', '营养饮食', '健康饮食搭配', 654, 8.2),
('topic_005', '瑜伽冥想', '瑜伽冥想修身养性', 432, 6.5),
('topic_006', '跑步有氧', '跑步有氧运动', 321, 5.1),
('topic_007', '力量训练', '力量训练技巧', 289, 4.8),
('topic_008', '健身新手', '健身新手入门', 198, 3.2);

-- 插入默认挑战数据
INSERT INTO challenges (id, name, description, category, difficulty, duration, start_date, end_date, max_participants, rules, rewards, status, created_by) VALUES
('challenge_001', '30天深蹲挑战', '每天完成100个深蹲，坚持30天', '力量挑战', 'intermediate', 30, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 1000, '每天完成100个深蹲，可以分组完成', '{"points": 500, "badge": "squat_master"}', 'active', 'admin'),
('challenge_002', '21天平板支撑挑战', '每天平板支撑，从30秒开始逐步增加', '核心挑战', 'beginner', 21, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 21 DAY), 500, '每天平板支撑，时间逐步增加', '{"points": 300, "badge": "core_warrior"}', 'active', 'admin'),
('challenge_003', '7天早起运动挑战', '连续7天早起进行运动', '习惯挑战', 'beginner', 7, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 200, '每天6点前起床并完成30分钟运动', '{"points": 200, "badge": "early_bird"}', 'active', 'admin'),
('challenge_004', '100天跑步挑战', '100天内累计跑步100公里', '有氧挑战', 'advanced', 100, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 100 DAY), 2000, '100天内累计跑步100公里，可以分多次完成', '{"points": 1000, "badge": "marathon_runner"}', 'active', 'admin');
