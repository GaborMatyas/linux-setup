#!/usr/bin/env bash
set -euo pipefail

APP_ID="stow"

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"
source "${REPO_ROOT}/src/utils/install-brew-package.sh"

section_header "Installing ${APP_ID}"
install_brew_package "${APP_ID}"

section_end