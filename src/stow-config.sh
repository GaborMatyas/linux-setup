#!/usr/bin/env bash
# stow-config.sh - Configure stow symlinks for dotfiles

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

STOW_DIR="${REPO_ROOT}/stow"
TARGET_DIR="${HOME}"

section_header "Configuring stow symlinks"

# Run stow to create symlinks
log_info "Running: stow -t ${TARGET_DIR} -d ${STOW_DIR}"
cd "${STOW_DIR}"
stow -t "${TARGET_DIR}" -d "${STOW_DIR}"

if [ $? -eq 0 ]; then
  log_success "Stow configuration complete"
  log_result "Dotfiles location" "${TARGET_DIR}"
else
  log_error "Stow failed"
  section_end
  exit 1
fi

section_end