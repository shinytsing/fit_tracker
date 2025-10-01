-- FitTracker 消息模块数据库表设计
-- 包含聊天、消息、通知、群聊、媒体文件等表

-- 聊天表
CREATE TABLE chats (
    id VARCHAR(36) PRIMARY KEY,
    type ENUM('private', 'group') NOT NULL COMMENT '聊天类型',
    name VARCHAR(100) COMMENT '聊天名称（群聊）',
    description TEXT COMMENT '聊天描述',
    avatar VARCHAR(500) COMMENT '聊天头像',
    created_by VARCHAR(36) COMMENT '创建者ID',
    last_message_id VARCHAR(36) COMMENT '最后一条消息ID',
    last_message_at TIMESTAMP NULL COMMENT '最后消息时间',
    unread_count INT DEFAULT 0 COMMENT '未读消息数',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否活跃',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_type (type),
    INDEX idx_created_by (created_by),
    INDEX idx_last_message_at (last_message_at),
    INDEX idx_is_active (is_active),
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (last_message_id) REFERENCES messages(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='聊天表';

-- 聊天参与者表
CREATE TABLE chat_participants (
    id VARCHAR(36) PRIMARY KEY,
    chat_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    role ENUM('admin', 'member') DEFAULT 'member' COMMENT '角色',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP NULL COMMENT '离开时间',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否活跃',
    notification_enabled BOOLEAN DEFAULT TRUE COMMENT '是否开启通知',
    last_read_message_id VARCHAR(36) COMMENT '最后已读消息ID',
    last_read_at TIMESTAMP NULL COMMENT '最后已读时间',
    
    UNIQUE KEY uk_chat_user (chat_id, user_id),
    INDEX idx_chat_id (chat_id),
    INDEX idx_user_id (user_id),
    INDEX idx_is_active (is_active),
    FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (last_read_message_id) REFERENCES messages(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='聊天参与者表';

-- 消息表
CREATE TABLE messages (
    id VARCHAR(36) PRIMARY KEY,
    chat_id VARCHAR(36) NOT NULL,
    sender_id VARCHAR(36) NOT NULL,
    type ENUM('text', 'image', 'video', 'voice', 'file', 'location', 'contact', 'system') NOT NULL COMMENT '消息类型',
    content TEXT COMMENT '消息内容',
    media_url VARCHAR(500) COMMENT '媒体文件URL',
    thumbnail_url VARCHAR(500) COMMENT '缩略图URL',
    duration INT DEFAULT 0 COMMENT '时长（秒）',
    file_name VARCHAR(255) COMMENT '文件名',
    file_size BIGINT DEFAULT 0 COMMENT '文件大小（字节）',
    location_name VARCHAR(200) COMMENT '位置名称',
    location_address TEXT COMMENT '位置地址',
    latitude DECIMAL(10, 8) COMMENT '纬度',
    longitude DECIMAL(11, 8) COMMENT '经度',
    contact_name VARCHAR(100) COMMENT '联系人姓名',
    contact_phone VARCHAR(20) COMMENT '联系人电话',
    contact_avatar VARCHAR(500) COMMENT '联系人头像',
    reply_to_id VARCHAR(36) COMMENT '回复的消息ID',
    extra JSON COMMENT '额外数据',
    status ENUM('sending', 'sent', 'delivered', 'read', 'failed') DEFAULT 'sending' COMMENT '消息状态',
    is_deleted BOOLEAN DEFAULT FALSE COMMENT '是否已删除',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_chat_id (chat_id),
    INDEX idx_sender_id (sender_id),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_reply_to_id (reply_to_id),
    FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_to_id) REFERENCES messages(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息表';

-- 消息状态表
CREATE TABLE message_status (
    id VARCHAR(36) PRIMARY KEY,
    message_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    status ENUM('sent', 'delivered', 'read') NOT NULL COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_message_user (message_id, user_id),
    INDEX idx_message_id (message_id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息状态表';

-- 系统通知表
CREATE TABLE system_notifications (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    type ENUM('like', 'comment', 'follow', 'mention', 'system', 'challenge', 'message') NOT NULL COMMENT '通知类型',
    title VARCHAR(200) NOT NULL COMMENT '通知标题',
    content TEXT COMMENT '通知内容',
    data JSON COMMENT '通知数据',
    related_user_id VARCHAR(36) COMMENT '相关用户ID',
    related_post_id VARCHAR(36) COMMENT '相关动态ID',
    related_message_id VARCHAR(36) COMMENT '相关消息ID',
    is_read BOOLEAN DEFAULT FALSE COMMENT '是否已读',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL COMMENT '阅读时间',
    
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at),
    INDEX idx_related_user_id (related_user_id),
    INDEX idx_related_post_id (related_post_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (related_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (related_post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (related_message_id) REFERENCES messages(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统通知表';

-- 群聊表
CREATE TABLE groups (
    id VARCHAR(36) PRIMARY KEY,
    chat_id VARCHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT '群名称',
    description TEXT COMMENT '群描述',
    avatar VARCHAR(500) COMMENT '群头像',
    created_by VARCHAR(36) NOT NULL COMMENT '创建者ID',
    max_members INT DEFAULT 500 COMMENT '最大成员数',
    member_count INT DEFAULT 0 COMMENT '当前成员数',
    is_public BOOLEAN DEFAULT FALSE COMMENT '是否公开',
    invite_code VARCHAR(20) COMMENT '邀请码',
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active' COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_chat_id (chat_id),
    INDEX idx_created_by (created_by),
    INDEX idx_is_public (is_public),
    INDEX idx_status (status),
    INDEX idx_invite_code (invite_code),
    FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='群聊表';

-- 群成员表
CREATE TABLE group_members (
    id VARCHAR(36) PRIMARY KEY,
    group_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    role ENUM('owner', 'admin', 'member') DEFAULT 'member' COMMENT '角色',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP NULL COMMENT '离开时间',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否活跃',
    notification_enabled BOOLEAN DEFAULT TRUE COMMENT '是否开启通知',
    last_read_message_id VARCHAR(36) COMMENT '最后已读消息ID',
    last_read_at TIMESTAMP NULL COMMENT '最后已读时间',
    
    UNIQUE KEY uk_group_user (group_id, user_id),
    INDEX idx_group_id (group_id),
    INDEX idx_user_id (user_id),
    INDEX idx_role (role),
    INDEX idx_is_active (is_active),
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (last_read_message_id) REFERENCES messages(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='群成员表';

-- 媒体文件表
CREATE TABLE media_files (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    filename VARCHAR(255) NOT NULL COMMENT '文件名',
    original_filename VARCHAR(255) NOT NULL COMMENT '原始文件名',
    file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
    file_url VARCHAR(500) NOT NULL COMMENT '文件URL',
    file_type ENUM('image', 'video', 'audio', 'file') NOT NULL COMMENT '文件类型',
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

-- 消息统计表
CREATE TABLE message_stats (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    stat_date DATE NOT NULL COMMENT '统计日期',
    messages_sent INT DEFAULT 0 COMMENT '发送消息数',
    messages_received INT DEFAULT 0 COMMENT '接收消息数',
    chats_count INT DEFAULT 0 COMMENT '聊天数量',
    groups_count INT DEFAULT 0 COMMENT '群聊数量',
    notifications_received INT DEFAULT 0 COMMENT '收到通知数',
    notifications_read INT DEFAULT 0 COMMENT '已读通知数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_date (user_id, stat_date),
    INDEX idx_user_id (user_id),
    INDEX idx_stat_date (stat_date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息统计表';

-- 消息设置表
CREATE TABLE message_settings (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    allow_stranger_messages BOOLEAN DEFAULT FALSE COMMENT '允许陌生人私信',
    message_notification BOOLEAN DEFAULT TRUE COMMENT '消息通知',
    group_notification BOOLEAN DEFAULT TRUE COMMENT '群聊通知',
    system_notification BOOLEAN DEFAULT TRUE COMMENT '系统通知',
    voice_call_enabled BOOLEAN DEFAULT TRUE COMMENT '语音通话',
    video_call_enabled BOOLEAN DEFAULT TRUE COMMENT '视频通话',
    auto_download_media BOOLEAN DEFAULT TRUE COMMENT '自动下载媒体',
    data_saver_mode BOOLEAN DEFAULT FALSE COMMENT '省流量模式',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息设置表';

-- 通话记录表
CREATE TABLE call_records (
    id VARCHAR(36) PRIMARY KEY,
    caller_id VARCHAR(36) NOT NULL COMMENT '发起者ID',
    receiver_id VARCHAR(36) NOT NULL COMMENT '接收者ID',
    chat_id VARCHAR(36) COMMENT '聊天ID',
    call_type ENUM('voice', 'video') NOT NULL COMMENT '通话类型',
    status ENUM('calling', 'answered', 'rejected', 'missed', 'ended') NOT NULL COMMENT '通话状态',
    duration INT DEFAULT 0 COMMENT '通话时长（秒）',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL COMMENT '结束时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_caller_id (caller_id),
    INDEX idx_receiver_id (receiver_id),
    INDEX idx_chat_id (chat_id),
    INDEX idx_call_type (call_type),
    INDEX idx_status (status),
    INDEX idx_started_at (started_at),
    FOREIGN KEY (caller_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通话记录表';

-- 消息草稿表
CREATE TABLE message_drafts (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    chat_id VARCHAR(36) NOT NULL,
    content TEXT COMMENT '草稿内容',
    media_url VARCHAR(500) COMMENT '媒体文件URL',
    reply_to_id VARCHAR(36) COMMENT '回复的消息ID',
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_chat (user_id, chat_id),
    INDEX idx_user_id (user_id),
    INDEX idx_chat_id (chat_id),
    INDEX idx_last_modified (last_modified),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_to_id) REFERENCES messages(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息草稿表';

-- 插入默认消息设置数据
INSERT INTO message_settings (id, user_id, allow_stranger_messages, message_notification, group_notification, system_notification, voice_call_enabled, video_call_enabled, auto_download_media, data_saver_mode) 
SELECT 
    CONCAT('msg_setting_', u.id),
    u.id,
    FALSE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    FALSE
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM message_settings ms WHERE ms.user_id = u.id
);
