#!/usr/bin/env bash
#
# bazzite-install.sh - Bazzite Linux Setup Installer
#
# This script installs and configures applications and settings
# specifically for Bazzite Linux (an immutable Fedora-based distro).
#
# Usage:
#   ./bazzite-install.sh
#
# Part of linux-setup repository - multi-OS dotfiles and configurations
# For other operating systems, see:
#   - macos-install.sh (coming soon)
#   - wsl-install.sh (coming soon)
#
set -euo pipefail

REMOTE_NAME="flathub"
REMOTE_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"

APPS=(
  "org.keepassxc.KeePassXC"
  "dev.zed.Zed"
  "org.mozilla.Thunderbird"
  "com.transmissionbt.Transmission"
  "org.videolan.VLC"
)

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SRC_DIR="$(cd -- "${SCRIPT_DIR}/src" &>/dev/null && pwd)"

# Source common utilities (includes run_helper_script)
source "${SRC_DIR}/utils/common.sh"

MONITOR_SWITCH_INSTALLER_SCRIPT="${SRC_DIR}/monitor-switch-install.sh"
ZED_INSTALLER_SCRIPT="${SRC_DIR}/zed-installer.sh"
PCLOUD_INSTALLER_SCRIPT="${SRC_DIR}/pcloud-install.sh"
BAZZITE_GLOBAL_SHORTCUTS_SCRIPT="${SRC_DIR}/bazzite-global-shortcuts.sh"
BAZZITE_GLOBAL_CONFIG_SCRIPT="${SRC_DIR}/bazzite-global-config.sh"
KITTY_TERMINAL_INSTALLER_SCRIPT="${SRC_DIR}/kitty-terminal-installer.sh"
ZOXIDE_CLI_TOOL_INSTALLER_SCRIPT="${SRC_DIR}/zoxide-install.sh"
FZF_INSTALLER_SCRIPT="${SRC_DIR}/fzf-install.sh"
RIPGREP_INSTALLER_SCRIPT="${SRC_DIR}/ripgrep-install.sh"
FD_INSTALLER_SCRIPT="${SRC_DIR}/fd-install.sh"
TMUX_INSTALLER_SCRIPT="${SRC_DIR}/tmux-install.sh"
YAZI_INSTALLER_SCRIPT="${SRC_DIR}/yazi-install.sh"


echo
echo "==> Checking Flatpak availability..."
if ! command -v flatpak >/dev/null 2>&1; then
  echo "ERROR: 'flatpak' is not installed or not in PATH."
  echo "On Bazzite it should be available by default. Please install Flatpak first."
  exit 1
fi

echo
echo "==> Ensuring Flathub remote exists..."
if ! flatpak remotes --columns=name | tail -n +2 | grep -qx "${REMOTE_NAME}"; then
  echo "Adding Flathub remote..."
  flatpak remote-add --if-not-exists "${REMOTE_NAME}" "${REMOTE_URL}"
else
  echo "Flathub remote already present."
fi

echo
echo "==> Updating Flatpak appstream metadata..."
flatpak update --appstream -y || true

is_installed() {
  local app_id="$1"
  flatpak info "$app_id" >/dev/null 2>&1
}

install_app() {
  local app_id="$1"

  if is_installed "$app_id"; then
    echo "==> Already installed: ${app_id} (skipping)"
    return 0
  fi

  echo "==> Installing: ${app_id}"
  flatpak install -y "${REMOTE_NAME}" "${app_id}"
}



echo
echo "==> Installing core applications (KeePassXC, Zed)..."
for app in "${APPS[@]}"; do
  install_app "$app"
done

# --- Helper scripts (consistent execution) ---
run_helper_script "${MONITOR_SWITCH_INSTALLER_SCRIPT}" "Monitor switch installer logic"
run_helper_script "${ZED_INSTALLER_SCRIPT}" "Zed installer logic"
run_helper_script "${PCLOUD_INSTALLER_SCRIPT}" "pCloud installer logic (Option A client)"
run_helper_script "${BAZZITE_GLOBAL_SHORTCUTS_SCRIPT}" "Bazzite KDE global shortcuts configuration"
run_helper_script "${BAZZITE_GLOBAL_CONFIG_SCRIPT}" "Bazzite KDE global config change"
run_helper_script "${KITTY_TERMINAL_INSTALLER_SCRIPT}" "Install Kitty terminal"
run_helper_script "${FZF_INSTALLER_SCRIPT}" "Install fzf CLI tool"
run_helper_script "${ZOXIDE_CLI_TOOL_INSTALLER_SCRIPT}" "Install Zoxide cli tool to enhance navigation across folders in terminal"
run_helper_script "${RIPGREP_INSTALLER_SCRIPT}" "Install ripgrep (rg) CLI tool"
run_helper_script "${FD_INSTALLER_SCRIPT}" "Install fd (modern 'find' command alternative)"
run_helper_script "${TMUX_INSTALLER_SCRIPT}" "Install tmux (by Linuxbrew)"
run_helper_script "${YAZI_INSTALLER_SCRIPT}" "Install Yazi CLI wrapper"



echo
echo "==> Done."
echo "==> Please restart the system so the new config and shortcut changes can be applied."
