#!/usr/bin/env bash
set -euo pipefail

# kitty-config.sh - Kitty terminal configuration for macOS
#
# This script symlinks the repo-managed kitty config files to ~/.config/kitty/
# Safe to run multiple times (idempotent).
#
# Usage:
#   ./kitty-config.sh
#   (or called from macbook-install.sh)

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

KITTY_CONFIG_DIR="${HOME}/.config/kitty"

# Repo-managed config files (stow-managed: stow/kitty/.config/kitty/)
REPO_KITTY_CONF="${REPO_ROOT}/stow/kitty/.config/kitty/kitty.conf"
REPO_KITTY_THEME="${REPO_ROOT}/stow/kitty/.config/kitty/theme.conf"

section_header "Configuring Kitty terminal"

log_info "Setting up kitty config directory..."
mkdir -p "${KITTY_CONFIG_DIR}"

# Symlink kitty.conf
if [[ -f "${REPO_KITTY_CONF}" ]]; then
  log_info "Symlinking kitty.conf..."
  create_symlink "${REPO_KITTY_CONF}" "${KITTY_CONFIG_DIR}/kitty.conf"
  log_success "kitty.conf configured"
else
  log_warn "kitty.conf not found in repo: ${REPO_KITTY_CONF}"
fi

# Symlink theme.conf
if [[ -f "${REPO_KITTY_THEME}" ]]; then
  log_info "Symlinking theme.conf..."
  create_symlink "${REPO_KITTY_THEME}" "${KITTY_CONFIG_DIR}/theme.conf"
  log_success "theme.conf configured"
else
  log_warn "theme.conf not found in repo: ${REPO_KITTY_THEME}"
fi

log_result "Config location" "${KITTY_CONFIG_DIR}"
log_result "Note" "Restart Kitty to apply configuration"

section_end
