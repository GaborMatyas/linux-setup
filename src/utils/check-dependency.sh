#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   check_dependency <command_name> [error_message]
#
# Behavior:
# - Checks if command is available on PATH
# - If missing, prints error message and exits with code 1
# - If present, returns 0 silently
#
# Examples:
#   check_dependency curl
#   check_dependency jq "jq is required for JSON parsing"

check_dependency() {
  local cmd="$1"
  local error_msg="${2:-}"

  if ! command -v "${cmd}" >/dev/null 2>&1; then
    if [[ -z "${error_msg}" ]]; then
      echo "ERROR: '${cmd}' is required but not installed." >&2
    else
      echo "ERROR: ${error_msg}" >&2
    fi
    return 1
  fi
}

# If executed as a script (not sourced), run as CLI:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <command_name> [error_message]" >&2
    exit 1
  fi
  check_dependency "$@"
fi
