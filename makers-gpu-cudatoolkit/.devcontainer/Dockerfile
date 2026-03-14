ARG BASE_IMAGE=ghcr.io/agentcluck77/devcontainer-stripped-makers-gpu:main
FROM ${BASE_IMAGE}

USER root

ARG CUDA_KEYRING_DEB=cuda-keyring_1.1-1_all.deb
ARG CUDA_REPO_URL=https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64
ARG CUDA_TOOLKIT_PACKAGE=cuda-toolkit

RUN set -eux; \
    cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak; \
    sed -i '/^Components:/ { /contrib/! s/$/ contrib/ }' /etc/apt/sources.list.d/debian.sources; \
    apt-get update; \
    apt-get install -y --no-install-recommends wget gpg ca-certificates; \
    cd /tmp; \
    wget -q "${CUDA_REPO_URL}/${CUDA_KEYRING_DEB}"; \
    dpkg -i "${CUDA_KEYRING_DEB}"; \
    apt-get update; \
    apt-get install -y --no-install-recommends "${CUDA_TOOLKIT_PACKAGE}"; \
    rm -f "/tmp/${CUDA_KEYRING_DEB}"; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

ENV CUDA_HOME=/usr/local/cuda
ENV PATH=/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64

USER dev-user
