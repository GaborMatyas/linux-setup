#!/usr/bin/env bash
set -euo pipefail

# brew-packages-install.sh - Homebrew packages installer for macOS
#
# This script installs CLI packages via Homebrew and sets up shell integration.
# Safe to run multiple times (idempotent).
#
# Usage:
#   ./brew-packages-install.sh
#   (or called from macbook-install.sh)

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

# Shell snippet paths (works for both bash and zsh)
REPO_FZF_SHELLRC_SNIPPET="${REPO_ROOT}/files-to-copy/dotfiles/shellrc.d/fzf.sh"
REPO_ZOXIDE_SHELLRC_SNIPPET="${REPO_ROOT}/files-to-copy/dotfiles/shellrc.d/zoxide.sh"

PACKAGES=(
  git
  zoxide
  fzf
  fd
  ripgrep
)

# =============================================================================
# Functions
# =============================================================================

# require_homebrew
# Checks if Homebrew is installed and available.
# Exits with error if not found.
require_homebrew() {
  if ! is_installed command brew; then
    log_error "Homebrew is not installed. Please run homebrew-install.sh first."
    exit 1
  fi
}

# install_brew_package <package_name>
# Installs a Homebrew package if not already installed.
# Idempotent: skips if package is already present.
install_brew_package() {
  local package="$1"

  if brew list "${package}" &>/dev/null; then
    log_skip "Already installed: ${package}"
  else
    log_info "Installing ${package}..."
    brew install "${package}"
    log_success "Installed ${package}"
  fi
}

# =============================================================================
# Main
# =============================================================================

section_header "Installing Homebrew packages"

require_homebrew

for package in "${PACKAGES[@]}"; do
  install_brew_package "${package}"
done

section_end

# --- Shell integration snippets ---

section_header "Configuring shell integration"

log_info "Installing fzf shell snippet..."
install_shellrc_snippet "${REPO_FZF_SHELLRC_SNIPPET}" "fzf.sh"
log_success "fzf shell integration configured"

log_info "Installing zoxide shell snippet..."
install_shellrc_snippet "${REPO_ZOXIDE_SHELLRC_SNIPPET}" "zoxide.sh"
log_success "zoxide shell integration configured"

log_result "Snippets location" "${HOME}/.shellrc.d/"
log_result "Note" "Add 'for f in ~/.shellrc.d/*.sh; do source \"\$f\"; done' to ~/.zshrc"

section_end
