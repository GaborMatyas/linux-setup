#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   install_bashrc_snippet <source_snippet> <snippet_name>
#
# Behavior:
# - Creates ~/.bashrc.d directory if it doesn't exist
# - Symlinks repo-managed snippet to ~/.bashrc.d/<snippet_name>
# - Uses create-symlink.sh utility for consistent symlink behavior
# - Validates that source snippet exists
#
# Examples:
#   install_bashrc_snippet "${REPO_ROOT}/files-to-copy/dotfiles/bashrc.d/fzf.sh" "fzf.sh"
#   install_bashrc_snippet "${REPO_ROOT}/files-to-copy/dotfiles/bashrc.d/zoxide.sh" "zoxide.sh"

install_bashrc_snippet() {
  local src="$1"
  local snippet_name="$2"

  if [[ -z "${src}" ]]; then
    echo "ERROR: Source snippet path is required" >&2
    return 1
  fi

  if [[ -z "${snippet_name}" ]]; then
    echo "ERROR: Snippet name is required" >&2
    return 1
  fi

  if [[ ! -f "${src}" ]]; then
    echo "ERROR: Source snippet does not exist: ${src}" >&2
    return 1
  fi

  local bashrc_d_dir="${HOME}/.bashrc.d"
  local target="${bashrc_d_dir}/${snippet_name}"

  mkdir -p "${bashrc_d_dir}"

  # Source the create-symlink utility
  local script_dir
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  # shellcheck source=src/utils/create-symlink.sh
  source "${script_dir}/create-symlink.sh"

  create_symlink "${src}" "${target}"

  echo "==> Bash snippet installed:"
  echo "==>   Source: ${src}"
  echo "==>   Target: ${target}"
  echo "==> Note: This file is repo-managed via symlink. Updates require no reinstall."

  return 0
}

# If executed as a script (not sourced), run as CLI:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <source_snippet> <snippet_name>" >&2
    exit 1
  fi
  install_bashrc_snippet "$@"
fi
