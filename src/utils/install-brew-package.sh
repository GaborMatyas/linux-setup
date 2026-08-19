#!/usr/bin/env bash
# install-brew-package.sh - Install a Homebrew/Linuxbrew package

install_brew_package() {
  local package_name="$1"
  local brew_prefix="${BREW_PREFIX:-/home/linuxbrew/.linuxbrew}"

  # Ensure brew is installed
  if ! command -v brew &>/dev/null; then
    log_error "Homebrew is not installed. Please run homebrew-install.sh first."
    return 1
  fi

  # Check if package is already installed
  if brew list "${package_name}" &>/dev/null; then
    log_skip "Already installed via brew: ${package_name}"
    log_result "Binary" "$(command -v "${package_name}" || true)"
    return 0
  fi

  log_info "Installing ${package_name} via brew..."
  brew install "${package_name}"

  # Validate installation
  if ! command -v "${package_name}" &>/dev/null; then
    log_error "${package_name} installation finished, but command not found on PATH"
    log_result "Brew prefix" "$(brew --prefix 2>/dev/null || true)"
    log_warn "Ensure brew shellenv is loaded in bash (e.g. eval \"\$(brew shellenv)\")"
    return 1
  fi

  log_success "Installed ${package_name}"
  log_result "Binary" "$(command -v "${package_name}" || true)"
  return 0
}