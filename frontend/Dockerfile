# Flutter 前端 Dockerfile
FROM ubuntu:22.04

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# 安装 Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# 验证 Flutter 安装
RUN flutter doctor

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 获取依赖
RUN flutter pub get

# 构建应用
RUN flutter build apk --release

# 暴露端口（如果需要 web 版本）
EXPOSE 8080

# 启动命令
CMD ["flutter", "run", "--web-port", "8080", "--web-hostname", "0.0.0.0"]
