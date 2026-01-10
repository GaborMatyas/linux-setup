#!/usr/bin/env bash
set -euo pipefail
# This script configures KDE global shortcuts:
# - Switch keyboard layout: Meta+Space
# - KRunner: Ctrl+Space (instead of Alt+Space)
#
# NOTE: This script does NOT attempt to reload KDE shortcut services.
# The changes will take effect after logging out/in or rebooting.

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

CONFIG_FILE="${HOME}/.config/kglobalshortcutsrc"

# 1) Keyboard layout switching
KEYBOARD_LAYOUT_KEY_NAME="Switch to Next Keyboard Layout"
KEYBOARD_LAYOUT_SHORTCUT="Meta+Space"

# 2) KRunner shortcut (Plasma 6 format)
KRUNNER_SECTION_HEADER="[services][org.kde.krunner.desktop]"
KRUNNER_KEY="_launch"
# Keep Alt+F2 as fallback; remove Alt+Space by omitting it
KRUNNER_VALUE="Ctrl+Space\tSearch\tAlt+F2"

section_header "Configuring KDE Global Shortcuts"

log_info "Target file: ${CONFIG_FILE}"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  log_error "KDE shortcuts config file not found: ${CONFIG_FILE}"
  exit 1
fi

# ----------------------------
# Keyboard layout shortcut
# ----------------------------
log_info "Setting keyboard layout shortcut: ${KEYBOARD_LAYOUT_SHORTCUT}"

if ! grep -q "^${KEYBOARD_LAYOUT_KEY_NAME}=" "${CONFIG_FILE}"; then
  log_error "Key not found in ${CONFIG_FILE}: ${KEYBOARD_LAYOUT_KEY_NAME}"
  log_warn "Run: grep -n \"${KEYBOARD_LAYOUT_KEY_NAME}\" ${CONFIG_FILE}"
  exit 1
fi

# KDE shortcut format for this entry: <active>,<default>,<description>
sed -i \
  "s|^${KEYBOARD_LAYOUT_KEY_NAME}=.*|${KEYBOARD_LAYOUT_KEY_NAME}=${KEYBOARD_LAYOUT_SHORTCUT},${KEYBOARD_LAYOUT_SHORTCUT},${KEYBOARD_LAYOUT_KEY_NAME}|" \
  "${CONFIG_FILE}"

log_success "Keyboard layout shortcut updated"
log_result "Line" "$(grep -n "^${KEYBOARD_LAYOUT_KEY_NAME}=" "${CONFIG_FILE}")"

# ----------------------------
# KRunner shortcut
# ----------------------------
log_info "Setting KRunner shortcut: Ctrl+Space"

# Ensure section exists; if not, append it
if ! grep -q "^\[services\]\[org\.kde\.krunner\.desktop\]$" "${CONFIG_FILE}"; then
  log_info "KRunner section not found, adding it..."
  printf "\n%s\n" "${KRUNNER_SECTION_HEADER}" >> "${CONFIG_FILE}"
  log_success "Section added"
fi

# Replace or insert the key under the section header.
awk -v section="${KRUNNER_SECTION_HEADER}" -v key="${KRUNNER_KEY}" -v value="${KRUNNER_VALUE}" '
  BEGIN { in_section=0; key_written=0 }
  $0 == section { in_section=1; print; next }
  /^\[/ {
    if (in_section && !key_written) {
      print key "=" value
      key_written=1
    }
    in_section=0
    print
    next
  }
  in_section && $0 ~ ("^" key "=") {
    print key "=" value
    key_written=1
    next
  }
  { print }
  END {
    if (in_section && !key_written) {
      print key "=" value
    }
  }
' "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp"

mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

log_success "KRunner shortcut updated"
log_result "Line" "$(sed -n "/^\[services\]\[org\.kde\.krunner\.desktop\]$/,/^\[/p" "${CONFIG_FILE}" | grep -n "^${KRUNNER_KEY}=" || true)"

log_warn "Changes take effect after logout/reboot"

section_end
