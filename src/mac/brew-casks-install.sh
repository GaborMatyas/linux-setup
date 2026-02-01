#!/usr/bin/env bash
set -euo pipefail

# brew-casks-install.sh - Homebrew Cask applications installer for macOS
#
# This script installs GUI applications via Homebrew Cask.
# Safe to run multiple times (idempotent).
#
# Usage:
#   ./brew-casks-install.sh
#   (or called from macbook-install.sh)

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

# Casks to install: "cask_name:App Name.app"
# The app name is used to check /Applications for manual installs
CASKS=(
  "slack:Slack.app"
  "obsidian:Obsidian.app"
  "visual-studio-code:Visual Studio Code.app"
  "vlc:VLC.app"
  "rectangle:Rectangle.app"
  "discord:Discord.app"
  "firefox@developer-edition:Firefox Developer Edition.app"
  "obs:OBS.app"
  "google-chrome:Google Chrome.app"
  "microsoft-edge:Microsoft Edge.app"
  "alt-tab:AltTab.app"
  "raycast:Raycast.app"
  "stats:Stats.app"
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

# install_brew_cask <cask_name> <app_name>
# Installs a Homebrew Cask application if not already installed.
# Idempotent: skips if cask is already present (via brew or in /Applications).
install_brew_cask() {
  local cask="$1"
  local app_name="$2"

  # Check if brew already knows about it
  if brew list --cask "${cask}" &>/dev/null; then
    log_skip "Already installed (brew): ${cask}"
    return 0
  fi

  # Check if app exists in /Applications (installed manually)
  if [[ -d "/Applications/${app_name}" ]]; then
    log_skip "Already installed (manual): ${cask}"
    return 0
  fi

  log_info "Installing ${cask}..."
  brew install --cask "${cask}"
  log_success "Installed ${cask}"
}

# =============================================================================
# Main
# =============================================================================

section_header "Installing Homebrew Cask applications"

require_homebrew

for entry in "${CASKS[@]}"; do
  cask="${entry%%:*}"
  app_name="${entry##*:}"
  install_brew_cask "${cask}" "${app_name}"
done

section_end
