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

USER dev-user
WORKDIR /home/dev-user

ENV NONINTERACTIVE=1
ENV HOMEBREW_NO_ANALYTICS=1
ENV HOMEBREW_NO_INSTALL_CLEANUP=1

# Install Homebrew for Linux under /home/linuxbrew/.linuxbrew.
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/dev-user/.local/bin:/home/dev-user/miniforge3/bin:${PATH}

COPY .devcontainer/Brewfile /tmp/Brewfile
RUN brew bundle install --file /tmp/Brewfile

# Install Miniforge (Conda-compatible distribution).
RUN arch="$(uname -m)" \
    && case "$arch" in \
      x86_64) miniforge_arch="x86_64" ;; \
      aarch64|arm64) miniforge_arch="aarch64" ;; \
      *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac \
    && curl -L -o /tmp/Miniforge3.sh \
    "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-${miniforge_arch}.sh" \
    && bash /tmp/Miniforge3.sh -b -p "$HOME/miniforge3" \
    && rm -f /tmp/Miniforge3.sh \
    && "$HOME/miniforge3/bin/conda" clean -afy

RUN grep -q 'conda" shell.bash hook' "$HOME/.bashrc" \
    || echo 'eval "$("$HOME/miniforge3/bin/conda" shell.bash hook)"' >> "$HOME/.bashrc"
