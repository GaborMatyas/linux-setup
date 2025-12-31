#!/usr/bin/env bash
set -euo pipefail

APP_ID="fd"
BIN_NAME="fd"

LOCAL_BIN="${HOME}/.local/bin"
FD_BIN="${LOCAL_BIN}/${BIN_NAME}"

GITHUB_API_LATEST="https://api.github.com/repos/sharkdp/fd/releases/latest"

echo
echo "==> Installing ${APP_ID} (${BIN_NAME})..."

# --- Already-installed check (same style as your install.sh) ---
if [[ -x "${FD_BIN}" ]]; then
  echo "==> Already installed: ${APP_ID} (skipping)"
  echo "==> Binary: ${FD_BIN}"
  echo "==> Version: $("${FD_BIN}" --version | head -n1 || true)"
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
  x86_64)   PLATFORM="x86_64-unknown-linux-gnu" ;;
  aarch64)  PLATFORM="aarch64-unknown-linux-gnu" ;;
  *)
    echo "ERROR: Unsupported architecture: ${ARCH}"
    echo "Supported: x86_64, aarch64"
    exit 1
    ;;
esac

echo
echo "==> Fetching latest release metadata from GitHub..."

# fd release assets typically look like:
#   fd-v9.0.0-x86_64-unknown-linux-gnu.tar.gz
#   fd-v9.0.0-aarch64-unknown-linux-gnu.tar.gz
DOWNLOAD_URL="$(
  curl -fsSL "${GITHUB_API_LATEST}" \
    | grep -oE "https://github.com/sharkdp/fd/releases/download/[^\"]+/fd-v[0-9]+\.[0-9]+\.[0-9]+-${PLATFORM}\.tar\.gz" \
    | head -n1
)"

if [[ -z "${DOWNLOAD_URL}" ]]; then
  echo "ERROR: Could not determine latest ${APP_ID} download URL for platform: ${PLATFORM}"
  echo "TIP: Check releases manually: https://github.com/sharkdp/fd/releases"
  exit 1
fi

echo "==> Download URL: ${DOWNLOAD_URL}"

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

TARBALL="${TMP_DIR}/fd.tar.gz"

echo
echo "==> Downloading ${APP_ID}..."
curl -fsSL "${DOWNLOAD_URL}" -o "${TARBALL}"

echo
echo "==> Extracting..."
tar -xzf "${TARBALL}" -C "${TMP_DIR}"

# Find extracted directory (fd-v<version>-<platform>)
EXTRACTED_DIR="$(find "${TMP_DIR}" -maxdepth 1 -type d -name "fd-v*-*" | head -n1)"
if [[ -z "${EXTRACTED_DIR}" ]]; then
  echo "ERROR: Could not locate extracted fd directory."
  exit 1
fi

if [[ ! -f "${EXTRACTED_DIR}/fd" ]]; then
  echo "ERROR: Extracted tarball does not contain 'fd' binary as expected."
  exit 1
fi

echo
echo "==> Installing binary to: ${FD_BIN}"
install -m 0755 "${EXTRACTED_DIR}/fd" "${FD_BIN}"

# Validate
if [[ ! -x "${FD_BIN}" ]]; then
  echo "ERROR: fd binary not found at expected location: ${FD_BIN}"
  exit 1
fi

echo
echo "==> ${APP_ID} installed successfully."
echo "==> Binary: ${FD_BIN}"
echo "==> Version: $("${FD_BIN}" --version | head -n1 || true)"
