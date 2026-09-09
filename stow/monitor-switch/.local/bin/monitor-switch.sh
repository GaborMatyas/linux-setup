#!/usr/bin/env bash
set -euo pipefail

HDMI="HDMI-A-1"   # LG TV
DP="DP-2"         # Samsung

usage() {
  cat <<EOF
Usage: $(basename "$0") <flag>

Flags:
  lg     -> HDMI only (LG TV)
  sa     -> DP only (Samsung)
EOF
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

FLAG="$1"

case "$FLAG" in
  lg)
    echo "Switching to HDMI only (LG TV)"
    # IMPORTANT: enable first to avoid "all outputs disabled" state
    kscreen-doctor output."$HDMI".enable
    kscreen-doctor output."$DP".disable
    ;;

  sa)
    echo "Switching to DP only (Samsung)"
    # IMPORTANT: enable first to avoid "all outputs disabled" state
    kscreen-doctor output."$DP".enable
    kscreen-doctor output."$HDMI".disable
    ;;
esac
