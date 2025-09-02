#!/bin/bash

# Docker 测试脚本 - 自动化验证开发服务器初始化脚本
# 使用 expect 来模拟用户交互

set -e

echo "========================================"
echo "  Docker 环境验证测试"
echo "========================================"

# 创建一个测试输入文件来模拟用户输入
cat > /tmp/test_inputs << 'EOF'
# Git 用户名（使用默认值）

# Git 邮箱（使用默认值）

# JDK 选择 - 选择 OpenJDK 17
1
# Maven 选择 - 安装 Maven
1
EOF

echo "开始运行初始化脚本..."
echo "注意: 此测试将使用预设的输入来自动化安装过程"

# 运行脚本并提供预设输入
timeout 1200 bash -c '
exec < /tmp/test_inputs
./init-dev-server.sh
'

echo
echo "========================================"
echo "  安装验证"
echo "========================================"

# 验证各个工具是否安装成功
echo "检查安装的工具版本:"

# 基础工具验证
tools=("git" "curl" "wget" "htop" "tmux" "vim")
for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        version=$($tool --version 2>/dev/null | head -1 || echo "已安装")
        echo "✅ $tool: $version"
    else
        echo "❌ $tool: 未安装"
    fi
done

# Rust 验证
if command -v rustc &> /dev/null; then
    echo "✅ Rust: $(rustc --version)"
    echo "✅ Cargo: $(cargo --version)"
else
    echo "❌ Rust: 未安装"
fi

# UV 验证
if command -v uv &> /dev/null; then
    echo "✅ UV: $(uv --version)"
else
    echo "❌ UV: 未安装"
fi

# Node.js 验证
if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node --version)"
    echo "✅ npm: v$(npm --version)"
    
    # 检查全局包
    if command -v yarn &> /dev/null; then
        echo "✅ Yarn: $(yarn --version)"
    fi
    if command -v pnpm &> /dev/null; then
        echo "✅ pnpm: $(pnpm --version)"
    fi
    if command -v pm2 &> /dev/null; then
        echo "✅ PM2: $(pm2 --version)"
    fi
else
    echo "❌ Node.js: 未安装"
fi

# Java 验证
if command -v java &> /dev/null; then
    java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
    javac_version=$(javac -version 2>&1 | cut -d' ' -f2)
    echo "✅ Java: $java_version"
    echo "✅ Javac: $javac_version"
    echo "✅ JAVA_HOME: ${JAVA_HOME:-未设置}"
else
    echo "❌ Java: 未安装"
fi

# Maven 验证
if command -v mvn &> /dev/null; then
    maven_version=$(mvn -version 2>/dev/null | head -1 | cut -d' ' -f3)
    echo "✅ Maven: $maven_version"
    
    # 检查 Maven 配置
    if [[ -f "$HOME/.m2/settings.xml" ]]; then
        echo "✅ Maven 配置文件: 已创建"
    else
        echo "❌ Maven 配置文件: 未找到"
    fi
else
    echo "❌ Maven: 未安装"
fi

echo
echo "========================================"
echo "  环境配置验证"
echo "========================================"

# Git 配置验证
echo "Git 配置:"
git_user=$(git config --global user.name 2>/dev/null || echo "未设置")
git_email=$(git config --global user.email 2>/dev/null || echo "未设置")
echo "  用户名: $git_user"
echo "  邮箱: $git_email"

# tmux 配置验证
if [[ -f "$HOME/.tmux.conf" ]]; then
    echo "✅ tmux 配置文件: 已创建"
else
    echo "❌ tmux 配置文件: 未找到"
fi

# 开发目录验证
echo "开发目录:"
directories=("$HOME/projects" "$HOME/tools" "$HOME/scripts" "$HOME/.local/bin")
for dir in "${directories[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "✅ $dir: 已创建"
    else
        echo "❌ $dir: 未找到"
    fi
done

echo
echo "========================================"
echo "  测试完成"
echo "========================================"

# 计算成功安装的工具数量
success_count=0
total_count=0

# 基础工具计数
for tool in "${tools[@]}"; do
    total_count=$((total_count + 1))
    if command -v "$tool" &> /dev/null; then
        success_count=$((success_count + 1))
    fi
done

# 开发工具计数
dev_tools=("rustc" "uv" "node" "java" "mvn")
for tool in "${dev_tools[@]}"; do
    total_count=$((total_count + 1))
    if command -v "$tool" &> /dev/null; then
        success_count=$((success_count + 1))
    fi
done

echo "安装成功率: $success_count/$total_count ($(( success_count * 100 / total_count ))%)"

if [[ $success_count -eq $total_count ]]; then
    echo "🎉 所有工具安装成功！"
    exit 0
else
    echo "⚠️  部分工具安装失败，请检查日志"
    exit 1
fi
