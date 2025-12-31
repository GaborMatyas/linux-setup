#!/usr/bin/env bash
set -euo pipefail

APP_ID="zoxide"

# Repo paths
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

REPO_ZOXIDE_BASHRC_SNIPPET="${REPO_ROOT}/files-to-copy/dotfiles/bashrc.d/zoxide.sh"

# Target paths
LOCAL_BIN="${HOME}/.local/bin"
ZOXIDE_PATH="${LOCAL_BIN}/zoxide"

BASHRC_D_DIR="${HOME}/.bashrc.d"
TARGET_ZOXIDE_SNIPPET="${BASHRC_D_DIR}/zoxide.sh"

echo
echo "==> Installing ${APP_ID}..."

# --- Always install/override the bashrc snippet (even if zoxide is already installed) ---
echo
echo "==> Installing bash integration snippet..."
mkdir -p "${BASHRC_D_DIR}"

if [[ ! -f "${REPO_ZOXIDE_BASHRC_SNIPPET}" ]]; then
  echo "ERROR: Missing repo snippet: ${REPO_ZOXIDE_BASHRC_SNIPPET}"
  echo "Make sure files-to-copy/dotfiles/bashrc.d/zoxide.sh exists in your repo."
  exit 1
fi

cp -f "${REPO_ZOXIDE_BASHRC_SNIPPET}" "${TARGET_ZOXIDE_SNIPPET}"
chmod 0644 "${TARGET_ZOXIDE_SNIPPET}"

echo "==> Copied: ${REPO_ZOXIDE_BASHRC_SNIPPET}"
echo "==> To:     ${TARGET_ZOXIDE_SNIPPET}"
echo "==> Note: This file is repo-managed and overwritten on every run."

# --- Install zoxide binary if missing ---
if [[ -x "${ZOXIDE_PATH}" ]]; then
  echo
  echo "==> Already installed: ${APP_ID} (skipping)"
  echo "==> Binary: ${ZOXIDE_PATH}"
  echo "==> Bash integration snippet refreshed."
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required but not installed."
  exit 1
fi

mkdir -p "${LOCAL_BIN}"

# Official installer: installs into ~/.local/bin by default
export XDG_BIN_HOME="${LOCAL_BIN}"

echo
echo "==> Downloading and installing ${APP_ID}..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

if [[ ! -x "${ZOXIDE_PATH}" ]]; then
  echo "ERROR: zoxide was not installed at expected location: ${ZOXIDE_PATH}"
  exit 1
fi

echo
echo "==> ${APP_ID} installed at: ${ZOXIDE_PATH}"
echo "==> Version: $("${ZOXIDE_PATH}" --version || true)"
echo "==> Bash integration snippet installed at: ${TARGET_ZOXIDE_SNIPPET}"
echo "==> From now, the 'cd' command uses zoxide under the hood"
echo "==> Restart your terminal or run: source ~/.bashrc"
