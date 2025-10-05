-- FitTracker 数据库初始化脚本
-- 注意：数据库和用户已由 Docker Compose 创建，这里只需要授权

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