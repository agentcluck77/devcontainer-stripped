#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[bootstrap] $*"
}

# Nothing required here for the base image — all tools are baked in.
# Add workspace-specific setup below as needed.

log "Bootstrap complete."
