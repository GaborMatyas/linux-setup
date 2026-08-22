#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   fetch_github_release <owner> <repo> <asset_pattern>
#
# Behavior:
# - Fetches latest release metadata from GitHub API
# - Extracts download URL matching the provided asset pattern
# - Prints the download URL to stdout
# - Exits with error if URL cannot be determined
#
# Examples:
#   URL="$(fetch_github_release junegunn fzf "fzf-[0-9]+\.[0-9]+\.[0-9]+-linux_amd64\.tar\.gz")"
#   URL="$(fetch_github_release BurntSushi ripgrep "ripgrep-[0-9]+\.[0-9]+\.[0-9]+-x86_64-unknown-linux-musl\.tar\.gz")"

fetch_github_release() {
  local owner="$1"
  local repo="$2"
  local asset_pattern="$3"

  local api_url="https://api.github.com/repos/${owner}/${repo}/releases/latest"
  local download_url

  download_url="$(
    curl -fsSL "${api_url}" \
      | grep -oE "https://github.com/${owner}/${repo}/releases/download/[^\"]+/${asset_pattern}" \
      | head -n1
  )"

  if [[ -z "${download_url}" ]]; then
    echo "ERROR: Could not determine latest ${repo} release download URL" >&2
    echo "Asset pattern: ${asset_pattern}" >&2
    echo "TIP: Check releases manually: https://github.com/${owner}/${repo}/releases" >&2
    return 1
  fi

  echo "${download_url}"
}

# If executed as a script (not sourced), run as CLI:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <owner> <repo> <asset_pattern>" >&2
    exit 1
  fi
  fetch_github_release "$@"
fi
