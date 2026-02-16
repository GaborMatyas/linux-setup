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

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

REPO_KITTY_CONF="${REPO_ROOT}/files-to-copy/dotfiles/kitty/kitty.conf"
REPO_KITTY_THEME="${REPO_ROOT}/files-to-copy/dotfiles/kitty/theme.conf"
REPO_KITTY_SHELL_INTEGRATION="${REPO_ROOT}/files-to-copy/dotfiles/bashrc.d/kitty.sh"
BASHRC_D_DIR="${HOME}/.bashrc.d"

# Treat kitty as installed if the expected install directory exists,
# or if kitty is already on PATH.
is_kitty_installed() {
  [[ -d "${KITTY_INSTALL_DIR}" ]] || command -v kitty >/dev/null 2>&1
}

install_kitty_config() {
  log_info "Installing kitty config (repo-managed via symlink)..."

  if [[ ! -f "${REPO_KITTY_CONF}" ]]; then
    log_error "Missing repo config: ${REPO_KITTY_CONF}"
    log_result "Expected at" "files-to-copy/dotfiles/kitty/kitty.conf"
    exit 1
  fi

  mkdir -p "${KITTY_CONFIG_DIR}"
  create_symlink "${REPO_KITTY_CONF}" "${KITTY_CONFIG_FILE}"
  log_success "Config installed"
  log_result "Source" "${REPO_KITTY_CONF}"
  log_result "Target" "${KITTY_CONFIG_FILE}"

  # Install theme.conf if it exists
  if [[ -f "${REPO_KITTY_THEME}" ]]; then
    log_info "Installing kitty theme config (repo-managed via symlink)..."
    local theme_target="${KITTY_CONFIG_DIR}/theme.conf"
    create_symlink "${REPO_KITTY_THEME}" "${theme_target}"
    log_success "Theme installed"
    log_result "Source" "${REPO_KITTY_THEME}"
    log_result "Target" "${theme_target}"
  fi

  # Install shell integration for bashrc.d
  if [[ -f "${REPO_KITTY_SHELL_INTEGRATION}" ]]; then
    log_info "Installing kitty shell integration (repo-managed via symlink)..."
    mkdir -p "${BASHRC_D_DIR}"
    local shell_target="${BASHRC_D_DIR}/kitty.sh"
    create_symlink "${REPO_KITTY_SHELL_INTEGRATION}" "${shell_target}"
    log_success "Shell integration installed"
    log_result "Source" "${REPO_KITTY_SHELL_INTEGRATION}"
    log_result "Target" "${shell_target}"
  fi
}

section_header "Installing ${APP_ID}"

# If kitty is already installed, still ensure config is linked
if is_kitty_installed; then
  log_skip "Already installed: ${APP_ID}"
  install_kitty_config
  section_end
  exit 0
fi

log_info "Checking dependencies..."
check_dependency curl
log_success "Dependencies satisfied"

log_info "Installing kitty via official binary installer..."
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

if [[ ! -d "${KITTY_INSTALL_DIR}" ]]; then
  log_error "Expected kitty install directory not found: ${KITTY_INSTALL_DIR}"
  log_warn "The installer may have failed or installed to a different location"
  exit 1
fi
log_success "Kitty installed"

log_info "Setting up PATH symlinks (kitty + kitten)..."
mkdir -p "${BIN_DIR}"
ln -sf "${KITTY_INSTALL_DIR}/bin/kitty" "${KITTY_INSTALL_DIR}/bin/kitten" "${BIN_DIR}/"
log_success "PATH symlinks created"

log_info "Installing desktop integration (.desktop files)..."
mkdir -p "${APP_DIR}"
cp -f "${KITTY_INSTALL_DIR}/share/applications/kitty.desktop" "${APP_DIR}/"
cp -f "${KITTY_INSTALL_DIR}/share/applications/kitty-open.desktop" "${APP_DIR}/"
log_success "Desktop files installed"

log_info "Patching Exec= and Icon= in kitty desktop files..."
KITTY_ICON_PATH="$(readlink -f "${HOME}")/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png"
KITTY_EXEC_PATH="$(readlink -f "${HOME}")/.local/kitty.app/bin/kitty"
sed -i "s|Icon=kitty|Icon=${KITTY_ICON_PATH}|g" "${APP_DIR}"/kitty*.desktop
sed -i "s|Exec=kitty|Exec=${KITTY_EXEC_PATH}|g" "${APP_DIR}"/kitty*.desktop
log_success "Desktop files patched"

log_info "Setting kitty as default terminal for xdg-terminal-exec..."
mkdir -p "${CONFIG_DIR}"
echo 'kitty.desktop' > "${CONFIG_DIR}/xdg-terminals.list"
log_success "Default terminal configured"

# Install repo-managed config after installation
install_kitty_config

log_info "Verifying installation..."
if command -v kitty >/dev/null 2>&1; then
  log_success "Installation complete"
  log_result "Binary" "$(command -v kitty)"
else
  log_warn "kitty is not found on PATH"
  log_result "Expected" "${BIN_DIR} should be in PATH"
fi

log_result "Note" "Log out/in (or reboot) for desktop menus to refresh"

section_end
