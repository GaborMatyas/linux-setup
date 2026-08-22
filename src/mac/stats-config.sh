#!/usr/bin/env bash
set -euo pipefail

# stats-config.sh - Stats app configuration for macOS
#
# This script symlinks the Stats.plist config file to ~/Library/Preferences/
# so that Stats app settings are managed via the repo.
# Safe to run multiple times (idempotent).
#
# Usage:
#   ./stats-config.sh
#   (or called from macbook-install.sh)

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

# Paths
REPO_STATS_PLIST="${REPO_ROOT}/files-to-copy/dotfiles/mac/Stats.plist"
TARGET_STATS_PLIST="${HOME}/Library/Preferences/eu.exelban.Stats.plist"

section_header "Configuring Stats app"

# Validate source file exists
if [[ ! -f "${REPO_STATS_PLIST}" ]]; then
  log_error "Stats.plist not found in repo: ${REPO_STATS_PLIST}"
  exit 1
fi

# Check if already symlinked correctly
if [[ -L "${TARGET_STATS_PLIST}" ]]; then
  current_target="$(readlink "${TARGET_STATS_PLIST}")"
  if [[ "${current_target}" == "${REPO_STATS_PLIST}" ]]; then
    log_skip "Already configured: Stats.plist symlink exists"
    section_end
    exit 0
  fi
fi

# Remove existing file or symlink
if [[ -e "${TARGET_STATS_PLIST}" ]] || [[ -L "${TARGET_STATS_PLIST}" ]]; then
  log_info "Removing existing Stats.plist..."
  rm "${TARGET_STATS_PLIST}"
fi

# Create symlink
log_info "Creating symlink..."
ln -s "${REPO_STATS_PLIST}" "${TARGET_STATS_PLIST}"
log_success "Stats.plist symlinked"

log_result "Source" "${REPO_STATS_PLIST}"
log_result "Target" "${TARGET_STATS_PLIST}"
log_result "Note" "Restart Stats app to apply settings"

section_end
