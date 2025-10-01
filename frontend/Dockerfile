# FitTracker 前端 Dockerfile
FROM node:18-alpine AS build

# 设置工作目录
WORKDIR /app

# 复制package文件
COPY pubspec.yaml pubspec.lock ./

# 安装Flutter
RUN apk add --no-cache curl unzip && \
    curl -o flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.zip && \
    unzip flutter.zip && \
    mv flutter /opt/flutter && \
    rm flutter.zip

# 设置Flutter环境
ENV PATH="/opt/flutter/bin:${PATH}"

# 获取依赖
RUN flutter pub get

# 复制源代码
COPY . .

# 构建Web应用
RUN flutter build web --release

# 使用Nginx提供静态文件服务
FROM nginx:alpine

# 复制构建的文件
COPY --from=build /app/build/web /usr/share/nginx/html

# 复制Nginx配置
COPY nginx.conf /etc/nginx/nginx.conf

# 暴露端口
EXPOSE 80

# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]