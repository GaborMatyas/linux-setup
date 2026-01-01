#!/usr/bin/env bash
set -euo pipefail

echo
echo "==> Configuring KDE power management + screen locking..."

# ---------------------------
# Power management settings
# ---------------------------
# Goal: prevent suspend/hibernate due to idle on AC power
# Dim screen after 2 minutes (requested)
# Keep screen ON (disable DPMS screen-off)

# Dim automatically after 2 minutes idle
kwriteconfig6 --file powermanagementprofilesrc --group AC --group DimDisplay --key idleTime 5

# Disable turning off the screen via DPMS
kwriteconfig6 --file powermanagementprofilesrc --group AC --group DPMSControl --key idleTime 0

# Disable suspend/hibernate due to idle
kwriteconfig6 --file powermanagementprofilesrc --group AC --group SuspendSession --key idleTime 0
kwriteconfig6 --file powermanagementprofilesrc --group AC --group SuspendSession --key suspendType 0

# Lid action (0 usually means "do nothing")
kwriteconfig6 --file powermanagementprofilesrc --group AC --group HandleButtonEvents --key lidAction 0
kwriteconfig6 --file powermanagementprofilesrc --group AC --group HandleButtonEvents --key powerButtonAction 16

echo "==> Power management configured: dim after 2 minutes; no idle suspend/hibernate; no idle DPMS on AC."


# ---------------------------
# Screen locking settings
# ---------------------------
# Requirements:
# - Lock screen automatically in 2 minutes
# - Delay before password required: 5 minutes
# - Lock on resume: enabled

kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock true
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 2
kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockGrace 300
kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockOnResume true

echo "==> Screen locking configured: auto-lock after 2 minutes; password required after 5 minutes; lock on resume enabled."


# ---------------------------
# Validation (prints current values)
# ---------------------------
echo
echo "==> Validating applied settings..."

echo "Power management (AC profile):"
echo "  DimDisplay idleTime:     $(kreadconfig6 --file powermanagementprofilesrc --group AC --group DimDisplay --key idleTime || true) minutes"
echo "  DPMSControl idleTime:    $(kreadconfig6 --file powermanagementprofilesrc --group AC --group DPMSControl --key idleTime || true) minutes"
echo "  SuspendSession idleTime: $(kreadconfig6 --file powermanagementprofilesrc --group AC --group SuspendSession --key idleTime || true)"
echo "  SuspendSession suspendType: $(kreadconfig6 --file powermanagementprofilesrc --group AC --group SuspendSession --key suspendType || true)"
echo "  Lid action:              $(kreadconfig6 --file powermanagementprofilesrc --group AC --group HandleButtonEvents --key lidAction || true)"

echo
echo "Screen locking:"
echo "  Autolock:      $(kreadconfig6 --file kscreenlockerrc --group Daemon --key Autolock || true)"
echo "  Timeout:       $(kreadconfig6 --file kscreenlockerrc --group Daemon --key Timeout || true) minutes"
echo "  LockGrace:     $(kreadconfig6 --file kscreenlockerrc --group Daemon --key LockGrace || true) seconds"
echo "  LockOnResume:  $(kreadconfig6 --file kscreenlockerrc --group Daemon --key LockOnResume || true)"

echo
echo "==> Done."
echo "==> NOTE: If changes do not apply immediately, log out/in or reboot KDE Plasma."
