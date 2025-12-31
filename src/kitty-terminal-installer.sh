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
# Source documentation:
# https://sw.kovidgoyal.net/kitty/binary/

APP_ID="kitty"
KITTY_INSTALL_DIR="${HOME}/.local/kitty.app"
BIN_DIR="${HOME}/.local/bin"
APP_DIR="${HOME}/.local/share/applications"
CONFIG_DIR="${HOME}/.config"

# --- Already-installed check (same style message as install.sh) ---
is_kitty_installed() {
  # Treat kitty as installed if the expected install directory exists,
  # or if kitty is already on PATH.
  [[ -d "${KITTY_INSTALL_DIR}" ]] || command -v kitty >/dev/null 2>&1
}

if is_kitty_installed; then
  echo "==> Already installed: ${APP_ID} (skipping)"
  exit 0
fi

echo
echo "==> Installing kitty via official binary installer..."

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required but not installed."
  exit 1
fi

# Run the installer (standard location on Linux: ~/.local/kitty.app)
# Official command:
#   curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
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
# sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
# sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Icon=kitty|Icon=${KITTY_ICON_PATH}|g" "${APP_DIR}"/kitty*.desktop
sed -i "s|Exec=kitty|Exec=${KITTY_EXEC_PATH}|g" "${APP_DIR}"/kitty*.desktop

echo
echo "==> Setting kitty as default terminal for xdg-terminal-exec..."
mkdir -p "${CONFIG_DIR}"
echo 'kitty.desktop' > "${CONFIG_DIR}/xdg-terminals.list"

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
