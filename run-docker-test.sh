#!/bin/bash

# Docker 构建和测试运行脚本

set -e

echo "========================================"
echo "  开发服务器初始化脚本 - Docker 验证"
echo "========================================"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查 Docker 是否运行
if ! docker info &> /dev/null; then
    echo "❌ Docker 服务未运行，请启动 Docker"
    exit 1
fi

echo "✅ Docker 环境检查通过"

# 构建测试镜像
echo
echo "构建测试镜像..."
docker build -t dev-server-test .

# 运行测试容器
echo
echo "运行测试容器..."
echo "注意: 测试过程可能需要几分钟时间"

# 创建测试容器并运行验证脚本
docker run --rm -v "$(pwd)/test-docker.sh:/home/testuser/test-docker.sh:ro" \
    dev-server-test bash -c "chmod +x /home/testuser/test-docker.sh && /home/testuser/test-docker.sh"

echo
echo "========================================"
echo "  Docker 验证完成"
echo "========================================"
