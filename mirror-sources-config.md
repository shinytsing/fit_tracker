# 国内镜像源配置

## npm 镜像源
```bash
# 设置淘宝镜像
npm config set registry https://registry.npmmirror.com

# 或者使用cnpm
npm install -g cnpm --registry=https://registry.npmmirror.com
```

## yarn 镜像源
```bash
# 设置淘宝镜像
yarn config set registry https://registry.npmmirror.com

# 或者使用yrm管理镜像源
npm install -g yrm
yrm use taobao
```

## pnpm 镜像源
```bash
# 设置淘宝镜像
pnpm config set registry https://registry.npmmirror.com
```

## Git 镜像源
```bash
# GitHub 镜像
git config --global url."https://github.com.cnpmjs.org/".insteadOf "https://github.com/"

# 或者使用其他镜像
git config --global url."https://hub.fastgit.xyz/".insteadOf "https://github.com/"
```

## Docker 镜像源
```bash
# 创建或编辑 Docker daemon 配置文件
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
EOF

# 重启 Docker 服务
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## Python pip 镜像源
```bash
# 临时使用
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple package_name

# 永久配置
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

## Maven 镜像源
在 `~/.m2/settings.xml` 中添加：
```xml
<mirrors>
  <mirror>
    <id>aliyunmaven</id>
    <mirrorOf>*</mirrorOf>
    <name>阿里云公共仓库</name>
    <url>https://maven.aliyun.com/repository/public</url>
  </mirror>
</mirrors>
```

## Gradle 镜像源
在 `~/.gradle/init.gradle` 中添加：
```gradle
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/public' }
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        mavenCentral()
    }
}
```

## 常用镜像源地址

### npm 镜像源
- 淘宝镜像：https://registry.npmmirror.com
- 腾讯镜像：https://mirrors.cloud.tencent.com/npm/
- 华为镜像：https://repo.huaweicloud.com/repository/npm/

### GitHub 镜像源
- GitHub 镜像：https://github.com.cnpmjs.org/
- FastGit：https://hub.fastgit.xyz/
- GitClone：https://gitclone.com/

### Docker 镜像源
- 中科大镜像：https://docker.mirrors.ustc.edu.cn
- 网易镜像：https://hub-mirror.c.163.com
- 百度镜像：https://mirror.baidubce.com

### Python pip 镜像源
- 清华大学：https://pypi.tuna.tsinghua.edu.cn/simple
- 阿里云：https://mirrors.aliyun.com/pypi/simple/
- 中科大：https://pypi.mirrors.ustc.edu.cn/simple/

## 验证配置
```bash
# 验证 npm 配置
npm config get registry

# 验证 yarn 配置
yarn config get registry

# 验证 pnpm 配置
pnpm config get registry

# 验证 Git 配置
git config --global --get url."https://github.com.cnpmjs.org/".insteadOf
```
