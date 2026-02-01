#!/usr/bin/env bash
set -euo pipefail

APP_ID="zoxide"

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

REPO_ZOXIDE_SHELLRC_SNIPPET="${REPO_ROOT}/files-to-copy/dotfiles/shellrc.d/zoxide.sh"

# Target paths
LOCAL_BIN="${HOME}/.local/bin"
ZOXIDE_PATH="${LOCAL_BIN}/zoxide"

section_header "Installing ${APP_ID}"

# Always install/override the shell snippet (even if zoxide is already installed)
log_info "Installing shell integration snippet..."
install_shellrc_snippet "${REPO_ZOXIDE_SHELLRC_SNIPPET}" "zoxide.sh"
log_success "Shell integration configured"

# Install zoxide binary if missing
if is_installed binary "${ZOXIDE_PATH}"; then
  log_skip "Already installed: ${APP_ID}"
  log_result "Binary" "${ZOXIDE_PATH}"
  log_result "Version" "$("${ZOXIDE_PATH}" --version || true)"
  section_end
  exit 0
fi

log_info "Checking dependencies..."
check_dependency curl
log_success "Dependencies satisfied"

mkdir -p "${LOCAL_BIN}"

# Official installer: installs into ~/.local/bin by default
export XDG_BIN_HOME="${LOCAL_BIN}"

log_info "Downloading and installing ${APP_ID}..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

if [[ ! -x "${ZOXIDE_PATH}" ]]; then
  log_error "zoxide was not installed at expected location: ${ZOXIDE_PATH}"
  exit 1
fi

log_success "Installation complete"
log_result "Binary" "${ZOXIDE_PATH}"
log_result "Version" "$("${ZOXIDE_PATH}" --version || true)"
log_result "Note" "Restart terminal or source your shell rc file"

section_end
