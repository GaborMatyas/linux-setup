#!/usr/bin/env bash
set -euo pipefail

REMOTE_NAME="flathub"
PCLOUD_CLIENT_APP_ID="io.kapsa.drive"   # S3Drive

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

section_header "Installing pCloud Client"

# If already installed, skip
if is_installed flatpak "${PCLOUD_CLIENT_APP_ID}"; then
  log_skip "Already installed: ${PCLOUD_CLIENT_APP_ID}"
  log_result "Launch command" "flatpak run ${PCLOUD_CLIENT_APP_ID}"
  section_end
  exit 0
fi

log_info "Installing: ${PCLOUD_CLIENT_APP_ID}"
flatpak install -y "${REMOTE_NAME}" "${PCLOUD_CLIENT_APP_ID}"
log_success "Installation complete"

log_result "App" "S3Drive (pCloud client)"
log_result "Launch command" "flatpak run ${PCLOUD_CLIENT_APP_ID}"
log_result "Note" "Log in with alternative pCloud service"

section_end
