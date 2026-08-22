#!/usr/bin/env bash
set -euo pipefail

# tmux-config.sh - tmux configuration setup
#
# This script symlinks the .tmux.conf config file to ~/.tmux.conf
# so that tmux settings are managed via the repo.
# Safe to run multiple times (idempotent).
# Works on both Linux and macOS.
#
# Usage:
#   ./tmux-config.sh
#   (or called from bazzite-install.sh or macbook-install.sh)

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

# Paths
REPO_TMUX_CONF="${REPO_ROOT}/files-to-copy/dotfiles/.tmux.conf"
TARGET_TMUX_CONF="${HOME}/.tmux.conf"

section_header "Configuring tmux"

# Validate source file exists
if [[ ! -f "${REPO_TMUX_CONF}" ]]; then
  log_error ".tmux.conf not found in repo: ${REPO_TMUX_CONF}"
  exit 1
fi

# Check if already symlinked correctly
if [[ -L "${TARGET_TMUX_CONF}" ]]; then
  current_target="$(readlink "${TARGET_TMUX_CONF}")"
  if [[ "${current_target}" == "${REPO_TMUX_CONF}" ]]; then
    log_skip "Already configured: .tmux.conf symlink exists"
    section_end
    exit 0
  fi
fi

# Create symlink (handles removing existing file/symlink)
log_info "Creating symlink..."
create_symlink "${REPO_TMUX_CONF}" "${TARGET_TMUX_CONF}"
log_success ".tmux.conf symlinked"

log_result "Source" "${REPO_TMUX_CONF}"
log_result "Target" "${TARGET_TMUX_CONF}"
log_result "Note" "Run 'tmux source ~/.tmux.conf' to reload config in active session"

section_end
