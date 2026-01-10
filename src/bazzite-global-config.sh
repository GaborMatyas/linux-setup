#!/usr/bin/env bash
set -euo pipefail

# Setup utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"
source "${REPO_ROOT}/src/utils/common.sh"

section_header "Configuring KDE Power Management & Screen Locking"

# ---------------------------
# Power management settings
# ---------------------------
log_info "Configuring power management..."

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

log_success "Power management configured"
log_result "Dim screen" "After 2 minutes"
log_result "DPMS screen-off" "Disabled"
log_result "Idle suspend" "Disabled"

# ---------------------------
# Screen locking settings
# ---------------------------
log_info "Configuring screen locking..."

kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock true
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 2
kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockGrace 300
kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockOnResume true

log_success "Screen locking configured"
log_result "Auto-lock" "After 2 minutes"
log_result "Password grace" "5 minutes"
log_result "Lock on resume" "Enabled"

# ---------------------------
# Validation
# ---------------------------
log_info "Validating applied settings..."

log_result "DimDisplay idleTime" "$(kreadconfig6 --file powermanagementprofilesrc --group AC --group DimDisplay --key idleTime || true) minutes"
log_result "DPMSControl idleTime" "$(kreadconfig6 --file powermanagementprofilesrc --group AC --group DPMSControl --key idleTime || true) minutes"
log_result "Autolock" "$(kreadconfig6 --file kscreenlockerrc --group Daemon --key Autolock || true)"
log_result "Lock timeout" "$(kreadconfig6 --file kscreenlockerrc --group Daemon --key Timeout || true) minutes"

log_warn "Changes may require logout/reboot to take effect"

section_end
