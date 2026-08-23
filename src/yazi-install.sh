#!/usr/bin/env bash
set -euo pipefail

# yazi-install.sh - Verify Yazi Flatpak installation for Bazzite
#
# The `yazi` CLI wrapper is managed separately by stow-config.sh:
#   stow/yazi/.local/bin/yazi -> ~/.local/bin/yazi
#
# This script only verifies that the backing Flatpak is installed
# and runnable.

APP_ID="yazi"
FLATPAK_APP_ID="io.github.sxyazi.yazi"

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

section_header "Checking ${APP_ID} CLI"

# Validate Flatpak CLI exists
log_info "Checking dependencies..."
check_dependency flatpak
log_success "Flatpak available"

# Validate Yazi Flatpak exists
log_info "Checking for Yazi Flatpak..."
if ! is_installed flatpak "${FLATPAK_APP_ID}"; then
  log_error "Flatpak not installed: ${FLATPAK_APP_ID}"
  log_warn "Install it with: flatpak install flathub ${FLATPAK_APP_ID}"
  exit 1
fi

log_success "Yazi Flatpak found"

# Verify Flatpak application runs
log_info "Verifying Yazi Flatpak..."
if ! flatpak run "${FLATPAK_APP_ID}" --version >/dev/null 2>&1; then
  log_error "Flatpak exists but failed to run: ${FLATPAK_APP_ID}"
  log_warn "Try manually: flatpak run ${FLATPAK_APP_ID} --version"
  exit 1
fi

log_success "Yazi Flatpak runs successfully"
log_result "Run" "yazi"

section_end
