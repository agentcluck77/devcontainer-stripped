# Devcontainer Image Templates

This repo builds and publishes multiple devcontainer base images to GHCR.
Publishing is currently `linux/amd64` only.

## Images

- `ghcr.io/agentcluck77/devcontainer-stripped-base:main`
  - Minimal Debian dev base (git, gh, uv, common CLI tools).
  - No NVIDIA runtime settings.

- `ghcr.io/agentcluck77/devcontainer-stripped-base-heavy:main`
  - Extends `base` with Homebrew + Miniforge (conda) and additional CLI tools.
  - Built and published for `linux/amd64`.
  - No NVIDIA runtime settings.

- `ghcr.io/agentcluck77/devcontainer-stripped-base-heavy-nvidia:main`
  - Extends `base-heavy`.
  - Intended for generic NVIDIA GPU devcontainer use.

- `ghcr.io/agentcluck77/devcontainer-stripped-makers-gpu:main`
  - GPU-focused variant for maker workflows, built from `base-heavy`.

- `ghcr.io/agentcluck77/devcontainer-stripped-base-heavy-cudatoolkit:main`
  - Extends `base-heavy`.
  - Installs latest NVIDIA `cuda-toolkit` from the official Debian 12 CUDA repo.

- `ghcr.io/agentcluck77/devcontainer-stripped-makers-gpu-cudatoolkit:main`
  - Extends `makers-gpu`.
  - Adds latest NVIDIA `cuda-toolkit` with GPU runtime settings.

- `ghcr.io/agentcluck77/devcontainer-stripped-base-heavy-llamacpp:main`
  - Extends `base-heavy-cudatoolkit`.
  - Builds `llama.cpp` from source with CUDA (`GGML_CUDA=ON`) during image build.

- `ghcr.io/agentcluck77/devcontainer-stripped-makers-gpu-llamacpp:main`
  - Extends `makers-gpu-cudatoolkit`.
  - Builds `llama.cpp` from source with CUDA (`GGML_CUDA=ON`) during image build.

## Local Template Folders

- `base/.devcontainer`
- `base-heavy/.devcontainer`
- `base-heavy-nvidia/.devcontainer`
- `makers-gpu/.devcontainer`
- `base-heavy-cudatoolkit/.devcontainer`
- `makers-gpu-cudatoolkit/.devcontainer`
- `base-heavy-llamacpp/.devcontainer`
- `makers-gpu-llamacpp/.devcontainer`

Use the `devcontainer.json` in those folders as starting points.

## Use in a Devcontainer

### CPU / non-NVIDIA

```jsonc
{
  "image": "ghcr.io/agentcluck77/devcontainer-stripped-base-heavy:main",
  "remoteUser": "dev-user",
  "containerUser": "dev-user",
  "updateRemoteUserUID": true,
  "workspaceFolder": "/workspaces/content",
  "securityOpt": ["label=disable"],
  "postCreateCommand": "bash .devcontainer/build.sh"
}
```

### NVIDIA GPU

```jsonc
{
  "image": "ghcr.io/agentcluck77/devcontainer-stripped-base-heavy-nvidia:main",
  "remoteUser": "dev-user",
  "containerUser": "dev-user",
  "updateRemoteUserUID": true,
  "workspaceFolder": "/workspaces/content",
  "securityOpt": ["label=disable"],
  "runArgs": ["--device", "nvidia.com/gpu=all"],
  "containerEnv": {
    "NVIDIA_VISIBLE_DEVICES": "all",
    "NVIDIA_DRIVER_CAPABILITIES": "compute,utility"
  },
  "postCreateCommand": "sudo chown -R $(id -u):$(id -g) /home/linuxbrew/.linuxbrew && bash .devcontainer/build.sh"
}
```

### NVIDIA + CUDA Toolkit

```jsonc
{
  "image": "ghcr.io/agentcluck77/devcontainer-stripped-makers-gpu-cudatoolkit:main",
  "remoteUser": "dev-user",
  "containerUser": "dev-user",
  "updateRemoteUserUID": true,
  "workspaceFolder": "/workspaces/content",
  "securityOpt": ["label=disable"],
  "runArgs": ["--device", "nvidia.com/gpu=all"],
  "containerEnv": {
    "NVIDIA_VISIBLE_DEVICES": "all",
    "NVIDIA_DRIVER_CAPABILITIES": "compute,utility"
  },
  "postCreateCommand": "sudo chown -R $(id -u):$(id -g) /home/linuxbrew/.linuxbrew && bash .devcontainer/build.sh"
}
```

### NVIDIA + CUDA Toolkit + llama.cpp

```jsonc
{
  "image": "ghcr.io/agentcluck77/devcontainer-stripped-makers-gpu-llamacpp:main",
  "remoteUser": "dev-user",
  "containerUser": "dev-user",
  "updateRemoteUserUID": true,
  "workspaceFolder": "/workspaces/content",
  "securityOpt": ["label=disable"],
  "runArgs": ["--device", "nvidia.com/gpu=all"],
  "containerEnv": {
    "NVIDIA_VISIBLE_DEVICES": "all",
    "NVIDIA_DRIVER_CAPABILITIES": "compute,utility"
  },
  "postCreateCommand": "sudo chown -R $(id -u):$(id -g) /home/linuxbrew/.linuxbrew && bash .devcontainer/build.sh"
}
```

## Publishing

The GitHub Actions workflow `.github/workflows/publish-ghcr.yml` builds and pushes:

1. `base`
2. `base-heavy` (from the freshly built `base` tag)
3. `base-heavy-nvidia`, `makers-gpu`, and `base-heavy-cudatoolkit` (from freshly built `base-heavy`)
4. `makers-gpu-cudatoolkit` (from freshly built `makers-gpu`)
5. `base-heavy-llamacpp` (from freshly built `base-heavy-cudatoolkit`)
6. `makers-gpu-llamacpp` (from freshly built `makers-gpu-cudatoolkit`)

Tags published: `latest`, `main`, and short commit SHA.
No QEMU emulation is used in CI.
