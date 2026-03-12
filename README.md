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

## Local Template Folders

- `base/.devcontainer`
- `base-heavy/.devcontainer`
- `base-heavy-nvidia/.devcontainer`
- `makers-gpu/.devcontainer`

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

## Publishing

The GitHub Actions workflow `.github/workflows/publish-ghcr.yml` builds and pushes:

1. `base`
2. `base-heavy` (from the freshly built `base` tag)
3. `base-heavy-nvidia` and `makers-gpu` (from freshly built `base-heavy`)

Tags published: `latest`, `main`, and short commit SHA.
No QEMU emulation is used in CI.
