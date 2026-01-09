#!/usr/bin/env bash
set -euo pipefail

# kitty-terminal-installer.sh
#
# Installs kitty using the official binary installer:
#   curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
#
# Then applies the recommended Linux desktop integration steps:
#   - symlink kitty + kitten into ~/.local/bin
#   - install .desktop launchers into ~/.local/share/applications
#   - patch Icon= and Exec= in those desktop files
#   - optionally set kitty as the default terminal via ~/.config/xdg-terminals.list
#
# Additionally:
#   - symlink repo-managed kitty config to ~/.config/kitty/kitty.conf
#
# Source documentation:
# https://sw.kovidgoyal.net/kitty/binary/

APP_ID="kitty"
KITTY_INSTALL_DIR="${HOME}/.local/kitty.app"
BIN_DIR="${HOME}/.local/bin"
APP_DIR="${HOME}/.local/share/applications"
CONFIG_DIR="${HOME}/.config"
KITTY_CONFIG_DIR="${CONFIG_DIR}/kitty"
KITTY_CONFIG_FILE="${KITTY_CONFIG_DIR}/kitty.conf"

# Repo paths
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

# shellcheck source=src/utils/create-symlink.sh
source "${REPO_ROOT}/src/utils/create-symlink.sh"

REPO_KITTY_CONF="${REPO_ROOT}/files-to-copy/dotfiles/kitty/kitty.conf"
REPO_KITTY_THEME="${REPO_ROOT}/files-to-copy/dotfiles/kitty/theme.conf"

# Treat kitty as installed if the expected install directory exists,
# or if kitty is already on PATH.
is_kitty_installed() {
  [[ -d "${KITTY_INSTALL_DIR}" ]] || command -v kitty >/dev/null 2>&1
}

install_kitty_config() {
  echo
  echo "==> Installing kitty config (repo-managed via symlink)..."

  if [[ ! -f "${REPO_KITTY_CONF}" ]]; then
    echo "ERROR: Missing repo config: ${REPO_KITTY_CONF}"
    echo "Create it at: files-to-copy/dotfiles/kitty/kitty.conf"
    exit 1
  fi

  mkdir -p "${KITTY_CONFIG_DIR}"
  create_symlink "${REPO_KITTY_CONF}" "${KITTY_CONFIG_FILE}"

  echo "==> Config installed:"
  echo "==>   Source: ${REPO_KITTY_CONF}"
  echo "==>   Target: ${KITTY_CONFIG_FILE}"

  # Install theme.conf if it exists
  if [[ -f "${REPO_KITTY_THEME}" ]]; then
    echo
    echo "==> Installing kitty theme config (repo-managed via symlink)..."
    local theme_target="${KITTY_CONFIG_DIR}/theme.conf"
    create_symlink "${REPO_KITTY_THEME}" "${theme_target}"
    echo "==> Theme installed:"
    echo "==>   Source: ${REPO_KITTY_THEME}"
    echo "==>   Target: ${theme_target}"
  fi
}

# If kitty is already installed, still ensure config is linked
if is_kitty_installed; then
  echo "==> Already installed: ${APP_ID} (skipping)"
  install_kitty_config
  exit 0
fi

echo
echo "==> Installing kitty via official binary installer..."

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required but not installed."
  exit 1
fi

# Run the installer (standard location on Linux: ~/.local/kitty.app)
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

if [[ ! -d "${KITTY_INSTALL_DIR}" ]]; then
  echo "ERROR: Expected kitty install directory not found: ${KITTY_INSTALL_DIR}"
  echo "The installer may have failed or installed to a different location."
  exit 1
fi

echo
echo "==> Setting up PATH symlinks (kitty + kitten)..."
mkdir -p "${BIN_DIR}"

# Recommended symlink command from docs:
# ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
ln -sf "${KITTY_INSTALL_DIR}/bin/kitty" "${KITTY_INSTALL_DIR}/bin/kitten" "${BIN_DIR}/"

echo
echo "==> Installing desktop integration (.desktop files)..."
mkdir -p "${APP_DIR}"

# Recommended copy commands from docs:
# cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
# cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
cp -f "${KITTY_INSTALL_DIR}/share/applications/kitty.desktop" "${APP_DIR}/"
cp -f "${KITTY_INSTALL_DIR}/share/applications/kitty-open.desktop" "${APP_DIR}/"

echo
echo "==> Patching Exec= and Icon= in kitty desktop files..."
KITTY_ICON_PATH="$(readlink -f "${HOME}")/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png"
KITTY_EXEC_PATH="$(readlink -f "${HOME}")/.local/kitty.app/bin/kitty"

# Recommended sed commands from docs:
sed -i "s|Icon=kitty|Icon=${KITTY_ICON_PATH}|g" "${APP_DIR}"/kitty*.desktop
sed -i "s|Exec=kitty|Exec=${KITTY_EXEC_PATH}|g" "${APP_DIR}"/kitty*.desktop

echo
echo "==> Setting kitty as default terminal for xdg-terminal-exec..."
mkdir -p "${CONFIG_DIR}"
echo 'kitty.desktop' > "${CONFIG_DIR}/xdg-terminals.list"

# Install repo-managed config after installation
install_kitty_config

echo
echo "==> Verifying installation..."
if command -v kitty >/dev/null 2>&1; then
  echo "==> kitty available on PATH: $(command -v kitty)"
else
  echo "WARNING: kitty is not found on PATH."
  echo "Ensure ${BIN_DIR} is included in your system-wide PATH."
fi

echo
echo "==> Done installing kitty."
echo "==> You may need to log out/in (or reboot) for desktop environment menus to refresh."
