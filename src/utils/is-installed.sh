#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   is_installed <type> <identifier>
#
# Types:
#   binary      - Check if executable exists at specific path
#   command     - Check if command is available on PATH
#   flatpak     - Check if Flatpak app is installed
#
# Examples:
#   is_installed binary "${HOME}/.local/bin/fzf"
#   is_installed command tmux
#   is_installed flatpak "org.keepassxc.KeePassXC"
#
# Returns:
#   0 if installed, 1 if not installed

is_installed() {
  local type="$1"
  local identifier="$2"

  case "${type}" in
    binary)
      [[ -x "${identifier}" ]]
      ;;
    command)
      command -v "${identifier}" >/dev/null 2>&1
      ;;
    flatpak)
      flatpak info "${identifier}" >/dev/null 2>&1
      ;;
    *)
      echo "ERROR: Unknown installation check type: ${type}" >&2
      echo "Supported types: binary, command, flatpak" >&2
      return 2
      ;;
  esac
}

# If executed as a script (not sourced), run as CLI:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <type> <identifier>" >&2
    echo "Types: binary, command, flatpak" >&2
    exit 1
  fi
  is_installed "$@"
fi
