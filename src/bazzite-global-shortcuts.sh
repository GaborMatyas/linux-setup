#!/usr/bin/env bash
set -euo pipefail
# This script configures KDE global shortcuts:
# - Switch keyboard layout: Meta+Space
# - KRunner: Ctrl+Space (instead of Alt+Space)

CONFIG_FILE="${HOME}/.config/kglobalshortcutsrc"

# 1) Keyboard layout switching
KEYBOARD_LAYOUT_KEY_NAME="Switch to Next Keyboard Layout"
KEYBOARD_LAYOUT_SHORTCUT="Meta+Space"

# 2) KRunner shortcut (Plasma 6 format)
KRUNNER_SECTION_HEADER="[services][org.kde.krunner.desktop]"
KRUNNER_KEY="_launch"
# Keep Alt+F2 as fallback; remove Alt+Space by omitting it
KRUNNER_VALUE="Ctrl+Space\tSearch\tAlt+F2"

# Message helpers
ok()   { echo "✅ $*"; }
warn() { echo "❗ $*"; }
info() { echo "==> $*"; }

echo
info "Configuring KDE global shortcuts..."
info "Target file: ${CONFIG_FILE}"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  warn "KDE shortcuts config file not found: ${CONFIG_FILE}"
  exit 1
fi

# ----------------------------
# Keyboard layout shortcut
# ----------------------------
echo
info "Setting '${KEYBOARD_LAYOUT_KEY_NAME}' to: ${KEYBOARD_LAYOUT_SHORTCUT}"

if ! grep -q "^${KEYBOARD_LAYOUT_KEY_NAME}=" "${CONFIG_FILE}"; then
  warn "Key not found in ${CONFIG_FILE}: ${KEYBOARD_LAYOUT_KEY_NAME}"
  warn "TIP: Run: grep -n \"${KEYBOARD_LAYOUT_KEY_NAME}\" ${CONFIG_FILE}"
  exit 1
fi

# Update line deterministically:
# KDE shortcut format for this entry: <active>,<default>,<description>
sed -i \
  "s|^${KEYBOARD_LAYOUT_KEY_NAME}=.*|${KEYBOARD_LAYOUT_KEY_NAME}=${KEYBOARD_LAYOUT_SHORTCUT},${KEYBOARD_LAYOUT_SHORTCUT},${KEYBOARD_LAYOUT_KEY_NAME}|" \
  "${CONFIG_FILE}"

ok "Updated keyboard layout shortcut:"
grep -n "^${KEYBOARD_LAYOUT_KEY_NAME}=" "${CONFIG_FILE}"


# ----------------------------
# KRunner shortcut
# ----------------------------
echo
info "Setting KRunner shortcut to: Ctrl+Space"
info "Target section: ${KRUNNER_SECTION_HEADER}"
info "Setting: ${KRUNNER_KEY}=${KRUNNER_VALUE}"

# Ensure section exists; if not, append it
if ! grep -q "^\[services\]\[org\.kde\.krunner\.desktop\]$" "${CONFIG_FILE}"; then
  info "KRunner section not found, adding it..."
  printf "\n%s\n" "${KRUNNER_SECTION_HEADER}" >> "${CONFIG_FILE}"
  ok "Added section: ${KRUNNER_SECTION_HEADER}"
fi

# Replace or insert the key under the section header.
# This is safe with set -euo pipefail and works even if the key is missing.
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

ok "Updated KRunner shortcut line:"
sed -n "/^\[services\]\[org\.kde\.krunner\.desktop\]$/,/^\[/p" "${CONFIG_FILE}" | grep -n "^${KRUNNER_KEY}=" || true


# ----------------------------
# Reload KDE global shortcuts
# ----------------------------
echo
info "Reloading KDE global shortcuts so changes apply..."

if command -v kquitapp6 >/dev/null 2>&1 && command -v kglobalaccel6 >/dev/null 2>&1; then
  info "Reloading via kquitapp6/kglobalaccel6..."
  kquitapp6 kglobalaccel >/dev/null 2>&1 || true
  kglobalaccel6 >/dev/null 2>&1 &
  disown || true
  ok "KDE global shortcuts reloaded (kglobalaccel)."

echo
ok "KDE shortcut configuration complete."
