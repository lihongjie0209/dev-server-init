#!/bin/bash

# 快速安装脚本
# 直接从 GitHub 下载并运行开发服务器初始化脚本

set -e

echo "========================================"
echo "  开发服务器快速初始化"
echo "========================================"

# 检查系统
if ! command -v curl &> /dev/null; then
    echo "错误: 需要安装 curl"
    echo "请先运行: sudo apt update && sudo apt install -y curl"
    exit 1
fi

# 创建临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "下载初始化脚本..."
curl -fsSL -o init-dev-server.sh https://raw.githubusercontent.com/YOUR_USERNAME/dev-server-init/main/init-dev-server.sh

echo "添加执行权限..."
chmod +x init-dev-server.sh

echo "开始执行初始化脚本..."
./init-dev-server.sh

# 清理临时文件
cd "$HOME"
rm -rf "$TEMP_DIR"

echo "快速安装完成！"
