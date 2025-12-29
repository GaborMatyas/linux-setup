#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Source folder for monitor switch files
MONITOR_SWITCH_DIR="${SCRIPT_DIR}/../files-to-copy/monitor-switch"

# Destination locations (user-scoped, best practice on Bazzite)
BIN_DIR="${HOME}/.local/bin"
APP_DIR="${HOME}/.local/share/applications"

# Files to install
MONITOR_SWITCH_FILE="monitor-switch.sh"
MONITOR_SWITCH_SRC="${MONITOR_SWITCH_DIR}/${MONITOR_SWITCH_FILE}"
MONITOR_SWITCH_DST="${BIN_DIR}/${MONITOR_SWITCH_FILE}"

MONLG_DESKTOP_FILE="monlg.desktop"
MONSA_DESKTOP_FILE="monsa.desktop"

MONLG_DESKTOP_SRC="${MONITOR_SWITCH_DIR}/${MONLG_DESKTOP_FILE}"
MONSA_DESKTOP_SRC="${MONITOR_SWITCH_DIR}/${MONSA_DESKTOP_FILE}"

MONLG_DESKTOP_DST="${APP_DIR}/${MONLG_DESKTOP_FILE}"
MONSA_DESKTOP_DST="${APP_DIR}/${MONSA_DESKTOP_FILE}"

ensure_dir() {
  local dir="$1"
  local friendly_name="$2"

  echo "==> Ensuring ${friendly_name} exists: ${dir}"
  mkdir -p "${dir}"
}

install_file() {
  local src="$1"
  local dst="$2"
  local mode="$3"
  local friendly_name="$4"

  if [[ ! -f "${src}" ]]; then
    echo "ERROR: Missing ${friendly_name}: ${src}"
    exit 1
  fi

  echo "==> Installing ${friendly_name} to ${dst} (overwriting if exists)"
  install -m "${mode}" "${src}" "${dst}"
}

echo
echo "==> Installing monitor-switch utilities..."

ensure_dir "${BIN_DIR}" "user bin directory"
ensure_dir "${APP_DIR}" "desktop entry directory"

install_file "${MONITOR_SWITCH_SRC}" "${MONITOR_SWITCH_DST}" "0755" "${MONITOR_SWITCH_FILE}"
install_file "${MONLG_DESKTOP_SRC}" "${MONLG_DESKTOP_DST}" "0644" "${MONLG_DESKTOP_FILE}"
install_file "${MONSA_DESKTOP_SRC}" "${MONSA_DESKTOP_DST}" "0644" "${MONSA_DESKTOP_FILE}"

# Refresh KDE application cache so KRunner and the app launcher pick up .desktop files
if command -v kbuildsycoca6 >/dev/null 2>&1; then
  echo "==> Refreshing KDE application cache (kbuildsycoca6)..."
  kbuildsycoca6 >/dev/null 2>&1 || true
else
  echo "==> NOTE: kbuildsycoca6 not found; KDE cache refresh skipped."
  echo "    If the launchers do not appear in KRunner immediately, log out and log back in."
fi

echo
echo "==> Monitor switch installation complete."
echo "Installed:"
echo "  Script: ${MONITOR_SWITCH_DST}"
echo "  Launchers:"
echo "    - ${MONLG_DESKTOP_DST}"
echo "    - ${MONSA_DESKTOP_DST}"
echo
echo "Usage:"
echo "  CLI:"
echo "    ${MONITOR_SWITCH_DST} lg"
echo "    ${MONITOR_SWITCH_DST} sa"
echo "  KRunner:"
echo "    Type: monlg"
echo "    Type: monsa"
