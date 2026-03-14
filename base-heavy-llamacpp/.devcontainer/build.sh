#!/usr/bin/env bash
set -euo pipefail

echo "[bootstrap] llama.cpp CUDA image is pre-provisioned."
echo "[bootstrap] llama-cli path: $(command -v llama-cli || echo unavailable)"
