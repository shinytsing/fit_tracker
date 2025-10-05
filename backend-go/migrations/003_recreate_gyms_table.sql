-- 重新创建gyms表，使用自增ID
DROP TABLE IF EXISTS gyms CASCADE;

CREATE TABLE gyms (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    name VARCHAR(255) NOT NULL,
    address TEXT,
    latitude NUMERIC(10,8),
    longitude NUMERIC(11,8),
    description TEXT,
    phone VARCHAR(50),
    website VARCHAR(255),
    opening_hours TEXT DEFAULT '',
    facilities TEXT DEFAULT '',
    images TEXT DEFAULT '',
    owner_user_id VARCHAR(255),
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE
);

-- 创建索引
CREATE INDEX idx_gyms_name ON gyms(name);
CREATE INDEX idx_gyms_location ON gyms(latitude, longitude);
CREATE INDEX idx_gyms_owner ON gyms(owner_user_id);
CREATE INDEX idx_gyms_active ON gyms(is_active);
