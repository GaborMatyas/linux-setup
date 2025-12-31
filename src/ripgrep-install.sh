#!/usr/bin/env bash
set -euo pipefail

APP_ID="ripgrep"
BIN_NAME="rg"

LOCAL_BIN="${HOME}/.local/bin"
RG_BIN="${LOCAL_BIN}/${BIN_NAME}"

GITHUB_API_LATEST="https://api.github.com/repos/BurntSushi/ripgrep/releases/latest"

echo
echo "==> Installing ${APP_ID} (${BIN_NAME})..."

# --- Already-installed check (same style as your install.sh) ---
if [[ -x "${RG_BIN}" ]]; then
  echo "==> Already installed: ${APP_ID} (skipping)"
  echo "==> Binary: ${RG_BIN}"
  echo "==> Version: $("${RG_BIN}" --version | head -n1 || true)"
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
  x86_64)   PLATFORM="x86_64-unknown-linux-musl" ;;
  aarch64)  PLATFORM="aarch64-unknown-linux-gnu" ;;
  *)
    echo "ERROR: Unsupported architecture: ${ARCH}"
    echo "Supported: x86_64, aarch64"
    exit 1
    ;;
esac

echo
echo "==> Fetching latest release metadata from GitHub..."

# Determine the download URL for the tarball matching our platform.
# Example filename patterns:
#   ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz
#   ripgrep-13.0.0-aarch64-unknown-linux-gnu.tar.gz
DOWNLOAD_URL="$(
  curl -fsSL "${GITHUB_API_LATEST}" \
    | grep -oE "https://github.com/BurntSushi/ripgrep/releases/download/[^\"]+/ripgrep-[0-9]+\.[0-9]+\.[0-9]+-${PLATFORM}\.tar\.gz" \
    | head -n1
)"

if [[ -z "${DOWNLOAD_URL}" ]]; then
  echo "ERROR: Could not determine latest ${APP_ID} download URL for platform: ${PLATFORM}"
  echo "TIP: Check releases manually: https://github.com/BurntSushi/ripgrep/releases"
  exit 1
fi

echo "==> Download URL: ${DOWNLOAD_URL}"

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

TARBALL="${TMP_DIR}/ripgrep.tar.gz"

echo
echo "==> Downloading ${APP_ID}..."
curl -fsSL "${DOWNLOAD_URL}" -o "${TARBALL}"

echo
echo "==> Extracting..."
tar -xzf "${TARBALL}" -C "${TMP_DIR}"

# Find extracted directory (ripgrep-<version>-<platform>)
EXTRACTED_DIR="$(find "${TMP_DIR}" -maxdepth 1 -type d -name "ripgrep-*-*" | head -n1)"
if [[ -z "${EXTRACTED_DIR}" ]]; then
  echo "ERROR: Could not locate extracted ripgrep directory."
  exit 1
fi

if [[ ! -f "${EXTRACTED_DIR}/rg" ]]; then
  echo "ERROR: Extracted tarball does not contain 'rg' binary as expected."
  exit 1
fi

echo
echo "==> Installing binary to: ${RG_BIN}"
install -m 0755 "${EXTRACTED_DIR}/rg" "${RG_BIN}"

# Validate
if [[ ! -x "${RG_BIN}" ]]; then
  echo "ERROR: rg binary not found at expected location: ${RG_BIN}"
  exit 1
fi

echo
echo "==> ${APP_ID} installed successfully."
echo "==> Binary: ${RG_BIN}"
echo "==> Version: $("${RG_BIN}" --version | head -n1 || true)"
