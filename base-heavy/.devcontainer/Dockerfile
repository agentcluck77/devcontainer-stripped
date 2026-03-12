ARG BASE_IMAGE=ghcr.io/agentcluck77/devcontainer-stripped-base:main
FROM ${BASE_IMAGE}

USER root

# Linuxbrew requires a compiler toolchain and basic build utilities.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    file \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Homebrew Linux default prefix must be writable by the installing user.
RUN mkdir -p /home/linuxbrew/.linuxbrew \
    && chown -R dev-user:dev-user /home/linuxbrew

USER dev-user
WORKDIR /home/dev-user

ENV NONINTERACTIVE=1
ENV HOMEBREW_NO_ANALYTICS=1
ENV HOMEBREW_NO_INSTALL_CLEANUP=1

# Install Homebrew for Linux under /home/linuxbrew/.linuxbrew.
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/dev-user/.local/bin:/home/dev-user/miniforge3/bin:${PATH}

COPY .devcontainer/Brewfile /tmp/Brewfile
RUN cp /tmp/Brewfile /tmp/Brewfile.effective \
    # Avoid long/fragile source builds in CI image publishing.
    && grep -v '^[[:space:]]*brew "plantuml"' /tmp/Brewfile.effective > /tmp/Brewfile.ci \
    && mv /tmp/Brewfile.ci /tmp/Brewfile.effective \
    && brew bundle install --file /tmp/Brewfile.effective

# Install Miniforge (Conda-compatible distribution) for amd64.
RUN test "$(uname -m)" = "x86_64" \
    && curl -L -o /tmp/Miniforge3.sh \
    "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh" \
    && bash /tmp/Miniforge3.sh -b -p "$HOME/miniforge3" \
    && rm -f /tmp/Miniforge3.sh \
    && "$HOME/miniforge3/bin/conda" clean -afy

RUN grep -q 'conda" shell.bash hook' "$HOME/.bashrc" \
    || echo 'eval "$("$HOME/miniforge3/bin/conda" shell.bash hook)"' >> "$HOME/.bashrc"
