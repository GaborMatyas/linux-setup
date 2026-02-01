#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   install_shellrc_snippet <source_snippet> <snippet_name>
#
# Behavior:
# - Creates ~/.shellrc.d directory if it doesn't exist
# - Symlinks repo-managed snippet to ~/.shellrc.d/<snippet_name>
# - Uses create-symlink.sh utility for consistent symlink behavior
# - Validates that source snippet exists
# - Works for both bash and zsh (user sources from their respective rc file)
#
# Examples:
#   install_shellrc_snippet "${REPO_ROOT}/files-to-copy/dotfiles/shellrc.d/fzf.sh" "fzf.sh"
#   install_shellrc_snippet "${REPO_ROOT}/files-to-copy/dotfiles/shellrc.d/zoxide.sh" "zoxide.sh"
#
# Note: User must add the following to their ~/.bashrc or ~/.zshrc:
#   for file in ~/.shellrc.d/*.sh; do
#     [[ -r "$file" ]] && source "$file"
#   done

install_shellrc_snippet() {
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

  local shellrc_d_dir="${HOME}/.shellrc.d"
  local target="${shellrc_d_dir}/${snippet_name}"

  mkdir -p "${shellrc_d_dir}"

  # Source the create-symlink utility
  local script_dir
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  # shellcheck source=src/utils/create-symlink.sh
  source "${script_dir}/create-symlink.sh"

  create_symlink "${src}" "${target}"

  echo "==> Shell snippet installed:"
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
  install_shellrc_snippet "$@"
fi
