#!/usr/bin/env bash
set -euo pipefail

APP_ID="tmux"
BREW_PREFIX="/home/linuxbrew/.linuxbrew"

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

section_header "Installing ${APP_ID}"

# Ensure brew is available
log_info "Checking for Homebrew..."
check_dependency brew

# Ensure brew is the expected Linuxbrew (optional but useful safety check)
ACTUAL_PREFIX="$(brew --prefix 2>/dev/null || true)"
if [[ -n "${ACTUAL_PREFIX}" && "${ACTUAL_PREFIX}" != "${BREW_PREFIX}" ]]; then
  log_warn "brew prefix differs from expected"
  log_result "Expected" "${BREW_PREFIX}"
  log_result "Actual" "${ACTUAL_PREFIX}"
fi
log_success "Homebrew available"

# If tmux already exists, skip install
if is_installed command tmux; then
  log_skip "Already installed: ${APP_ID}"
  log_result "Version" "$(tmux -V || true)"
  log_result "Binary" "$(command -v tmux)"
  section_end
  exit 0
fi

log_info "Installing ${APP_ID} via brew..."
brew install tmux

# Validate installation
if ! is_installed command tmux; then
  log_error "${APP_ID} installation finished, but 'tmux' is still not found on PATH"
  log_result "Brew prefix" "$(brew --prefix)"
  log_warn "Ensure brew shellenv is loaded in bash (e.g. eval \"\$(brew shellenv)\")"
  exit 1
fi

log_success "Installation complete"
log_result "Version" "$(tmux -V || true)"
log_result "Binary" "$(command -v tmux)"

section_end
