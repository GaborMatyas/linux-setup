#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   create_symlink <source> <target> [--chmod-x]
#
# Behavior:
# - Ensures parent dir exists for <target>
# - Removes any existing file/symlink at <target> (no backup)
# - Creates/updates symlink <target> -> <source>
# - If --chmod-x is passed, ensures <source> is executable

create_symlink() {
  local src="$1"
  local dst="$2"
  local chmod_x="${3:-}"

  if [[ ! -e "$src" ]]; then
    echo "ERROR: Source does not exist: $src" >&2
    return 1
  fi

  mkdir -p "$(dirname "$dst")"

  # Remove existing destination if it's a file or symlink.
  # (If it's a directory, we refuse to delete it automatically.)
  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ -d "$dst" && ! -L "$dst" ]]; then
      echo "ERROR: Destination exists and is a directory (refusing to remove): $dst" >&2
      return 1
    fi
    rm -f "$dst"
  fi

  ln -s "$src" "$dst"

  if [[ "$chmod_x" == "--chmod-x" ]]; then
    chmod +x "$src"
  fi
}

# If executed as a script (not sourced), run as CLI:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <source> <target> [--chmod-x]" >&2
    exit 1
  fi
  create_symlink "$@"
fi
