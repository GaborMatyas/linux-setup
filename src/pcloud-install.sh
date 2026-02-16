#!/usr/bin/env bash
set -euo pipefail

APP_ID="pcloud"
PCLOUD_DOWNLOAD_PAGE="https://www.pcloud.com/download-free-online-cloud-file-storage.html"

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

# Repo-managed desktop entry
REPO_DESKTOP_ENTRY="${REPO_ROOT}/files-to-copy/desktop-entries/pcloud.desktop"

# Installation paths
LOCAL_BIN="${HOME}/.local/bin"
PCLOUD_BIN="${LOCAL_BIN}/pcloud"
DESKTOP_DIR="${HOME}/.local/share/applications"
DESKTOP_FILE="${DESKTOP_DIR}/pcloud.desktop"

section_header "Installing pCloud (Official Client)"

# Check if pCloud binary exists
if is_installed binary "${PCLOUD_BIN}"; then
  log_skip "pCloud binary already installed"
  log_result "Binary" "${PCLOUD_BIN}"
else

# Check dependencies
log_info "Checking dependencies..."
check_dependency wget
log_success "Dependencies satisfied"

# Create directories
mkdir -p "${LOCAL_BIN}"
mkdir -p "${DESKTOP_DIR}"

# Check if user has already downloaded pCloud manually
if [[ -f "${PCLOUD_BIN}" && -x "${PCLOUD_BIN}" ]]; then
  log_info "Found existing pCloud binary"
  log_success "pCloud already available"
else
  log_warn "pCloud AppImage must be downloaded manually"
  echo
  log_result "Why manual?" "pCloud uses temporary CDN URLs that expire frequently"
  log_result "Download from" "${PCLOUD_DOWNLOAD_PAGE}"
  echo
  log_info "Instructions:"
  echo "  1. Visit: ${PCLOUD_DOWNLOAD_PAGE}"
  echo "  2. Click 'Download' under 'pCloud Drive for Linux'"
  echo "  3. Save the downloaded file (AppImage) to: ${PCLOUD_BIN}"
  echo "  4. Run this installer again"
  echo
  log_warn "Quick commands (after downloading to ~/Downloads/pcloud):"
  echo "  mv ~/Downloads/pcloud ${PCLOUD_BIN}"
  echo "  chmod +x ${PCLOUD_BIN}"
  echo "  ./bazzite-install.sh  # or ./src/pcloud-install.sh"
  echo
  log_error "pCloud not found at: ${PCLOUD_BIN}"
  section_end
  exit 1
fi
fi

# Create desktop entry via symlink (repo-managed)
log_info "Creating desktop entry..."
if [[ ! -f "${REPO_DESKTOP_ENTRY}" ]]; then
  log_error "Missing repo desktop entry: ${REPO_DESKTOP_ENTRY}"
  log_warn "Expected at: files-to-copy/desktop-entries/pcloud.desktop"
  exit 1
fi

mkdir -p "${DESKTOP_DIR}"
create_symlink "${REPO_DESKTOP_ENTRY}" "${DESKTOP_FILE}"
log_success "Desktop entry created (repo-managed via symlink)"

# Validate installation
if [[ ! -x "${PCLOUD_BIN}" ]]; then
  log_error "pCloud binary is not executable: ${PCLOUD_BIN}"
  exit 1
fi

log_success "Installation complete"
log_result "Binary" "${PCLOUD_BIN}"
log_result "Launch command" "pcloud"
log_result "Desktop entry" "Find 'pCloud' in application menu"
log_result "Note" "Official pCloud client (AppImage)"

log_warn "First run: pCloud will download additional components"
log_warn "To start on login: Add pCloud to KDE autostart applications"

section_end
