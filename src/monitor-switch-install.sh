#!/usr/bin/env bash
set -euo pipefail

# Symlink-based installer for monitor-switch assets.
# Ensures repo-managed files are *not copied*, only symlinked, with safe backups.

link_file() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local bak="${dst}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$bak"
    echo "==> Backed up existing file: $dst -> $bak"
  fi

  if [[ -L "$dst" ]]; then
    local cur
    cur="$(readlink "$dst")"
    if [[ "$cur" == "$src" ]]; then
      echo "==> Symlink already correct: $dst -> $src"
      return 0
    fi
  fi

  ln -sfn "$src" "$dst"
  echo "==> Symlinked: $dst -> $src"
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Source folder for monitor switch files
MONITOR_SWITCH_DIR="${SCRIPT_DIR}/../files-to-copy/monitor-switch"

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

echo
echo "==> Installing monitor-switch (symlinks)..."

# Validate sources
for f in "${MONITOR_SWITCH_SRC}" "${MONLG_DESKTOP_SRC}" "${MONSA_DESKTOP_SRC}"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: Missing source file: $f"
    exit 1
  fi
done

# Create destinations
mkdir -p "${BIN_DIR}" "${APP_DIR}"

# Symlink assets
link_file "${MONITOR_SWITCH_SRC}" "${MONITOR_SWITCH_DST}"
chmod +x "${MONITOR_SWITCH_SRC}" || true  # ensure repo file is executable for local use

link_file "${MONLG_DESKTOP_SRC}" "${MONLG_DESKTOP_DST}"
link_file "${MONSA_DESKTOP_SRC}" "${MONSA_DESKTOP_DST}"

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
