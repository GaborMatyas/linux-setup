#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   download_and_extract <url> <destination_dir>
#
# Behavior:
# - Downloads tarball from URL to a temporary location
# - Extracts it to the specified destination directory
# - Handles .tar.gz files
#
# Examples:
#   download_and_extract "https://example.com/app.tar.gz" "/tmp/extract"
#
# Returns:
#   0 on success, 1 on failure

download_and_extract() {
  local url="$1"
  local dest_dir="$2"

  if [[ -z "${url}" ]]; then
    echo "ERROR: URL is required" >&2
    return 1
  fi

  if [[ -z "${dest_dir}" ]]; then
    echo "ERROR: Destination directory is required" >&2
    return 1
  fi

  mkdir -p "${dest_dir}"

  local tarball="${dest_dir}/download.tar.gz"

  echo "==> Downloading from: ${url}"
  if ! curl -fsSL "${url}" -o "${tarball}"; then
    echo "ERROR: Failed to download from ${url}" >&2
    return 1
  fi

  echo "==> Extracting to: ${dest_dir}"
  if ! tar -xzf "${tarball}" -C "${dest_dir}"; then
    echo "ERROR: Failed to extract tarball" >&2
    return 1
  fi

  # Clean up tarball after extraction
  rm -f "${tarball}"

  return 0
}

# If executed as a script (not sourced), run as CLI:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <url> <destination_dir>" >&2
    exit 1
  fi
  download_and_extract "$@"
fi
