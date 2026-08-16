#!/usr/bin/env bash
set -euo pipefail

# print-further-steps.sh - Display manual steps required after macOS setup
#
# This script prints out manual configuration steps that cannot be automated.
# Called at the end of macbook-install.sh.
#
# Usage:
#   ./print-further-steps.sh
#   (or called from macbook-install.sh)

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

FURTHER_STEPS_FILE="${SCRIPT_DIR}/further-steps.txt"

section_header "Manual steps required"

if [[ -f "${FURTHER_STEPS_FILE}" ]]; then
  cat "${FURTHER_STEPS_FILE}"
else
  log_error "further-steps.txt not found: ${FURTHER_STEPS_FILE}"
  exit 1
fi

section_end
