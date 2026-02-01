#!/usr/bin/env bash
# common.sh - Common utility library for setup scripts
#
# Usage:
#   source "${REPO_ROOT}/src/utils/common.sh"
#
# This file sources all utility functions to make them available
# to installer scripts.

set -euo pipefail

# Determine utils directory
UTILS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Source all utility functions
# shellcheck source=src/utils/create-symlink.sh
source "${UTILS_DIR}/create-symlink.sh"

# shellcheck source=src/utils/get-repo-root.sh
source "${UTILS_DIR}/get-repo-root.sh"

# shellcheck source=src/utils/is-installed.sh
source "${UTILS_DIR}/is-installed.sh"

# shellcheck source=src/utils/check-dependency.sh
source "${UTILS_DIR}/check-dependency.sh"

# shellcheck source=src/utils/log.sh
source "${UTILS_DIR}/log.sh"

# shellcheck source=src/utils/detect-architecture.sh
source "${UTILS_DIR}/detect-architecture.sh"

# shellcheck source=src/utils/fetch-github-release.sh
source "${UTILS_DIR}/fetch-github-release.sh"

# shellcheck source=src/utils/create-temp-dir.sh
source "${UTILS_DIR}/create-temp-dir.sh"

# shellcheck source=src/utils/download-and-extract.sh
source "${UTILS_DIR}/download-and-extract.sh"

# shellcheck source=src/utils/install-binary.sh
source "${UTILS_DIR}/install-binary.sh"

# shellcheck source=src/utils/install-shellrc-snippet.sh
source "${UTILS_DIR}/install-shellrc-snippet.sh"

# shellcheck source=src/utils/run-helper-script.sh
source "${UTILS_DIR}/run-helper-script.sh"

# All utility functions are now available:
# - create_symlink
# - get_repo_root
# - is_installed
# - check_dependency
# - detect_architecture
# - fetch_github_release
# - create_temp_dir
# - download_and_extract
# - install_binary
# - install_shellrc_snippet
# - log_info, log_success, log_error, log_warn, log_skip, log_result
# - section_header, section_end
# - info, ok, warn, error (aliases)
# - run_helper_script
