#!/usr/bin/env bash
set -euo pipefail

# run-helper-script.sh - Utility to execute helper/installer scripts
#
# Usage:
#   source "${REPO_ROOT}/src/utils/run-helper-script.sh"
#   run_helper_script "/path/to/script.sh" "Description of script"
#
# Or as a standalone:
#   ./run-helper-script.sh "/path/to/script.sh" "Description of script"
#
# Behavior:
# - Prints a header with the script description
# - Checks that the script file exists
# - Makes the script executable
# - Executes the script
# - Exits with error if script is missing

run_helper_script() {
  local script_path="$1"
  local script_desc="$2"

  echo
  echo "==> Running ${script_desc}..."

  if [[ ! -f "${script_path}" ]]; then
    echo "ERROR: Missing helper script: ${script_path}" >&2
    echo "Make sure ${script_path##*/} exists." >&2
    return 1
  fi

  chmod +x "${script_path}"
  "${script_path}"
}

# If executed as a script (not sourced), run as CLI:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <script_path> <script_description>" >&2
    exit 1
  fi
  run_helper_script "$@"
fi
