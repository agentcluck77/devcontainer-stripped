# CUDA Toolkit Install Guide for Fresh Debian Containers

Research date: 2026-03-14

This guide is the recommended playbook for installing the CUDA toolkit on fresh Debian-based containers that already have host NVIDIA driver access exposed into the container.

It is written for the workflow in this repo:

- build `llama.cpp` with CUDA
- run local inference inside the container
- avoid cloud dependencies

## Recommendation

For fresh containers, prefer a **system CUDA toolkit install** from NVIDIA's Debian repo.

Why:

- cleaner than Conda for `llama.cpp` builds
- avoids Conda injecting `CC`, `CXX`, `LD`, `LDFLAGS`, and runtime paths
- produces a more predictable `/usr/local/cuda` layout
- easier to reuse across shells, users, and build tools

Use Conda only as a fallback when:

- you do not have root
- you cannot modify APT sources
- you need an isolated toolkit for one-off experiments

## What this guide assumes

- the container is Debian 12
- `nvidia-smi` works inside the container
- you have `sudo`
- you want toolkit-only packages, not container-side driver packages

Important:

- install `cuda-toolkit` or `cuda-toolkit-<major>-<minor>`
- do **not** install the `cuda` metapackage unless you explicitly want driver-related packages too

## Preflight

Verify GPU visibility first:

```bash
nvidia-smi
```

If this fails, stop. Fix container GPU passthrough first.

Check the current distro:

```bash
cat /etc/os-release
```

## Debian 12 install steps

### 1. Enable `contrib` in Debian sources

NVIDIA's docs require Debian repositories to include `contrib`.

Back up the source file and add `contrib`:

```bash
sudo cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak
sudo sed -i 's/^Components: main$/Components: main contrib/' /etc/apt/sources.list.d/debian.sources
```

Verify:

```bash
sed -n '1,120p' /etc/apt/sources.list.d/debian.sources
```

### 2. Install base repo tools

```bash
sudo apt-get update
sudo apt-get install -y wget gpg
```

### 3. Add NVIDIA's CUDA repo keyring

As of 2026-03-14, the Debian 12 repo publishes:

```text
cuda-keyring_1.1-1_all.deb
```

Install it:

```bash
cd /tmp
wget https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
```

### 4. Refresh APT metadata

```bash
sudo apt-get update
```

### 5. Choose a toolkit package

List available toolkit packages:

```bash
apt-cache search '^cuda-toolkit' | sed -n '1,60p'
```

Typical choices:

- `cuda-toolkit`
- `cuda-toolkit-13`
- `cuda-toolkit-13-1`
- `cuda-toolkit-13-2`

Recommendation:

- prefer a version aligned with the host driver's reported CUDA compatibility
- if `nvidia-smi` reports CUDA `13.1`, `cuda-toolkit-13-1` is a conservative choice

### 6. Install the toolkit

Recommended:

```bash
sudo apt-get install -y cuda-toolkit-13-1
```

Or latest toolkit tracked by the repo:

```bash
sudo apt-get install -y cuda-toolkit
```

## Shell environment

Add this block to `~/.bashrc`:

```bash
export CUDA_HOME=/usr/local/cuda
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
```

Apply it in the current shell:

```bash
source ~/.bashrc
```

## Verification

Run all of these:

```bash
which nvcc
nvcc -V
echo "$CUDA_HOME"
ls -ld /usr/local/cuda /usr/local/cuda/bin /usr/local/cuda/lib64
nvidia-smi
```

Expected:

- `which nvcc` returns `/usr/local/cuda/bin/nvcc` or another path under `/usr/local`
- `nvcc -V` prints a CUDA compiler version
- `CUDA_HOME` is `/usr/local/cuda`
- `/usr/local/cuda` exists
- `nvidia-smi` still works

Optional linker check:

```bash
ldconfig -p | grep -E 'libcudart|libcublas' || true
```

## Recommended `llama.cpp` build flow after system install

Do **not** build from an activated Conda toolchain unless you intentionally want that.

Use a clean shell:

```bash
conda deactivate 2>/dev/null || true
unset CC CXX LD CPPFLAGS CFLAGS CXXFLAGS LDFLAGS
```

Then rebuild:

```bash
cd /workspaces/content/llama.cpp
rm -rf build

cmake -B build \
  -DGGML_CUDA=ON \
  -DCUDAToolkit_ROOT=/usr/local/cuda \
  -DCMAKE_C_COMPILER=/usr/bin/cc \
  -DCMAKE_CXX_COMPILER=/usr/bin/c++

cmake --build build --config Release -j"$(nproc)"
```

Why the clean shell matters:

- Conda often injects its own compiler wrappers and linker flags
- that can produce mixed system/Conda linkage
- this caused the exact `libcudart`, `libcublas`, `libgomp`, and `GLIBCXX` link failures seen in this environment

## Troubleshooting

### `cmake` says CUDA toolkit not found

Check:

```bash
which nvcc
nvcc -V
echo "$CUDA_HOME"
```

If `nvcc` is missing after install:

- confirm the toolkit package actually finished installing
- confirm `/usr/local/cuda/bin` is on `PATH`
- open a new shell or `source ~/.bashrc`

### `apt install nvidia-cuda-toolkit` does not work

That package comes from Debian repositories and may be unavailable or undesirable in minimal containers.

Use NVIDIA's own repo and install `cuda-toolkit` instead.

### `llama.cpp` links against the wrong libraries

This usually means:

- Conda is still activated
- `CC`, `CXX`, `LD`, or `LDFLAGS` are still set
- CMake cache was created under a different toolchain

Fix:

```bash
conda deactivate 2>/dev/null || true
unset CC CXX LD CPPFLAGS CFLAGS CXXFLAGS LDFLAGS
rm -rf build
```

Then reconfigure from scratch.

### `nvidia-smi` works but runtime errors persist

That typically means:

- toolkit is installed
- host driver is mounted
- but versions or search paths are mismatched

Re-check:

```bash
echo "$PATH"
echo "$LD_LIBRARY_PATH"
which nvcc
nvcc -V
```

## Conda fallback

Use this only if you cannot install system packages:

```bash
conda create -n llama-build -c nvidia -c conda-forge cuda cmake ninja git -y
conda activate llama-build
```

If you go this route, be explicit during CMake configuration and expect more toolchain friction:

```bash
cmake -B build \
  -DGGML_CUDA=ON \
  -DCUDAToolkit_ROOT="$CONDA_PREFIX" \
  -DCMAKE_CUDA_COMPILER="$CONDA_PREFIX/bin/nvcc"
```

For `llama.cpp`, the system install path is still preferable.

## Sources

- NVIDIA CUDA Installation Guide for Linux:
  https://docs.nvidia.com/cuda/cuda-installation-guide-linux/
- NVIDIA Debian 12 CUDA repo:
  https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/
