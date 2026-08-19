#!/usr/bin/env bash
set -euo pipefail

# homebrew-install.sh - Homebrew package manager installer for macOS
#
# This script installs Homebrew if not already present.
# Safe to run multiple times (idempotent).
#
# Usage:
#   ./homebrew-install.sh
#   (or called from macbook-install.sh)

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

section_header "Installing Homebrew"

# Check if Homebrew is already installed
if is_installed command brew; then
  log_skip "Already installed: Homebrew"
  log_result "Binary" "$(command -v brew)"
  log_result "Version" "$(brew --version | head -n1)"
  section_end
  exit 0
fi

# Check dependencies
log_info "Checking dependencies..."
check_dependency curl "curl is required to install Homebrew"
log_success "Dependencies satisfied"

# Install Homebrew using the official installer
log_info "Running Homebrew installer..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# After installation, add brew to PATH for the current session
# Homebrew installs to different locations based on architecture
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # Apple Silicon
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  # Intel Mac
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Verify installation
if is_installed command brew; then
  log_success "Homebrew installed successfully"
  log_result "Binary" "$(command -v brew)"
  log_result "Version" "$(brew --version | head -n1)"
  log_result "Note" "Add 'eval \"\$(brew shellenv)\"' to your ~/.zshrc if not already present"
else
  log_error "Homebrew installation failed"
  exit 1
fi

section_end
