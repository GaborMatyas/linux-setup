#!/usr/bin/env bash
set -euo pipefail

REMOTE_NAME="flathub"
PCLOUD_CLIENT_APP_ID="io.kapsa.drive"   # S3Drive

echo "==> Installing pCloud client (Option A) via S3Drive Flatpak..."

# If already installed, skip
if flatpak info "${PCLOUD_CLIENT_APP_ID}" >/dev/null 2>&1; then
  echo "==> Already installed: ${PCLOUD_CLIENT_APP_ID} (skipping)"
  echo "==> You can launch it with: flatpak run ${PCLOUD_CLIENT_APP_ID}"
  exit 0
fi

echo "==> Installing: ${PCLOUD_CLIENT_APP_ID}"
flatpak install -y "${REMOTE_NAME}" "${PCLOUD_CLIENT_APP_ID}"

echo "==> pCloud client installed."
echo "==> Launch command: flatpak run ${PCLOUD_CLIENT_APP_ID}"
