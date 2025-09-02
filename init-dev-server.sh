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
    echo -e "${BLUE}[INFO]${NC} 安装 Rustup (使用阿里云镜像)..."
    
    # 设置阿里云镜像
    export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup
    export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup
    
    # 下载并运行 rustup 安装脚本
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # 添加到 PATH
    if [ -f "$HOME/.cargo/env" ]; then
        source $HOME/.cargo/env
    else
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    
    # 配置中国镜像源
    mkdir -p ~/.cargo
    cat > ~/.cargo/config.toml << 'EOF'
[source.crates-io]
replace-with = 'aliyun'

[source.aliyun]
registry = "https://code.aliyun.com/rustcc/crates.io-index.git"

[registries.aliyun]
index = "https://code.aliyun.com/rustcc/crates.io-index.git"

[net]
git-fetch-with-cli = true
EOF
    
    echo -e "${GREEN}[SUCCESS]${NC} Rustup 安装完成"
    if command -v rustc &> /dev/null; then
        echo -e "${BLUE}[INFO]${NC} 当前版本: $(rustc --version)"
    else
        echo -e "${YELLOW}[WARNING]${NC} 请重启终端以使 Rust 生效"
    fi
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

# 安装 JDK (可选)
install_jdk() {
    log_info "JDK 安装选项..."
    
    echo -e "${YELLOW}是否安装 OpenJDK？${NC}"
    echo "1. 安装 OpenJDK 17 (LTS 推荐)"
    echo "2. 安装 OpenJDK 21 (最新 LTS)"
    echo "3. 跳过 JDK 安装"
    
    local jdk_installed=false
    
    while true; do
        read -p "请选择 (1-3): " jdk_choice
        case $jdk_choice in
            1)
                log_info "安装 OpenJDK 17..."
                sudo apt-get update
                sudo apt-get install -y openjdk-17-jdk
                
                # 验证安装
                local java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 2>/dev/null || echo "未安装")
                local javac_version=$(javac -version 2>&1 | cut -d' ' -f2 2>/dev/null || echo "未安装")
                
                if [[ "$java_version" != "未安装" ]]; then
                    log_success "OpenJDK 17 安装完成"
                    log_info "Java 版本: $java_version"
                    log_info "Javac 版本: $javac_version"
                    
                    # 设置 JAVA_HOME
                    setup_java_environment "17"
                    jdk_installed=true
                else
                    log_error "OpenJDK 17 安装失败"
                fi
                break
                ;;
            2)
                log_info "安装 OpenJDK 21..."
                sudo apt-get update
                sudo apt-get install -y openjdk-21-jdk
                
                # 验证安装
                local java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 2>/dev/null || echo "未安装")
                local javac_version=$(javac -version 2>&1 | cut -d' ' -f2 2>/dev/null || echo "未安装")
                
                if [[ "$java_version" != "未安装" ]]; then
                    log_success "OpenJDK 21 安装完成"
                    log_info "Java 版本: $java_version"
                    log_info "Javac 版本: $javac_version"
                    
                    # 设置 JAVA_HOME
                    setup_java_environment "21"
                    jdk_installed=true
                else
                    log_error "OpenJDK 21 安装失败"
                fi
                break
                ;;
            3)
                log_info "跳过 JDK 安装"
                break
                ;;
            *)
                log_warning "无效选择，请输入 1-3"
                ;;
        esac
    done
    
    # 如果 JDK 安装成功，询问是否安装 Maven
    if [[ "$jdk_installed" == true ]]; then
        install_maven
    fi
}

# 设置 Java 环境变量
setup_java_environment() {
    local java_version=$1
    local java_home="/usr/lib/jvm/java-${java_version}-openjdk-amd64"
    
    # 检查 JAVA_HOME 目录是否存在
    if [[ -d "$java_home" ]]; then
        log_info "设置 JAVA_HOME 环境变量..."
        
        # 确定 shell 配置文件
        local shell_config=""
        if [[ -n "$ZSH_VERSION" ]]; then
            shell_config="$HOME/.zshrc"
        elif [[ -n "$BASH_VERSION" ]]; then
            shell_config="$HOME/.bashrc"
        else
            shell_config="$HOME/.profile"
        fi
        
        # 检查是否已经添加过 JAVA_HOME
        if ! grep -q "JAVA_HOME" "$shell_config" 2>/dev/null; then
            cat >> "$shell_config" << EOF

# Java 环境变量
export JAVA_HOME=$java_home
export PATH=\$JAVA_HOME/bin:\$PATH
EOF
            log_success "JAVA_HOME 环境变量已添加到 $shell_config"
        else
            log_info "JAVA_HOME 环境变量已存在"
        fi
        
        # 为当前会话设置环境变量
        export JAVA_HOME="$java_home"
        export PATH="$JAVA_HOME/bin:$PATH"
        
    else
        log_warning "未找到 Java 安装目录: $java_home"
    fi
}

# 安装 Maven (仅在 JDK 安装成功后询问)
install_maven() {
    echo
    log_info "Maven 安装选项..."
    
    echo -e "${YELLOW}是否安装 Apache Maven？${NC}"
    echo "1. 是，安装 Maven (推荐用于 Java 项目管理)"
    echo "2. 否，跳过 Maven 安装"
    
    while true; do
        read -p "请选择 (1-2): " maven_choice
        case $maven_choice in
            1)
                log_info "安装 Apache Maven..."
                sudo apt-get update
                sudo apt-get install -y maven
                
                # 验证安装
                local maven_version=$(mvn -version 2>/dev/null | head -1 | cut -d' ' -f3 2>/dev/null || echo "未安装")
                
                if [[ "$maven_version" != "未安装" ]]; then
                    log_success "Maven 安装完成"
                    log_info "Maven 版本: $maven_version"
                    
                    # 配置 Maven 使用阿里云镜像
                    setup_maven_mirrors
                else
                    log_error "Maven 安装失败"
                fi
                break
                ;;
            2)
                log_info "跳过 Maven 安装"
                break
                ;;
            *)
                log_warning "无效选择，请输入 1-2"
                ;;
        esac
    done
}

# 配置 Maven 镜像源
setup_maven_mirrors() {
    log_info "配置 Maven 使用阿里云镜像源..."
    
    local maven_home="$HOME/.m2"
    local settings_file="$maven_home/settings.xml"
    
    # 创建 .m2 目录
    mkdir -p "$maven_home"
    
    # 创建 settings.xml 配置文件
    cat > "$settings_file" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 
          http://maven.apache.org/xsd/settings-1.0.0.xsd">
  
  <mirrors>
    <!-- 阿里云公共仓库 -->
    <mirror>
      <id>alimaven</id>
      <name>aliyun maven</name>
      <url>https://maven.aliyun.com/repository/public</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
  
  <profiles>
    <profile>
      <id>aliyun</id>
      <repositories>
        <repository>
          <id>aliyun-central</id>
          <name>阿里云中央仓库</name>
          <url>https://maven.aliyun.com/repository/central</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
        </repository>
        <repository>
          <id>aliyun-public</id>
          <name>阿里云公共仓库</name>
          <url>https://maven.aliyun.com/repository/public</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
        </repository>
      </repositories>
    </profile>
  </profiles>
  
  <activeProfiles>
    <activeProfile>aliyun</activeProfile>
  </activeProfiles>
</settings>
EOF
    
    log_success "Maven 阿里云镜像配置完成"
    log_info "配置文件位置: $settings_file"
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
    
    # 检查 JDK 是否安装
    local java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 2>/dev/null || echo "")
    if [[ -n "$java_version" ]]; then
        echo "✅ JDK 安装完成 ($java_version)"
        
        # 检查 Maven 是否安装
        local maven_version=$(mvn -version 2>/dev/null | head -1 | cut -d' ' -f3 2>/dev/null || echo "")
        if [[ -n "$maven_version" ]]; then
            echo "✅ Maven 安装完成 ($maven_version)"
        else
            echo "⏭️  Maven 跳过安装"
        fi
    else
        echo "⏭️  JDK 跳过安装"
    fi
    
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
    
    # 如果安装了 Java，显示 Java 相关命令
    if command -v java &> /dev/null; then
        echo "  java -version            # 检查 Java 版本"
        echo "  javac -version           # 检查 Java 编译器版本"
        
        # 如果安装了 Maven，显示 Maven 命令
        if command -v mvn &> /dev/null; then
            echo "  mvn -version             # 检查 Maven 版本"
        fi
    fi
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
    install_jdk
    create_dev_directories
    setup_tmux
    
    echo
    show_summary
}

# 脚本入口点
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
