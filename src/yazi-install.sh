#!/usr/bin/env bash
set -euo pipefail

APP_ID="yazi"
FLATPAK_APP_ID="io.github.sxyazi.yazi"

# Repo paths
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

YAZI_SCRIPT_TO_COPY="${REPO_ROOT}/files-to-copy/bin/yazi"

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

# Ensure target dir exists
mkdir -p "${LOCAL_BIN}"

# Validate wrapper file exists in repo
if [[ ! -f "${YAZI_SCRIPT_TO_COPY}" ]]; then
  echo "ERROR: Missing repo wrapper: ${YAZI_SCRIPT_TO_COPY}"
  echo "Make sure files-to-copy/bin/yazi exists in your repo."
  exit 1
fi

# Copy wrapper (always overwrite)
cp -f "${YAZI_SCRIPT_TO_COPY}" "${TARGET_WRAPPER}"
chmod +x "${TARGET_WRAPPER}"

echo "==> Copied: ${YAZI_SCRIPT_TO_COPY}"
echo "==> To:     ${TARGET_WRAPPER}"
echo "==> Note: This wrapper is repo-managed and overwritten on every run."

# Validate wrapper works
echo
echo "==> Verifying wrapper..."
if "${TARGET_WRAPPER}" --version >/dev/null 2>&1; then
  echo "==> ${APP_ID} wrapper works."
  echo "==> Run: yazi"
else
  echo "ERROR: Wrapper installed but failed to execute: ${TARGET_WRAPPER}"
  echo "TIP: Try running: flatpak run ${FLATPAK_APP_ID} --version"
  exit 1
fi
