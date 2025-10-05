# FitTracker 后端 Dockerfile
FROM golang:1.23-alpine AS build

# 设置工作目录
WORKDIR /app

# 安装依赖
RUN apk add --no-cache git

# 复制go mod文件
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server cmd/server/main.go

# 使用Alpine作为运行时
FROM alpine:latest

# 安装ca证书
RUN apk --no-cache add ca-certificates

# 设置工作目录
WORKDIR /root/

# 复制构建的二进制文件
COPY --from=build /app/server .

# 复制配置文件
COPY --from=build /app/.env .

# 暴露端口
EXPOSE 8080

# 运行应用
CMD ["./server"]