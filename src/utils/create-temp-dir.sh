#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   create_temp_dir
#
# Behavior:
# - Creates a temporary directory using mktemp -d
# - Sets up an EXIT trap to automatically clean it up
# - Prints the path to stdout
#
# Example:
#   TMP_DIR="$(create_temp_dir)"
#   # Use TMP_DIR for operations...
#   # Automatically cleaned up on script exit
#
# Note: The cleanup trap is registered in the calling script's context
# when this function is sourced and called.

create_temp_dir() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  # Register cleanup trap
  cleanup() { rm -rf "${tmp_dir}"; }
  trap cleanup EXIT

  echo "${tmp_dir}"
}

# If executed as a script (not sourced), run as CLI:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  create_temp_dir
fi
