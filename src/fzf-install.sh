#!/usr/bin/env bash
set -euo pipefail

APP_ID="fzf"

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

REPO_FZF_SHELLRC_SNIPPET="${REPO_ROOT}/files-to-copy/dotfiles/shellrc.d/fzf.sh"

# Install location
LOCAL_BIN="${HOME}/.local/bin"
FZF_BIN="${LOCAL_BIN}/fzf"

section_header "Installing ${APP_ID}"

# Always install/override shell integration snippet (repo-managed)
log_info "Installing shell integration snippet..."
install_shellrc_snippet "${REPO_FZF_SHELLRC_SNIPPET}" "fzf.sh"
log_success "Shell integration configured"

# If fzf exists, we still refreshed the snippet and can stop
if is_installed binary "${FZF_BIN}"; then
  log_skip "Already installed: ${APP_ID}"
  log_result "Binary" "${FZF_BIN}"
  log_result "Version" "$("${FZF_BIN}" --version | head -n1 || true)"
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
PLATFORM="$(detect_architecture fzf)"
log_success "Architecture: ${PLATFORM}"

# Fetch latest release
log_info "Fetching latest release from GitHub..."
DOWNLOAD_URL="$(fetch_github_release junegunn fzf "fzf-[0-9]+\.[0-9]+\.[0-9]+-${PLATFORM}\.tar\.gz")"
log_success "Found release"

# Download and extract
log_info "Downloading and extracting..."
TMP_DIR="$(create_temp_dir)"
download_and_extract "${DOWNLOAD_URL}" "${TMP_DIR}"
log_success "Download complete"

# The tarball contains the 'fzf' binary at top level
if [[ ! -f "${TMP_DIR}/fzf" ]]; then
  log_error "Extracted tarball does not contain fzf binary as expected"
  exit 1
fi

# Install binary
log_info "Installing binary..."
install_binary "${TMP_DIR}/fzf" "${FZF_BIN}"
log_success "Installation complete"

log_result "Binary" "${FZF_BIN}"
log_result "Version" "$("${FZF_BIN}" --version | head -n1 || true)"
log_result "Note" "Restart terminal or source your shell rc file"

section_end
