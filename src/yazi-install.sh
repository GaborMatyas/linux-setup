#!/usr/bin/env bash
set -euo pipefail

APP_ID="yazi"
FLATPAK_APP_ID="io.github.sxyazi.yazi"

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

# Repo-managed wrapper
YAZI_WRAPPER_SRC="${REPO_ROOT}/files-to-copy/bin/yazi"

# Target paths
LOCAL_BIN="${HOME}/.local/bin"
TARGET_WRAPPER="${LOCAL_BIN}/yazi"

section_header "Installing ${APP_ID} CLI Wrapper"

# Validate flatpak exists
log_info "Checking dependencies..."
check_dependency flatpak
log_success "Flatpak available"

# Validate yazi flatpak exists
log_info "Checking for yazi flatpak..."
if ! is_installed flatpak "${FLATPAK_APP_ID}"; then
  log_error "Flatpak not installed: ${FLATPAK_APP_ID}"
  log_warn "Add it to your APPS array in install.sh and rerun"
  exit 1
fi
log_success "Yazi flatpak found"

mkdir -p "${LOCAL_BIN}"

# Validate wrapper file exists in repo
if [[ ! -f "${YAZI_WRAPPER_SRC}" ]]; then
  log_error "Missing repo wrapper: ${YAZI_WRAPPER_SRC}"
  log_result "Expected at" "files-to-copy/bin/yazi"
  exit 1
fi

# Symlink wrapper and ensure source is executable
log_info "Creating wrapper symlink..."
create_symlink "${YAZI_WRAPPER_SRC}" "${TARGET_WRAPPER}" --chmod-x
log_success "Wrapper installed"
log_result "Source" "${YAZI_WRAPPER_SRC}"
log_result "Target" "${TARGET_WRAPPER}"

# Validate wrapper exists and is executable
if [[ ! -x "${TARGET_WRAPPER}" ]]; then
  log_error "Wrapper is not executable: ${TARGET_WRAPPER}"
  log_warn "Ensure repo file is executable: chmod +x ${YAZI_WRAPPER_SRC}"
  exit 1
fi

# Verify Flatpak installation
log_info "Verifying Flatpak installation..."
if ! flatpak run "${FLATPAK_APP_ID}" --version >/dev/null 2>&1; then
  log_error "Flatpak exists but failed to run: ${FLATPAK_APP_ID}"
  log_warn "Try manually: flatpak run ${FLATPAK_APP_ID} --version"
  exit 1
fi

log_success "Wrapper configured successfully"
log_result "Run" "yazi"

section_end
