#!/usr/bin/env bash
set -euo pipefail

APP_ID="tmux"
BREW_PREFIX="/home/linuxbrew/.linuxbrew"

echo
echo "==> Installing ${APP_ID}..."

# Ensure brew is available
if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: 'brew' is not installed or not in PATH."
  echo "Expected Linuxbrew prefix: ${BREW_PREFIX}"
  echo "TIP: Ensure brew is installed and available, e.g.: ${BREW_PREFIX}/bin/brew"
  exit 1
fi

# Ensure brew is the expected Linuxbrew (optional but useful safety check)
ACTUAL_PREFIX="$(brew --prefix 2>/dev/null || true)"
if [[ -n "${ACTUAL_PREFIX}" && "${ACTUAL_PREFIX}" != "${BREW_PREFIX}" ]]; then
  echo "WARNING: brew prefix differs from expected."
  echo "==> Expected: ${BREW_PREFIX}"
  echo "==> Actual:   ${ACTUAL_PREFIX}"
fi

# If tmux already exists, skip install
if command -v tmux >/dev/null 2>&1; then
  echo "==> Already installed: ${APP_ID} (skipping)"
  echo "==> Version: $(tmux -V || true)"
  echo "==> Binary: $(command -v tmux)"
  exit 0
fi

echo "==> Installing ${APP_ID} via brew..."
brew install tmux

# Validate installation
if ! command -v tmux >/dev/null 2>&1; then
  echo "ERROR: ${APP_ID} installation finished, but 'tmux' is still not found on PATH."
  echo "==> Brew prefix: $(brew --prefix)"
  echo "==> TIP: Ensure brew shellenv is loaded in bash (e.g. eval \"\$(brew shellenv)\")"
  exit 1
fi

echo
echo "==> ${APP_ID} installed successfully."
echo "==> Version: $(tmux -V || true)"
echo "==> Binary: $(command -v tmux)"
