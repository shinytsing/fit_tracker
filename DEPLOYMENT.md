# FitTracker 部署指南

## 部署方式

### 1. Docker 部署（推荐）

#### 生产环境部署
```bash
# 1. 克隆项目
git clone <repository-url>
cd fittracker

# 2. 配置环境变量
cd backend-go
cp env.example .env
# 编辑 .env 文件，配置生产环境参数

# 3. 启动服务
docker-compose up -d

# 4. 查看服务状态
docker-compose ps
docker-compose logs -f
```

#### 测试环境部署
```bash
# 启动测试环境
docker-compose -f docker-compose.test.yml up -d

# 查看测试环境状态
docker-compose -f docker-compose.test.yml ps
```

### 2. 手动部署

#### 服务器要求
- Ubuntu 20.04+ / CentOS 7+
- 内存: 最低 2GB，推荐 4GB+
- 存储: 最低 20GB，推荐 50GB+
- CPU: 最低 2 核

#### 安装依赖
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装基础工具
sudo apt install -y curl wget git build-essential

# 安装 PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# 安装 Redis
sudo apt install -y redis-server

# 安装 Nginx
sudo apt install -y nginx

# 安装 Go
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 配置数据库
```bash
# 切换到 postgres 用户
sudo -u postgres psql

# 创建数据库和用户
CREATE DATABASE fittracker;
CREATE USER fittracker WITH PASSWORD 'fittracker123';
GRANT ALL PRIVILEGES ON DATABASE fittracker TO fittracker;
\q

# 初始化数据库
sudo -u postgres psql -d fittracker -f /path/to/backend-go/scripts/init.sql
```

#### 配置 Redis
```bash
# 编辑 Redis 配置
sudo nano /etc/redis/redis.conf

# 设置密码（可选）
requirepass your_redis_password

# 重启 Redis
sudo systemctl restart redis-server
sudo systemctl enable redis-server
```

#### 配置 Nginx
```bash
# 创建 Nginx 配置
sudo nano /etc/nginx/sites-available/fittracker

# 配置内容
server {
    listen 80;
    server_name your-domain.com;

    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        root /var/www/fittracker/frontend/build/web;
        try_files $uri $uri/ /index.html;
    }
}

# 启用站点
sudo ln -s /etc/nginx/sites-available/fittracker /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 部署应用
```bash
# 创建应用目录
sudo mkdir -p /opt/fittracker
sudo chown $USER:$USER /opt/fittracker

# 克隆项目
cd /opt/fittracker
git clone <repository-url> .

# 构建后端
cd backend-go
go mod download
go build -o fittracker-backend cmd/server/main.go

# 创建 systemd 服务
sudo nano /etc/systemd/system/fittracker-backend.service

# 服务配置
[Unit]
Description=FitTracker Backend Service
After=network.target postgresql.service redis.service

[Service]
Type=simple
User=fittracker
WorkingDirectory=/opt/fittracker/backend-go
ExecStart=/opt/fittracker/backend-go/fittracker-backend
Restart=always
RestartSec=5
Environment=ENVIRONMENT=production
Environment=DB_HOST=localhost
Environment=DB_PORT=5432
Environment=DB_USER=fittracker
Environment=DB_PASSWORD=fittracker123
Environment=DB_NAME=fittracker
Environment=REDIS_HOST=localhost
Environment=REDIS_PORT=6379
Environment=JWT_SECRET=your-production-secret-key

[Install]
WantedBy=multi-user.target

# 启动服务
sudo systemctl daemon-reload
sudo systemctl enable fittracker-backend
sudo systemctl start fittracker-backend
sudo systemctl status fittracker-backend
```

### 3. Kubernetes 部署

#### 创建命名空间
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: fittracker
```

#### 部署 PostgreSQL
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: fittracker
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        env:
        - name: POSTGRES_DB
          value: fittracker
        - name: POSTGRES_USER
          value: fittracker
        - name: POSTGRES_PASSWORD
          value: fittracker123
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: fittracker
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

#### 部署 Redis
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: fittracker
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis
  namespace: fittracker
spec:
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
```

#### 部署后端服务
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fittracker-backend
  namespace: fittracker
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fittracker-backend
  template:
    metadata:
      labels:
        app: fittracker-backend
    spec:
      containers:
      - name: fittracker-backend
        image: fittracker/backend:latest
        ports:
        - containerPort: 8080
        env:
        - name: ENVIRONMENT
          value: production
        - name: DB_HOST
          value: postgres
        - name: DB_PORT
          value: "5432"
        - name: DB_USER
          value: fittracker
        - name: DB_PASSWORD
          value: fittracker123
        - name: DB_NAME
          value: fittracker
        - name: REDIS_HOST
          value: redis
        - name: REDIS_PORT
          value: "6379"
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: fittracker-secrets
              key: jwt-secret
---
apiVersion: v1
kind: Service
metadata:
  name: fittracker-backend
  namespace: fittracker
spec:
  selector:
    app: fittracker-backend
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

## 环境变量配置

### 生产环境变量
```bash
# 应用配置
ENVIRONMENT=production
PORT=8080
HOST=0.0.0.0

# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_USER=fittracker
DB_PASSWORD=fittracker123
DB_NAME=fittracker
DB_SSLMODE=require

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password
REDIS_DB=0

# JWT配置
JWT_SECRET=your-production-secret-key-$(openssl rand -hex 32)
JWT_EXPIRES_IN=24

# AI服务配置
TENCENT_SECRET_ID=your_tencent_secret_id
TENCENT_SECRET_KEY=your_tencent_secret_key
DEEPSEEK_API_KEY=your_deepseek_api_key
GROQ_API_KEY=your_groq_api_key
```

## SSL 证书配置

### Let's Encrypt 证书
```bash
# 安装 Certbot
sudo apt install -y certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com

# 自动续期
sudo crontab -e
# 添加以下行
0 12 * * * /usr/bin/certbot renew --quiet
```

### 自签名证书
```bash
# 生成私钥
openssl genrsa -out fittracker.key 2048

# 生成证书签名请求
openssl req -new -key fittracker.key -out fittracker.csr

# 生成自签名证书
openssl x509 -req -days 365 -in fittracker.csr -signkey fittracker.key -out fittracker.crt

# 配置 Nginx SSL
sudo nano /etc/nginx/sites-available/fittracker

# 添加 SSL 配置
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/fittracker.crt;
    ssl_certificate_key /path/to/fittracker.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# HTTP 重定向到 HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

## 监控和日志

### 系统监控
```bash
# 安装监控工具
sudo apt install -y htop iotop nethogs

# 查看系统资源
htop
iotop
nethogs

# 查看服务状态
systemctl status fittracker-backend
systemctl status postgresql
systemctl status redis-server
systemctl status nginx
```

### 应用日志
```bash
# 查看应用日志
journalctl -u fittracker-backend -f

# 查看 Nginx 日志
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# 查看数据库日志
sudo tail -f /var/log/postgresql/postgresql-15-main.log

# 查看 Redis 日志
sudo tail -f /var/log/redis/redis-server.log
```

### 性能监控
```bash
# 安装 Prometheus 和 Grafana
docker run -d --name prometheus -p 9090:9090 prom/prometheus
docker run -d --name grafana -p 3000:3000 grafana/grafana

# 配置监控指标
# 在应用中添加 Prometheus 指标端点
```

## 备份和恢复

### 数据库备份
```bash
# 创建备份脚本
sudo nano /opt/scripts/backup-db.sh

#!/bin/bash
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/fittracker_$DATE.sql"

mkdir -p $BACKUP_DIR
pg_dump -h localhost -U fittracker fittracker > $BACKUP_FILE
gzip $BACKUP_FILE

# 删除7天前的备份
find $BACKUP_DIR -name "fittracker_*.sql.gz" -mtime +7 -delete

# 设置定时任务
sudo crontab -e
# 添加以下行
0 2 * * * /opt/scripts/backup-db.sh
```

### 应用备份
```bash
# 创建应用备份脚本
sudo nano /opt/scripts/backup-app.sh

#!/bin/bash
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/fittracker-app_$DATE.tar.gz"

mkdir -p $BACKUP_DIR
tar -czf $BACKUP_FILE /opt/fittracker

# 删除30天前的备份
find $BACKUP_DIR -name "fittracker-app_*.tar.gz" -mtime +30 -delete
```

## 故障排除

### 常见问题

1. **服务启动失败**
```bash
# 检查服务状态
systemctl status fittracker-backend

# 查看详细日志
journalctl -u fittracker-backend -n 50

# 检查端口占用
netstat -tlnp | grep :8080
```

2. **数据库连接失败**
```bash
# 检查 PostgreSQL 状态
systemctl status postgresql

# 测试数据库连接
psql -h localhost -U fittracker -d fittracker

# 检查数据库日志
sudo tail -f /var/log/postgresql/postgresql-15-main.log
```

3. **Redis 连接失败**
```bash
# 检查 Redis 状态
systemctl status redis-server

# 测试 Redis 连接
redis-cli ping

# 检查 Redis 日志
sudo tail -f /var/log/redis/redis-server.log
```

4. **Nginx 配置错误**
```bash
# 测试 Nginx 配置
sudo nginx -t

# 重新加载配置
sudo systemctl reload nginx

# 查看 Nginx 错误日志
sudo tail -f /var/log/nginx/error.log
```

### 性能优化

1. **数据库优化**
```sql
-- 创建索引
CREATE INDEX CONCURRENTLY idx_posts_created_at ON posts(created_at);
CREATE INDEX CONCURRENTLY idx_users_username ON users(username);

-- 分析表统计信息
ANALYZE posts;
ANALYZE users;
```

2. **Redis 优化**
```bash
# 编辑 Redis 配置
sudo nano /etc/redis/redis.conf

# 优化内存使用
maxmemory 512mb
maxmemory-policy allkeys-lru

# 启用持久化
save 900 1
save 300 10
save 60 10000
```

3. **Nginx 优化**
```bash
# 编辑 Nginx 配置
sudo nano /etc/nginx/nginx.conf

# 优化工作进程
worker_processes auto;
worker_connections 1024;

# 启用 Gzip 压缩
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
```

## 安全加固

### 防火墙配置
```bash
# 安装 UFW
sudo apt install -y ufw

# 配置防火墙规则
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 数据库安全
```sql
-- 创建只读用户
CREATE USER fittracker_readonly WITH PASSWORD 'readonly_password';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO fittracker_readonly;

-- 限制连接数
ALTER USER fittracker CONNECTION LIMIT 50;
```

### 应用安全
```bash
# 设置文件权限
sudo chown -R fittracker:fittracker /opt/fittracker
sudo chmod -R 755 /opt/fittracker

# 限制服务用户权限
sudo useradd -r -s /bin/false fittracker
```

---

*最后更新: 2024年12月29日*