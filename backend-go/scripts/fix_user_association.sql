-- 修复用户关联问题的SQL脚本
-- 确保所有动态都有正确的用户关联

-- 1. 检查是否有用户ID为0的动态
SELECT COUNT(*) as invalid_posts FROM posts WHERE user_id = 0;

-- 2. 检查是否有用户ID不存在的动态
SELECT COUNT(*) as orphaned_posts 
FROM posts p 
LEFT JOIN users u ON p.user_id = u.id 
WHERE u.id IS NULL AND p.user_id != 0;

-- 3. 修复用户ID为0的动态（如果有的话）
-- 注意：这需要根据实际情况调整，可能需要删除或关联到默认用户
-- UPDATE posts SET user_id = 1 WHERE user_id = 0;

-- 4. 确保外键约束正确
-- ALTER TABLE posts ADD CONSTRAINT fk_posts_user_id FOREIGN KEY (user_id) REFERENCES users(id);

-- 5. 检查签到记录的用户关联
SELECT COUNT(*) as invalid_checkins FROM checkins WHERE user_id = 0;

-- 6. 修复签到记录的用户关联（如果有问题）
-- UPDATE checkins SET user_id = 1 WHERE user_id = 0;

-- 7. 确保所有表都有正确的用户关联
SELECT 
    'posts' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN user_id = 0 THEN 1 END) as invalid_user_ids
FROM posts
UNION ALL
SELECT 
    'checkins' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN user_id = 0 THEN 1 END) as invalid_user_ids
FROM checkins;
