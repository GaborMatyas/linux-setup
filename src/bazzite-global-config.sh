# This part disables the hybernation and turning off display behaviour when the user is idle
kwriteconfig6 --file powermanagementprofilesrc --group AC --group DimDisplay --key idleTime 0
kwriteconfig6 --file powermanagementprofilesrc --group AC --group HandleButtonEvents --key lidAction 0
kwriteconfig6 --file powermanagementprofilesrc --group AC --group SuspendSession --key idleTime 0
kwriteconfig6 --file powermanagementprofilesrc --group AC --group SuspendSession --key suspendType 0
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 0
kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockOnResume false
kwriteconfig6 --file powermanagementprofilesrc --group AC --group DPMSControl --key idleTime 0
echo "==> Power management and screen locker is modified so the system is not hibernated in any cases if user is idle"
