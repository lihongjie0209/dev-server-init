#!/bin/bash

# 开发服务器初始化脚本
# 适用于 Debian/Ubuntu 系统
# 作者: 自动生成
# 日期: $(date +%Y-%m-%d)

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 root 用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "请不要以 root 用户运行此脚本"
        exit 1
    fi
}

# 检查系统类型
check_system() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case $ID in
            debian|ubuntu)
                log_info "检测到系统: $PRETTY_NAME"
                ;;
            *)
                log_error "不支持的系统类型: $PRETTY_NAME"
                log_error "此脚本仅支持 Debian 和 Ubuntu 系统"
                exit 1
                ;;
        esac
    else
        log_error "无法检测系统类型"
        exit 1
    fi
}

# 更新系统包管理器
update_system() {
    log_info "更新系统包管理器..."
    sudo apt update
    sudo apt upgrade -y
    log_success "系统更新完成"
}

# 安装基础工具
install_basic_tools() {
    log_info "安装基础工具..."
    local tools=(
        "curl"
        "wget" 
        "htop"
        "tmux"
        "vim"
        "git"
        "build-essential"
        "software-properties-common"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "unzip"
        "tree"
        "jq"
    )
    
    for tool in "${tools[@]}"; do
        log_info "安装 $tool..."
        sudo apt install -y "$tool"
    done
    
    log_success "基础工具安装完成"
}

# 配置 Git
setup_git() {
    log_info "配置 Git..."
    
    # 设置默认值
    local default_user="lihongjie0209"
    local default_email="lihongjie0209@gmail.com"
    
    # 尝试从当前系统获取用户信息
    local current_user=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    # 确定显示的默认值（优先级：当前系统配置 > 脚本默认值）
    local display_user="${current_user:-$default_user}"
    local display_email="${current_email:-$default_email}"
    
    # 提示用户输入，显示相应的默认值
    read -p "Git 用户名 (默认: $display_user): " git_username
    git_username=${git_username:-$display_user}
    
    read -p "Git 邮箱 (默认: $display_email): " git_email
    git_email=${git_email:-$display_email}
    
    # 设置 Git 配置
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    
    # 配置 Git 记住密码
    git config --global credential.helper store
    
    # 其他有用的 Git 配置
    git config --global init.defaultBranch main
    git config --global core.editor vim
    git config --global pull.rebase false
    
    log_success "Git 配置完成"
    log_info "用户名: $git_username"
    log_info "邮箱: $git_email"
    log_info "已启用密码记住功能"
}

# 安装 Rustup (使用阿里云镜像)
install_rustup() {
    log_info "安装 Rustup (使用阿里云镜像)..."
    
    # 设置 Rustup 镜像环境变量
    export RUSTUP_DIST_SERVER="https://mirrors.aliyun.com/rustup"
    export RUSTUP_UPDATE_ROOT="https://mirrors.aliyun.com/rustup/rustup"
    
    # 下载并安装 rustup
    curl --proto '=https' --tlsv1.2 -sSf https://mirrors.aliyun.com/rustup/rustup-init.sh | sh -s -- -y
    
    # 添加到当前会话的 PATH
    source "$HOME/.cargo/env"
    
    # 设置 Cargo 镜像源
    mkdir -p "$HOME/.cargo"
    cat > "$HOME/.cargo/config.toml" << 'EOF'
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = 'aliyun'

[source.aliyun]
registry = "https://code.aliyun.com/rustcc/crates.io-index.git"

[registries.aliyun]
index = "https://code.aliyun.com/rustcc/crates.io-index.git"

[net]
git-fetch-with-cli = true
EOF
    
    # 添加环境变量到 shell 配置文件
    local shell_config=""
    if [[ -n "$ZSH_VERSION" ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]]; then
        shell_config="$HOME/.bashrc"
    else
        shell_config="$HOME/.profile"
    fi
    
    # 检查是否已经添加过环境变量
    if ! grep -q "RUSTUP_DIST_SERVER" "$shell_config" 2>/dev/null; then
        cat >> "$shell_config" << 'EOF'

# Rust 环境变量 (阿里云镜像)
export RUSTUP_DIST_SERVER="https://mirrors.aliyun.com/rustup"
export RUSTUP_UPDATE_ROOT="https://mirrors.aliyun.com/rustup/rustup"
export PATH="$HOME/.cargo/bin:$PATH"
EOF
    fi
    
    log_success "Rustup 安装完成 (使用阿里云镜像)"
    log_info "Rust 版本: $(rustc --version)"
    log_info "Cargo 版本: $(cargo --version)"
}

# 安装 UV (Python 包管理器)
install_uv() {
    log_info "安装 UV..."
    
    # 使用官方安装脚本
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # 添加到当前会话的 PATH
    source "$HOME/.cargo/env"
    
    log_success "UV 安装完成"
    log_info "UV 版本: $(uv --version)"
}

# 安装 Node.js
install_nodejs() {
    log_info "安装 Node.js..."
    
    # 获取系统版本信息
    source /etc/os-release
    
    # 添加 NodeSource 官方仓库
    log_info "添加 NodeSource 官方仓库..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    
    # 安装 Node.js
    log_info "安装 Node.js LTS 版本..."
    sudo apt-get install -y nodejs
    
    # 验证安装
    local node_version=$(node --version 2>/dev/null || echo "未安装")
    local npm_version=$(npm --version 2>/dev/null || echo "未安装")
    
    if [[ "$node_version" != "未安装" ]]; then
        log_success "Node.js 安装完成"
        log_info "Node.js 版本: $node_version"
        log_info "npm 版本: v$npm_version"
        
        # 配置 npm 镜像源（可选，提高国内下载速度）
        log_info "配置 npm 使用淘宝镜像源..."
        npm config set registry https://registry.npmmirror.com/
        
        # 全局安装一些常用工具
        log_info "安装常用的全局 npm 包..."
        npm install -g yarn pnpm pm2
        
        log_success "Node.js 环境配置完成"
    else
        log_error "Node.js 安装失败"
    fi
}

# 创建开发环境目录
create_dev_directories() {
    log_info "创建开发环境目录..."
    
    local directories=(
        "$HOME/projects"
        "$HOME/tools"
        "$HOME/scripts"
        "$HOME/.local/bin"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
        log_info "创建目录: $dir"
    done
    
    log_success "开发环境目录创建完成"
}

# 配置 tmux
setup_tmux() {
    log_info "配置 tmux..."
    
    cat > "$HOME/.tmux.conf" << 'EOF'
# 启用鼠标支持
set -g mouse on

# 设置窗口和面板索引从 1 开始
set -g base-index 1
setw -g pane-base-index 1

# 快速重载配置文件
bind r source-file ~/.tmux.conf \; display "配置文件已重载!"

# 分割窗口快捷键
bind | split-window -h
bind - split-window -v

# 面板导航快捷键
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# 设置状态栏
set -g status-bg black
set -g status-fg white
set -g status-left '#[fg=green]#S '
set -g status-right '#[fg=yellow]%Y-%m-%d %H:%M'

# 历史记录行数
set -g history-limit 10000
EOF
    
    log_success "tmux 配置完成"
}

# 显示安装总结
show_summary() {
    log_success "开发服务器初始化完成！"
    echo
    echo "==================== 安装总结 ===================="
    echo "✅ 系统更新完成"
    echo "✅ 基础工具安装完成: curl, wget, htop, tmux, git 等"
    echo "✅ Git 配置完成 (用户: $(git config --global user.name), 邮箱: $(git config --global user.email))"
    echo "✅ Rustup 安装完成 (使用阿里云镜像)"
    echo "✅ UV 安装完成"
    echo "✅ Node.js 安装完成 ($(node --version 2>/dev/null || echo "未安装"))"
    echo "✅ tmux 配置完成"
    echo "✅ 开发目录创建完成"
    echo "================================================="
    echo
    log_warning "请重新加载 shell 配置或重新登录以使环境变量生效:"
    echo "source ~/.bashrc  # 或 source ~/.zshrc"
    echo
    log_info "常用命令:"
    echo "  tmux new -s mysession    # 创建新的 tmux 会话"
    echo "  tmux attach -t mysession # 附加到现有会话"
    echo "  htop                     # 查看系统资源"
    echo "  rustc --version          # 检查 Rust 版本"
    echo "  uv --version             # 检查 UV 版本"
    echo "  node --version           # 检查 Node.js 版本"
    echo "  npm --version            # 检查 npm 版本"
}

# 主函数
main() {
    echo "========================================"
    echo "    开发服务器初始化脚本"
    echo "    适用于 Debian/Ubuntu 系统"
    echo "========================================"
    echo
    
    check_root
    check_system
    
    log_info "开始初始化开发服务器..."
    echo
    
    update_system
    install_basic_tools
    setup_git
    install_rustup
    install_uv
    install_nodejs
    create_dev_directories
    setup_tmux
    
    echo
    show_summary
}

# 脚本入口点
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
