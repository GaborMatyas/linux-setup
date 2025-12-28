#!/usr/bin/env bash
set -euo pipefail

ZED_WRAPPER_DIR="$HOME/.local/bin"
ZED_WRAPPER_PATH="${ZED_WRAPPER_DIR}/zed"

echo "==> Ensuring Zed CLI wrapper exists at: ${ZED_WRAPPER_PATH}"

mkdir -p "${ZED_WRAPPER_DIR}"

# Create/update the wrapper (idempotent)
cat <<'WRAPPER_EOF' > "${ZED_WRAPPER_PATH}"
#!/usr/bin/env bash
exec flatpak run dev.zed.Zed "$@"
WRAPPER_EOF

chmod +x "${ZED_WRAPPER_PATH}"

echo "==> Zed CLI wrapper installed."
echo "==> You can now run: ${ZED_WRAPPER_PATH} ."
