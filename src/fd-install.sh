#!/usr/bin/env bash
set -euo pipefail

APP_ID="fd"
BIN_NAME="fd"

LOCAL_BIN="${HOME}/.local/bin"
FD_BIN="${LOCAL_BIN}/${BIN_NAME}"

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

section_header "Installing ${APP_ID}"

# Check if already installed
if is_installed binary "${FD_BIN}"; then
  log_skip "Already installed: ${APP_ID}"
  log_result "Binary" "${FD_BIN}"
  log_result "Version" "$("${FD_BIN}" --version | head -n1 || true)"
  section_end
  exit 0
fi

# Check dependencies
log_info "Checking dependencies..."
check_dependency curl
check_dependency tar
log_success "Dependencies satisfied"

mkdir -p "${LOCAL_BIN}"

# Detect architecture
log_info "Detecting system architecture..."
PLATFORM="$(detect_architecture fd)"
log_success "Architecture: ${PLATFORM}"

# Fetch latest release
log_info "Fetching latest release from GitHub..."
DOWNLOAD_URL="$(fetch_github_release sharkdp fd "fd-v[0-9]+\.[0-9]+\.[0-9]+-${PLATFORM}\.tar\.gz")"
log_success "Found release"

# Download and extract
log_info "Downloading and extracting..."
TMP_DIR="$(create_temp_dir)"
download_and_extract "${DOWNLOAD_URL}" "${TMP_DIR}"
log_success "Download complete"

# Find extracted directory
EXTRACTED_DIR="$(find "${TMP_DIR}" -maxdepth 1 -type d -name "fd-v*-*" | head -n1)"
if [[ -z "${EXTRACTED_DIR}" ]]; then
  log_error "Could not locate extracted fd directory"
  exit 1
fi

if [[ ! -f "${EXTRACTED_DIR}/fd" ]]; then
  log_error "Extracted tarball does not contain 'fd' binary as expected"
  exit 1
fi

# Install binary
log_info "Installing binary..."
install_binary "${EXTRACTED_DIR}/fd" "${FD_BIN}"
log_success "Installation complete"

log_result "Binary" "${FD_BIN}"
log_result "Version" "$("${FD_BIN}" --version | head -n1 || true)"

section_end
