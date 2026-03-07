FROM debian:bookworm-slim

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    git-lfs \
    jq \
    rsync \
    sudo \
    tmux \
    tree \
    wget \
    ripgrep \
    bat \
    && git lfs install --system \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI via official repo
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create dev-user with passwordless sudo
RUN useradd -m -s /bin/bash dev-user \
    && echo "dev-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dev-user \
    && chmod 0440 /etc/sudoers.d/dev-user

USER dev-user
WORKDIR /home/dev-user

# Install uv (replaces conda for Python env management — much lighter and faster)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Shell config
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc \
    && echo 'alias bat=batcat' >> ~/.bashrc
