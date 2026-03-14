#!/usr/bin/env bash
set -euo pipefail

echo "[bootstrap] GPU CUDA toolkit image is pre-provisioned."
echo "[bootstrap] nvcc path: $(command -v nvcc || echo unavailable)"
