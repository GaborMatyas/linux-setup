#!/usr/bin/env bash
set -euo pipefail

APP_ID="fzf"

# Repo paths
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

# shellcheck source=src/utils/create-symlink.sh
source "${REPO_ROOT}/src/utils/create-symlink.sh"

REPO_FZF_BASHRC_SNIPPET="${REPO_ROOT}/files-to-copy/dotfiles/bashrc.d/fzf.sh"

# Target bashrc.d paths (repo-managed snippet)
BASHRC_D_DIR="${HOME}/.bashrc.d"
TARGET_FZF_SNIPPET="${BASHRC_D_DIR}/fzf.sh"

# Install location
LOCAL_BIN="${HOME}/.local/bin"
FZF_BIN="${LOCAL_BIN}/fzf"

# GitHub release API
GITHUB_API_LATEST="https://api.github.com/repos/junegunn/fzf/releases/latest"

echo
echo "==> Installing ${APP_ID}..."

# --- Always install/override bash integration snippet (repo-managed) ---
echo
echo "==> Installing bash integration snippet..."
mkdir -p "${BASHRC_D_DIR}"

if [[ ! -f "${REPO_FZF_BASHRC_SNIPPET}" ]]; then
  echo "ERROR: Missing repo snippet: ${REPO_FZF_BASHRC_SNIPPET}"
  echo "Make sure files-to-copy/dotfiles/bashrc.d/fzf.sh exists in your repo."
  exit 1
fi

create_symlink "${REPO_FZF_BASHRC_SNIPPET}" "${TARGET_FZF_SNIPPET}"

echo "==> Snippet installed:"
echo "==>   Source: ${REPO_FZF_BASHRC_SNIPPET}"
echo "==>   Target: ${TARGET_FZF_SNIPPET}"
echo "==> Note: This file is repo-managed via symlink. Updates require no reinstall."

# --- If fzf exists, we still refreshed the snippet and can stop ---
if [[ -x "${FZF_BIN}" ]]; then
  echo
  echo "==> Already installed: ${APP_ID} (skipping)"
  echo "==> Binary: ${FZF_BIN}"
  echo "==> Version: $("${FZF_BIN}" --version | head -n1 || true)"
  echo "==> Bash snippet refreshed."
  exit 0
fi

# --- Dependencies ---
if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required but not installed."
  exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
  echo "ERROR: tar is required but not installed."
  exit 1
fi

mkdir -p "${LOCAL_BIN}"

# --- Detect architecture ---
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)   PLATFORM="linux_amd64" ;;
  aarch64)  PLATFORM="linux_arm64" ;;
  armv7l)   PLATFORM="linux_armv7" ;;
  *)
    echo "ERROR: Unsupported architecture: ${ARCH}"
    echo "Supported: x86_64, aarch64, armv7l"
    exit 1
    ;;
esac

echo
echo "==> Fetching latest release metadata from GitHub..."
# We intentionally avoid jq to keep dependencies minimal.
DOWNLOAD_URL="$(
  curl -fsSL "${GITHUB_API_LATEST}" \
    | grep -oE "https://github.com/junegunn/fzf/releases/download/[^\"]+/${APP_ID}-[0-9]+\.[0-9]+\.[0-9]+-${PLATFORM}\.tar\.gz" \
    | head -n1
)"

if [[ -z "${DOWNLOAD_URL}" ]]; then
  echo "ERROR: Could not determine latest ${APP_ID} release download URL for platform: ${PLATFORM}"
  echo "TIP: Check GitHub releases manually: https://github.com/junegunn/fzf/releases"
  exit 1
fi

echo "==> Download URL: ${DOWNLOAD_URL}"

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

TARBALL="${TMP_DIR}/fzf.tar.gz"

echo
echo "==> Downloading ${APP_ID}..."
curl -fsSL "${DOWNLOAD_URL}" -o "${TARBALL}"

echo
echo "==> Extracting and installing to: ${FZF_BIN}"
tar -xzf "${TARBALL}" -C "${TMP_DIR}"

# The tarball contains the 'fzf' binary at top level.
if [[ ! -f "${TMP_DIR}/fzf" ]]; then
  echo "ERROR: Extracted tarball does not contain fzf binary as expected."
  exit 1
fi

install -m 0755 "${TMP_DIR}/fzf" "${FZF_BIN}"

# Validate
if [[ ! -x "${FZF_BIN}" ]]; then
  echo "ERROR: fzf binary not found at expected location: ${FZF_BIN}"
  exit 1
fi

echo
echo "==> ${APP_ID} installed successfully."
echo "==> Binary: ${FZF_BIN}"
echo "==> Version: $("${FZF_BIN}" --version | head -n1 || true)"
echo "==> Bash integration is handled by: ${TARGET_FZF_SNIPPET}"
echo "==> Restart your terminal or run: source ~/.bashrc"
