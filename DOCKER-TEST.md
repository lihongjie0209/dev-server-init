# Docker 测试指南

这个目录包含了用于验证开发服务器初始化脚本的 Docker 测试环境。

## 测试文件说明

- `Dockerfile` - Ubuntu 22.04 测试环境镜像定义
- `docker-compose.yml` - Docker Compose 配置文件
- `test-docker.sh` - 自动化测试脚本
- `run-docker-test.sh` - 一键运行测试脚本

## 快速测试

### 方法 1: 使用提供的测试脚本

```bash
# 添加执行权限
chmod +x run-docker-test.sh

# 运行测试
./run-docker-test.sh
```

### 方法 2: 使用 Docker Compose (推荐)

```bash
# 自动化测试
docker-compose up dev-server-test

# 交互式测试 (手动运行脚本)
docker-compose up -d dev-server-interactive
docker exec -it dev-server-interactive bash
# 在容器内运行: ./init-dev-server.sh
```

### 方法 3: 手动 Docker 命令

```bash
# 构建镜像
docker build -t dev-server-test .

# 运行自动化测试
docker run --rm -v "$(pwd)/test-docker.sh:/home/testuser/test-docker.sh:ro" \
    dev-server-test bash -c "chmod +x /home/testuser/test-docker.sh && /home/testuser/test-docker.sh"

# 运行交互式测试
docker run -it --rm dev-server-test bash
```

## 测试内容

自动化测试脚本 (`test-docker.sh`) 会验证以下内容：

### 🛠️ 工具安装验证
- **基础工具**: git, curl, wget, htop, tmux, vim
- **Rust 环境**: rustc, cargo
- **Python 工具**: uv
- **Node.js 环境**: node, npm, yarn, pnpm, pm2
- **Java 环境**: java, javac, maven

### 🔧 配置验证
- Git 用户配置
- JAVA_HOME 环境变量
- tmux 配置文件
- Maven 配置文件
- 开发目录结构

### 📊 测试输出
测试脚本会显示：
- 每个工具的安装状态和版本
- 配置文件是否正确创建
- 环境变量是否正确设置
- 最终的成功率统计

## 测试场景

### 自动化测试 (test-docker.sh)
- 使用预设输入自动完成所有安装选项
- Git: 使用默认用户名和邮箱
- JDK: 自动选择 OpenJDK 17
- Maven: 自动选择安装

### 交互式测试
- 手动运行脚本，可以测试不同的选择组合
- 验证用户交互界面
- 测试错误处理和边界情况

## 故障排除

### 常见问题

1. **Docker 权限问题**
   ```bash
   # Linux 用户可能需要添加到 docker 组
   sudo usermod -aG docker $USER
   # 重新登录后生效
   ```

2. **网络超时**
   ```bash
   # 如果下载超时，可以设置更长的超时时间
   docker build --build-arg HTTP_TIMEOUT=300 -t dev-server-test .
   ```

3. **磁盘空间不足**
   ```bash
   # 清理不需要的 Docker 镜像
   docker system prune -a
   ```

### 调试测试

如果测试失败，可以使用交互式模式进行调试：

```bash
# 启动交互式容器
docker run -it --rm dev-server-test bash

# 在容器内手动运行脚本的各个部分
./init-dev-server.sh

# 检查日志和状态
echo $JAVA_HOME
ls -la ~/.m2/
cat ~/.gitconfig
```

## 测试环境规格

- **操作系统**: Ubuntu 22.04 LTS
- **用户**: 非 root 用户 (testuser)
- **权限**: sudo 权限（无密码）
- **网络**: 需要互联网连接下载软件包
- **资源**: 建议至少 2GB RAM，10GB 磁盘空间

## 自定义测试

您可以修改 `test-docker.sh` 来自定义测试行为：

1. **修改安装选项**: 编辑 `/tmp/test_inputs` 部分
2. **添加验证**: 在验证部分添加新的检查
3. **修改超时**: 调整 `timeout` 值

## CI/CD 集成

这些测试脚本可以集成到 CI/CD 流水线中：

```yaml
# GitHub Actions 示例
- name: Test with Docker
  run: |
    chmod +x run-docker-test.sh
    ./run-docker-test.sh
```
