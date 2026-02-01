#!/usr/bin/env bash
#
# macbook-install.sh - macOS Setup Installer
#
# This script installs and configures applications and settings
# specifically for macOS.
#
# Usage:
#   ./macbook-install.sh
#
# Part of linux-setup repository - multi-OS dotfiles and configurations
# For other operating systems, see:
#   - bazzite-install.sh (Bazzite Linux)
#
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SRC_DIR="$(cd -- "${SCRIPT_DIR}/src" &>/dev/null && pwd)"

# Source common utilities (includes run_helper_script)
source "${SRC_DIR}/utils/common.sh"

# Mac-specific helper scripts
HOMEBREW_INSTALLER_SCRIPT="${SRC_DIR}/mac/homebrew-install.sh"
BREW_PACKAGES_INSTALLER_SCRIPT="${SRC_DIR}/mac/brew-packages-install.sh"
BREW_CASKS_INSTALLER_SCRIPT="${SRC_DIR}/mac/brew-casks-install.sh"
STATS_CONFIG_SCRIPT="${SRC_DIR}/mac/stats-config.sh"

echo
echo "=========================================="
echo "  macOS Setup Installer"
echo "=========================================="

# --- Helper scripts ---
run_helper_script "${HOMEBREW_INSTALLER_SCRIPT}" "Homebrew installer"
run_helper_script "${BREW_PACKAGES_INSTALLER_SCRIPT}" "Homebrew packages installer"
run_helper_script "${BREW_CASKS_INSTALLER_SCRIPT}" "Homebrew Cask applications installer"
run_helper_script "${STATS_CONFIG_SCRIPT}" "Stats app configuration"

echo
echo "==> Done."
echo "==> macOS setup complete."
