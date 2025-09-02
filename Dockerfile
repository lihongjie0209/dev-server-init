# 使用 Ubuntu 最新 LTS 版本作为基础镜像
FROM ubuntu:22.04

# 设置环境变量避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 更新系统并安装基础工具
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# 创建一个非 root 用户用于测试
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 切换到测试用户
USER testuser
WORKDIR /home/testuser

# 复制脚本到容器中
COPY --chown=testuser:testuser init-dev-server.sh /home/testuser/init-dev-server.sh
COPY --chown=testuser:testuser test-docker.sh /home/testuser/test-docker.sh

# 设置脚本执行权限
RUN chmod +x /home/testuser/init-dev-server.sh /home/testuser/test-docker.sh

# 设置默认命令
CMD ["/bin/bash"]
