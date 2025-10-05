-- 修复 UserSettings 表结构
-- 创建时间: 2025-01-03
-- 描述: 修复 UserSettings 表的字段类型和约束

-- 添加 deleted_at 字段（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_settings' AND column_name = 'deleted_at') THEN
        ALTER TABLE user_settings ADD COLUMN deleted_at TIMESTAMP NULL;
        CREATE INDEX idx_user_settings_deleted_at ON user_settings(deleted_at);
    END IF;
END $$;

-- 确保主键约束正确
DO $$
BEGIN
    -- 检查是否存在主键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE table_name = 'user_settings' AND constraint_type = 'PRIMARY KEY') THEN
        ALTER TABLE user_settings ADD CONSTRAINT user_settings_pkey PRIMARY KEY (id);
    END IF;
END $$;

-- 确保外键约束正确
DO $$
BEGIN
    -- 检查是否存在外键
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE table_name = 'user_settings' 
                   AND constraint_name = 'user_settings_user_id_fkey') THEN
        ALTER TABLE user_settings ADD CONSTRAINT user_settings_user_id_fkey 
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
    END IF;
END $$;

-- 确保唯一索引正确
DO $$
BEGIN
    -- 检查是否存在唯一索引
    IF NOT EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE tablename = 'user_settings' AND indexname = 'user_settings_user_id_key') THEN
        CREATE UNIQUE INDEX user_settings_user_id_key ON user_settings(user_id);
    END IF;
END $$;
