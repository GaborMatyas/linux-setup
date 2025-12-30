#!/usr/bin/env bash
set -euo pipefail
# This file sets the Meta(Win)+Space keys as shurtcut for switching system language


CONFIG_FILE="${HOME}/.config/kglobalshortcutsrc"

KEY_NAME="Switch to Next Keyboard Layout"
SHORTCUT="Meta+Space"

echo
echo "==> Configuring KDE global shortcuts..."
echo "==> Target file: ${CONFIG_FILE}"
echo "==> Setting '${KEY_NAME}' to: ${SHORTCUT}"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "ERROR: KDE shortcuts config file not found: ${CONFIG_FILE}"
  exit 1
fi

# Ensure the key exists (prevents silent failure)
if ! grep -q "^${KEY_NAME}=" "${CONFIG_FILE}"; then
  echo "ERROR: Key not found in ${CONFIG_FILE}: ${KEY_NAME}"
  echo "TIP: Run: grep -n \"${KEY_NAME}\" ${CONFIG_FILE}"
  exit 1
fi

# Backup before editing
BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
cp -a "${CONFIG_FILE}" "${BACKUP_FILE}"
echo "==> Backup created: ${BACKUP_FILE}"

# Update the line deterministically
# KDE shortcut format: <active>,<default>,<description>
sed -i \
  "s|^${KEY_NAME}=.*|${KEY_NAME}=${SHORTCUT},${SHORTCUT},${KEY_NAME}|" \
  "${CONFIG_FILE}"

echo "==> Updated line:"
grep -n "^${KEY_NAME}=" "${CONFIG_FILE}"

# Reload KDE global shortcuts so changes apply immediately
if command -v kquitapp6 >/dev/null 2>&1 && command -v kglobalaccel6 >/dev/null 2>&1; then
  echo "==> Reloading KDE global shortcuts service (kglobalaccel)..."
  kquitapp6 kglobalaccel >/dev/null 2>&1 || true
  kglobalaccel6 >/dev/null 2>&1 &
  disown || true
else
  echo "==> NOTE: kquitapp6/kglobalaccel6 not found; log out and back in to apply changes."
fi

echo "==> KDE shortcut configuration complete."
