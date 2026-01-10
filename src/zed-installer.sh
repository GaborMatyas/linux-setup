#!/usr/bin/env bash
set -euo pipefail

ZED_WRAPPER_DIR="$HOME/.local/bin"
ZED_WRAPPER_PATH="${ZED_WRAPPER_DIR}/zed"

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

section_header "Installing Zed CLI Wrapper"

log_info "Creating Zed CLI wrapper..."
mkdir -p "${ZED_WRAPPER_DIR}"

# Create/update the wrapper (idempotent)
cat <<'WRAPPER_EOF' > "${ZED_WRAPPER_PATH}"
#!/usr/bin/env bash
exec flatpak run dev.zed.Zed "$@"
WRAPPER_EOF

chmod +x "${ZED_WRAPPER_PATH}"

log_success "Zed CLI wrapper installed"
log_result "Wrapper" "${ZED_WRAPPER_PATH}"
log_result "Usage" "zed ."

section_end
