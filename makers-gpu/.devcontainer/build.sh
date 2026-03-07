#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[bootstrap] $*"
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="${BREWFILE:-$REPO_ROOT/.devcontainer/Brewfile}"

if command -v brew >/dev/null 2>&1; then
  if [ -f "$BREWFILE" ]; then
    log "Syncing brew packages from Brewfile"
    brew bundle install --file "$BREWFILE"
  else
    log "Brewfile not found at $BREWFILE"
  fi
fi

MINIFORGE_HOME="$HOME/miniforge3"
CONDA_BIN="$MINIFORGE_HOME/bin/conda"
if [ ! -x "$CONDA_BIN" ]; then
  log "Conda binary not found at $CONDA_BIN (base-heavy image should provide it)"
  exit 1
fi

log "Setting PYTHONPATH in base conda env"
"$CONDA_BIN" env config vars set -n base PYTHONPATH=/workspaces/content || true
