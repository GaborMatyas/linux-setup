#!/usr/bin/env bash
set -euo pipefail

APP_ID="yazi"
FLATPAK_APP_ID="io.github.sxyazi.yazi"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

# shellcheck source=src/utils/create-symlink.sh
source "${REPO_ROOT}/src/utils/create-symlink.sh"

# Repo-managed wrapper
YAZI_WRAPPER_SRC="${REPO_ROOT}/files-to-copy/bin/yazi"

# Target paths
LOCAL_BIN="${HOME}/.local/bin"
TARGET_WRAPPER="${LOCAL_BIN}/yazi"

echo
echo "==> Installing ${APP_ID} CLI wrapper..."

# Validate flatpak exists
if ! command -v flatpak >/dev/null 2>&1; then
  echo "ERROR: flatpak is not installed. Cannot install ${APP_ID} wrapper."
  exit 1
fi

# Validate yazi flatpak exists
if ! flatpak info "${FLATPAK_APP_ID}" >/dev/null 2>&1; then
  echo "ERROR: Flatpak not installed: ${FLATPAK_APP_ID}"
  echo "TIP: Add it to your APPS array in install.sh and rerun."
  exit 1
fi

mkdir -p "${LOCAL_BIN}"

# Validate wrapper file exists in repo
if [[ ! -f "${YAZI_WRAPPER_SRC}" ]]; then
  echo "ERROR: Missing repo wrapper: ${YAZI_WRAPPER_SRC}"
  echo "Make sure files-to-copy/bin/yazi exists in your repo."
  exit 1
fi

# Symlink wrapper and ensure source is executable
create_symlink "${YAZI_WRAPPER_SRC}" "${TARGET_WRAPPER}" --chmod-x

echo "==> Wrapper installed:"
echo "==>   Source: ${YAZI_WRAPPER_SRC}"
echo "==>   Target: ${TARGET_WRAPPER}"
echo "==> Note: Wrapper is repo-managed via symlink."

# Validate wrapper exists and is executable
if [[ ! -x "${TARGET_WRAPPER}" ]]; then
  echo "ERROR: Wrapper is not executable: ${TARGET_WRAPPER}"
  echo "TIP: Ensure repo file is executable: chmod +x ${YAZI_WRAPPER_SRC}"
  exit 1
fi

echo
echo "==> Verifying Flatpak installation..."
flatpak run "${FLATPAK_APP_ID}" --version >/dev/null 2>&1 || {
  echo "ERROR: Flatpak exists but failed to run: ${FLATPAK_APP_ID}"
  echo "TIP: Try manually: flatpak run ${FLATPAK_APP_ID} --version"
  exit 1
}

echo "==> ${APP_ID} wrapper installed successfully."
echo "==> Run: yazi"
