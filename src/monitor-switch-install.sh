#!/usr/bin/env bash
set -euo pipefail

# Symlink-based installer for monitor-switch assets.
# Ensures repo-managed files are *not copied*, only symlinked.

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

# Source folder for monitor switch files
MONITOR_SWITCH_DIR="${REPO_ROOT}/files-to-copy/monitor-switch"

# Destination locations (user-scoped, best practice on Bazzite)
BIN_DIR="${HOME}/.local/bin"
APP_DIR="${HOME}/.local/share/applications"

# Files to install
MONITOR_SWITCH_FILE="monitor-switch.sh"
MONLG_DESKTOP_FILE="monlg.desktop"
MONSA_DESKTOP_FILE="monsa.desktop"

# Source paths
MONITOR_SWITCH_SRC="${MONITOR_SWITCH_DIR}/${MONITOR_SWITCH_FILE}"
MONLG_DESKTOP_SRC="${MONITOR_SWITCH_DIR}/${MONLG_DESKTOP_FILE}"
MONSA_DESKTOP_SRC="${MONITOR_SWITCH_DIR}/${MONSA_DESKTOP_FILE}"

# Destination paths
MONITOR_SWITCH_DST="${BIN_DIR}/${MONITOR_SWITCH_FILE}"
MONLG_DESKTOP_DST="${APP_DIR}/${MONLG_DESKTOP_FILE}"
MONSA_DESKTOP_DST="${APP_DIR}/${MONSA_DESKTOP_FILE}"

section_header "Installing Monitor Switch"

# Validate sources
log_info "Validating source files..."
for f in "${MONITOR_SWITCH_SRC}" "${MONLG_DESKTOP_SRC}" "${MONSA_DESKTOP_SRC}"; do
  if [[ ! -f "$f" ]]; then
    log_error "Missing source file: $f"
    exit 1
  fi
done
log_success "All source files found"

# Create destinations
mkdir -p "${BIN_DIR}" "${APP_DIR}"

# Symlink assets
log_info "Creating symlinks..."
create_symlink "${MONITOR_SWITCH_SRC}" "${MONITOR_SWITCH_DST}" --chmod-x
create_symlink "${MONLG_DESKTOP_SRC}" "${MONLG_DESKTOP_DST}"
create_symlink "${MONSA_DESKTOP_SRC}" "${MONSA_DESKTOP_DST}"
log_success "Symlinks created"

log_result "Script" "${MONITOR_SWITCH_DST}"
log_result "Launcher (LG)" "${MONLG_DESKTOP_DST}"
log_result "Launcher (SA)" "${MONSA_DESKTOP_DST}"
log_result "CLI Usage" "${MONITOR_SWITCH_DST} lg|sa"
log_result "KRunner" "Type: monlg or monsa"

section_end
