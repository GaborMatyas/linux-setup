#!/usr/bin/env bash
set -euo pipefail

# bashrc-setup.sh
#
# Ensures ~/.bashrc is properly configured to:
#   1. Add ~/.local/bin to PATH
#   2. Source all scripts in ~/.bashrc.d/
#
# This is essential for all bashrc.d snippets (zoxide, fzf, kitty, etc.) to work.
#
# Behavior:
#   - Checks if ~/.bashrc exists, creates minimal one if not
#   - Adds PATH configuration if missing
#   - Adds bashrc.d sourcing if missing
#   - Idempotent - safe to run multiple times
#   - Preserves existing user configuration

APP_ID="bashrc-setup"
BASHRC_FILE="${HOME}/.bashrc"

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

# Markers to prevent duplicate additions
PATH_MARKER="# linux-setup: Add ~/.local/bin to PATH"
BASHRC_D_MARKER="# linux-setup: Source ~/.bashrc.d scripts"

section_header "Configuring ${APP_ID}"

# Create minimal ~/.bashrc if it doesn't exist
if [[ ! -f "${BASHRC_FILE}" ]]; then
  log_info "Creating new ~/.bashrc..."
  cat > "${BASHRC_FILE}" <<'EOF'
# ~/.bashrc - Bash configuration for interactive shells

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Append to history file, don't overwrite it
shopt -s histappend

# Set history size
HISTSIZE=10000
HISTFILESIZE=20000

# Check window size after each command
shopt -s checkwinsize

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# Some useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

EOF
  log_success "Created ~/.bashrc"
fi

# Check and add PATH configuration
if grep -qF "${PATH_MARKER}" "${BASHRC_FILE}"; then
  log_skip "PATH configuration already present"
else
  log_info "Adding ~/.local/bin to PATH..."
  cat >> "${BASHRC_FILE}" <<'EOF'

# linux-setup: Add ~/.local/bin to PATH
if [[ -d "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
EOF
  log_success "PATH configuration added"
fi

# Check and add bashrc.d sourcing
if grep -qF "${BASHRC_D_MARKER}" "${BASHRC_FILE}"; then
  log_skip "bashrc.d sourcing already present"
else
  log_info "Adding bashrc.d sourcing..."
  cat >> "${BASHRC_FILE}" <<'EOF'

# linux-setup: Source ~/.bashrc.d scripts
if [[ -d "$HOME/.bashrc.d" ]]; then
    for rc in "$HOME/.bashrc.d"/*.sh; do
        [[ -f "$rc" ]] && source "$rc"
    done
    unset rc
fi
EOF
  log_success "bashrc.d sourcing added"
fi

log_success "Bashrc configuration complete"
log_result "File" "${BASHRC_FILE}"
log_result "Note" "Restart terminal or run: source ~/.bashrc"

# Show what will be loaded
if [[ -d "${HOME}/.bashrc.d" ]]; then
  log_info "Current bashrc.d scripts:"
  for script in "${HOME}/.bashrc.d"/*.sh; do
    if [[ -f "$script" ]]; then
      log_result "  →" "$(basename "$script")"
    fi
  done
fi

section_end
