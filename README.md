# 开发服务器初始化脚本

这是一个用于快速初始化 Debian/Ubuntu 开发服务器的 bash 脚本。

## 🚀 快速开始

**一键安装，立即使用：**

```bash
curl -fsSL https://raw.githubusercontent.com/lihongjie0209/dev-server-init/main/init-dev-server.sh | bash
```

> 💡 **提示**: 
> - 脚本会提示您输入 Git 用户名和邮箱，支持默认值，直接回车即可使用预设配置
> - JDK 安装是可选的，您可以选择 OpenJDK 17、OpenJDK 21 或跳过安装
> - 如果选择安装 JDK，脚本会询问是否需要安装 Maven 构建工具

## 功能特性

- ✅ **系统更新**: 自动更新系统包管理器
- ✅ **基础工具安装**: 安装 git, curl, wget, htop, tmux 等常用开发工具
- ✅ **Git 配置**: 
  - 从当前系统获取用户信息或提示用户输入
  - 配置用户名和邮箱
  - 启用密码记住功能
  - 设置其他有用的 Git 配置
- ✅ **Rust 环境**: 
  - 使用阿里云镜像安装 rustup
  - 配置 Cargo 国内镜像源
  - 自动添加环境变量到 shell 配置文件
- ✅ **UV 安装**: Python 包管理器
- ✅ **Node.js 环境**:
  - 安装最新 LTS 版本
  - 配置 npm 使用淘宝镜像源
  - 全局安装 yarn, pnpm, pm2 等常用工具
- ✅ **Java 环境** (可选):
  - 支持 OpenJDK 17 (LTS) 或 OpenJDK 21 (最新 LTS)
  - 自动配置 JAVA_HOME 环境变量
  - 用户可选择跳过安装
  - 可选安装 Apache Maven 构建工具
  - 配置 Maven 使用阿里云镜像源
- ✅ **开发环境**: 创建常用的开发目录
- ✅ **tmux 配置**: 提供便捷的终端复用器配置

## 系统要求

- Debian 或 Ubuntu 系统
- 非 root 用户运行
- 具有 sudo 权限

## 使用方法

### 🚀 一键安装（推荐）

最简单的方式，直接在 Debian/Ubuntu 服务器上运行：

```bash
curl -fsSL https://raw.githubusercontent.com/lihongjie0209/dev-server-init/main/init-dev-server.sh | bash
```

### 📥 手动安装

### 1. 下载脚本

```bash
# 克隆仓库
git clone https://github.com/lihongjie0209/dev-server-init.git
cd dev-server-init

# 或直接下载脚本文件
wget https://raw.githubusercontent.com/lihongjie0209/dev-server-init/main/init-dev-server.sh
```

### 2. 添加执行权限

```bash
chmod +x init-dev-server.sh
```

### 3. 运行脚本

```bash
./init-dev-server.sh
```

### 4. 重新加载 shell 配置

```bash
# 对于 bash 用户
source ~/.bashrc

# 对于 zsh 用户
source ~/.zshrc
```

## 安装的工具列表

### 基础工具
- `curl` - 命令行 HTTP 客户端
- `wget` - 文件下载工具
- `htop` - 交互式进程查看器
- `tmux` - 终端复用器
- `vim` - 文本编辑器
- `git` - 版本控制系统
- `build-essential` - 编译工具集
- `jq` - JSON 处理工具
- `tree` - 目录树显示工具
- `unzip` - 解压工具

### 开发工具
- **Rust**: 通过 rustup 安装，使用阿里云镜像
- **UV**: Python 包管理器
- **Node.js**: 最新 LTS 版本，包含 npm, yarn, pnpm, pm2
- **Java**: OpenJDK 17/21 + Maven (可选安装)

## 创建的目录结构

```
$HOME/
├── projects/     # 项目目录
├── tools/        # 工具目录
├── scripts/      # 脚本目录
└── .local/bin/   # 本地可执行文件目录
```

## 配置文件

### Git 配置
脚本会配置以下 Git 设置：
- 用户名和邮箱
- 默认分支名为 `main`
- 启用密码存储
- 设置默认编辑器为 vim
- 配置 pull 策略

### tmux 配置 (~/.tmux.conf)
- 启用鼠标支持
- 窗口和面板索引从 1 开始
- 自定义状态栏
- 便捷的面板分割和导航快捷键

### Rust 配置
- 使用阿里云 rustup 镜像
- 配置 Cargo 使用阿里云 crates.io 镜像
- 自动添加环境变量到 shell 配置文件

### Node.js 配置
- 使用 NodeSource 官方仓库安装最新 LTS 版本
- 配置 npm 使用淘宝镜像源 (registry.npmmirror.com)
- 全局安装常用包管理器和工具：yarn, pnpm, pm2

### Java 配置 (可选)
- 提供 OpenJDK 17 (LTS) 和 OpenJDK 21 (最新 LTS) 选项
- 自动设置 JAVA_HOME 环境变量
- 将 Java 可执行文件添加到 PATH
- 支持跳过安装选项
- JDK 安装成功后可选择安装 Apache Maven
- Maven 配置使用阿里云镜像源，提高依赖下载速度

## 常用命令

安装完成后，您可以使用以下命令：

```bash
# tmux 会话管理
tmux new -s mysession          # 创建新会话
tmux attach -t mysession       # 附加到会话
tmux list-sessions             # 列出所有会话

# 系统监控
htop                           # 查看系统资源

# Rust 开发
rustc --version                # 检查 Rust 版本
cargo --version                # 检查 Cargo 版本
cargo new myproject            # 创建新的 Rust 项目

# Python 开发
uv --version                   # 检查 UV 版本
uv init myproject              # 创建新的 Python 项目

# Node.js 开发
node --version                 # 检查 Node.js 版本
npm --version                  # 检查 npm 版本
yarn --version                 # 检查 yarn 版本
pnpm --version                 # 检查 pnpm 版本
npm init                       # 创建新的 Node.js 项目

# Java 开发 (如果已安装)
java -version                  # 检查 Java 版本
javac -version                 # 检查 Java 编译器版本
echo $JAVA_HOME                # 检查 JAVA_HOME 环境变量

# Maven 项目管理 (如果已安装)
mvn -version                   # 检查 Maven 版本
mvn archetype:generate         # 创建新的 Maven 项目
mvn clean compile              # 编译项目
mvn clean package              # 打包项目
```

## 故障排除

### 权限问题
如果遇到权限问题，请确保：
1. 不要以 root 用户运行脚本
2. 当前用户具有 sudo 权限
3. 首次运行 sudo 命令时输入密码

### 网络问题
如果下载失败，可能是网络问题：
1. 检查网络连接
2. 尝试使用代理
3. 重新运行脚本

### 环境变量未生效
如果安装完成后找不到命令：
1. 重新加载 shell 配置：`source ~/.bashrc`
2. 重新登录终端
3. 检查 `$PATH` 环境变量

## 自定义

您可以根据需要修改脚本：
1. 在 `install_basic_tools()` 函数中添加或移除工具
2. 修改 Git 配置
3. 自定义 tmux 配置
4. 添加其他开发工具的安装

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个脚本。

## 许可证

MIT License
