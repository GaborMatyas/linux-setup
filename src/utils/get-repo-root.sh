#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   get_repo_root
#
# Returns the absolute path to the repository root directory.
# Assumes this utility is located in src/utils/ relative to repo root.
#
# Example:
#   REPO_ROOT="$(get_repo_root)"

get_repo_root() {
  local script_dir
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  local repo_root
  repo_root="$(cd -- "${script_dir}/../.." &>/dev/null && pwd)"
  echo "${repo_root}"
}

# If executed as a script (not sourced), run as CLI:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  get_repo_root
fi
