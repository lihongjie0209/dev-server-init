# 开发服务器初始化脚本

这是一个用于快速初始化 Debian/Ubuntu 开发服务器的 bash 脚本。

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
- ✅ **开发环境**: 创建常用的开发目录
- ✅ **tmux 配置**: 提供便捷的终端复用器配置

## 系统要求

- Debian 或 Ubuntu 系统
- 非 root 用户运行
- 具有 sudo 权限

## 使用方法

### 1. 下载脚本

```bash
# 克隆仓库
git clone <repository-url>
cd dev-server-init

# 或直接下载脚本文件
wget https://raw.githubusercontent.com/<user>/<repo>/main/init-dev-server.sh
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
