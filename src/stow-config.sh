#!/usr/bin/env bash
# stow-config.sh - Configure stow symlinks for dotfiles

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

STOW_DIR="${REPO_ROOT}/stow"
TARGET_DIR="${HOME}"

section_header "Configuring stow symlinks"

# Iterate through all packages in stow/ directory
log_info "Discovering stow packages..."
cd "${STOW_DIR}"
for package in */; do
    if [ -d "$package" ]; then
        log_info "Stowing: ${package%/}"
        # stow requires parent directories to exist in the target (no
        # flag creates them, in 1.x or 2.x) — create them explicitly here.
        ( cd "${STOW_DIR}/${package%/}" \
          && find . -type f -exec dirname {} + | sort -u | xargs -r -I{} mkdir -p -- "${TARGET_DIR}/{}" )
        stow -t "${TARGET_DIR}" -d "${STOW_DIR}" "${package%/}"
    fi
done

if [ $? -eq 0 ]; then
  log_success "Stow configuration complete"
else
  log_error "Stow failed"
  section_end
  exit 1
fi

section_end