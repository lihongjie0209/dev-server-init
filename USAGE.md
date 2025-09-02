# 使用说明

## 在 Linux/Ubuntu/Debian 系统上使用

1. **下载项目文件到目标服务器**
2. **添加执行权限**:
   ```bash
   chmod +x init-dev-server.sh
   chmod +x quick-install.sh
   ```
3. **运行主脚本**:
   ```bash
   ./init-dev-server.sh
   ```

## 或者使用快速安装（一键执行）

如果您将代码上传到 GitHub，用户可以直接运行：

```bash
curl -fsSL https://raw.githubusercontent.com/lihongjie0209/dev-server-init/main/init-dev-server.sh | bash
```

## 功能验证

安装完成后，可以运行以下命令验证安装：

```bash
# 检查基础工具
git --version
curl --version
wget --version
htop --version
tmux -V

# 检查 Rust 环境
rustc --version
cargo --version

# 检查 UV
uv --version

# 检查 Git 配置
git config --list
```

## 重要提醒

- 请不要以 root 用户运行脚本
- 确保用户具有 sudo 权限
- 首次运行时需要输入 sudo 密码
- 安装完成后请重新加载 shell 配置或重新登录
