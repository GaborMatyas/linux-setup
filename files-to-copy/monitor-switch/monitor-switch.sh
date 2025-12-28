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
  lgsa   -> Both enabled, HDMI on the left, DP on the right (extended, not mirrored)
EOF
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

FLAG="$1"

# Helper: get current width from Geometry line (respects KDE defaults)
get_width() {
  local out="$1"
  kscreen-doctor -o | awk -v out="$out" '
    $1=="Output:" && $3==out {in=1; next}
    in && $1=="Geometry:" {
      # Geometry: X,Y WxH   -> $3 is WxH
      split($3,a,"x"); print a[1]; exit
    }
  '
}

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

  lgsa)
    echo "Enabling both outputs (extended), HDMI left / DP right"
    kscreen-doctor output."$HDMI".enable
    kscreen-doctor output."$DP".enable

    usage
    ;;
esac
