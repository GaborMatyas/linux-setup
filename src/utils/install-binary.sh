#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   install_binary <source> <destination>
#
# Behavior:
# - Ensures parent directory exists for destination
# - Installs binary with executable permissions (0755)
# - Uses the 'install' command for atomic installation
# - Validates that the destination is executable after installation
#
# Examples:
#   install_binary "/tmp/extracted/fzf" "${HOME}/.local/bin/fzf"
#   install_binary "${TMP_DIR}/rg" "${HOME}/.local/bin/rg"

install_binary() {
  local src="$1"
  local dst="$2"

  if [[ -z "${src}" ]]; then
    echo "ERROR: Source path is required" >&2
    return 1
  fi

  if [[ -z "${dst}" ]]; then
    echo "ERROR: Destination path is required" >&2
    return 1
  fi

  if [[ ! -f "${src}" ]]; then
    echo "ERROR: Source file does not exist: ${src}" >&2
    return 1
  fi

  # Ensure parent directory exists
  mkdir -p "$(dirname "${dst}")"

  # Install with executable permissions
  install -m 0755 "${src}" "${dst}"

  # Validate installation
  if [[ ! -x "${dst}" ]]; then
    echo "ERROR: Binary not found or not executable at: ${dst}" >&2
    return 1
  fi

  return 0
}

# If executed as a script (not sourced), run as CLI:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <source> <destination>" >&2
    exit 1
  fi
  install_binary "$@"
fi
