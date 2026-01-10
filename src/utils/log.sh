#!/usr/bin/env bash
set -euo pipefail

# log.sh - Logging and output formatting utility
#
# Provides consistent, colorful, and icon-based logging for installer scripts.
#
# Usage:
#   source "${REPO_ROOT}/src/utils/log.sh"
#
#   section_header "Installing Ripgrep"
#   log_info "Checking dependencies..."
#   log_success "Dependencies satisfied"
#   log_skip "Already installed"
#   log_error "Installation failed"
#   log_warn "Configuration may need manual adjustment"
#   section_end
#
# Icons used:
#   ✅ - Success (green)
#   ❌ - Error (red)
#   ❗ - Warning (yellow)
#   ⏭️  - Skip (blue)
#   ==> - Info (cyan)

# Color codes (only used if terminal supports colors)
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1; then
  COLOR_RESET="\033[0m"
  COLOR_RED="\033[0;31m"
  COLOR_GREEN="\033[0;32m"
  COLOR_YELLOW="\033[0;33m"
  COLOR_BLUE="\033[0;34m"
  COLOR_CYAN="\033[0;36m"
  COLOR_BOLD="\033[1m"
else
  COLOR_RESET=""
  COLOR_RED=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_BLUE=""
  COLOR_CYAN=""
  COLOR_BOLD=""
fi

# Track if we're in a section (for proper spacing)
_IN_SECTION=0

#
# section_header <title>
#
# Prints a section header with clear visual separation.
# Use this at the start of each major installation/configuration process.
#
# Example:
#   section_header "Installing Ripgrep"
#
section_header() {
  local title="$1"

  # Add spacing before section (unless first section)
  if [[ ${_IN_SECTION} -eq 1 ]]; then
    echo
  fi

  echo
  echo -e "${COLOR_BOLD}${COLOR_CYAN}==> ${title}${COLOR_RESET}"
  _IN_SECTION=1
}

#
# section_end
#
# Marks the end of a section. Optional, but helps with spacing.
#
# Example:
#   section_end
#
section_end() {
  _IN_SECTION=1
}

#
# log_info <message>
#
# Prints an informational message.
# Use for progress updates, status messages.
#
# Example:
#   log_info "Downloading package..."
#
log_info() {
  echo -e "${COLOR_CYAN}==> $*${COLOR_RESET}"
}

#
# log_success <message>
#
# Prints a success message with ✅ icon.
# Use when an operation completes successfully.
#
# Example:
#   log_success "Installation complete"
#
log_success() {
  echo -e "${COLOR_GREEN}✅ $*${COLOR_RESET}"
}

#
# log_error <message>
#
# Prints an error message with ❌ icon.
# Use for errors that prevent continuation.
#
# Example:
#   log_error "Failed to download package"
#
log_error() {
  echo -e "${COLOR_RED}❌ $*${COLOR_RESET}" >&2
}

#
# log_warn <message>
#
# Prints a warning message with ❗ icon.
# Use for non-fatal issues that need attention.
#
# Example:
#   log_warn "Configuration file not found, using defaults"
#
log_warn() {
  echo -e "${COLOR_YELLOW}❗ $*${COLOR_RESET}"
}

#
# log_skip <message>
#
# Prints a skip message with ⏭️ icon.
# Use when skipping an operation (e.g., already installed).
#
# Example:
#   log_skip "Already installed: ripgrep"
#
log_skip() {
  echo -e "${COLOR_BLUE}⏭️  $*${COLOR_RESET}"
}

#
# log_result <label> <value>
#
# Prints a labeled result (key: value format).
# Use for showing final information like version, path, etc.
#
# Example:
#   log_result "Binary" "${HOME}/.local/bin/rg"
#   log_result "Version" "ripgrep 15.1.0"
#
log_result() {
  local label="$1"
  local value="$2"
  echo -e "  ${COLOR_BOLD}${label}:${COLOR_RESET} ${value}"
}

#
# Helper functions (backward compatibility with existing scripts)
#

# Alias for log_success
ok() {
  log_success "$@"
}

# Alias for log_warn
warn() {
  log_warn "$@"
}

# Alias for log_info
info() {
  log_info "$@"
}

# Alias for log_error
error() {
  log_error "$@"
}

#
# print_separator [character] [length]
#
# Prints a visual separator line.
# Optional: Specify character and length (defaults: "─" and 60)
#
# Example:
#   print_separator
#   print_separator "=" 40
#
print_separator() {
  local char="${1:-─}"
  local length="${2:-60}"
  printf '%*s\n' "${length}" '' | tr ' ' "${char}"
}

# If executed as a script (not sourced), show examples:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "Logging Utility - Examples:"
  echo

  section_header "Example Installation Process"
  log_info "Checking dependencies..."
  sleep 0.5
  log_success "All dependencies found"
  log_info "Starting installation..."
  sleep 0.5
  log_success "Installation complete"
  log_result "Binary" "/home/user/.local/bin/app"
  log_result "Version" "1.2.3"

  section_header "Example Skip Scenario"
  log_info "Checking if already installed..."
  sleep 0.5
  log_skip "Already installed: app (version 1.2.3)"

  section_header "Example Warning Scenario"
  log_info "Applying configuration..."
  sleep 0.5
  log_warn "Config file not found, using defaults"
  log_success "Configuration applied"

  section_header "Example Error Scenario"
  log_info "Attempting risky operation..."
  sleep 0.5
  log_error "Operation failed: permission denied"

  section_end
  echo
  echo "All logging functions demonstrated."
fi
