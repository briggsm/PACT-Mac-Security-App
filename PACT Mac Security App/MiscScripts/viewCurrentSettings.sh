#!/bin/sh
# Note: should NOT need SUDO for any of these...

printf "\n"

# autologindisabled.sh
printf "* autologindisabled\n"
ald=$(defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser 2>&1)
if [[ $ald == *"does not exist"* ]]; then
	ald="DOES NOT EXIST (pass)"
fi
printf "defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser: %s\n\n" "$ald"

# autoupdatesoftware.sh
printf "* autoupdatesoftware\n"
printf "!!!!!!!! skipping for now !!!!!!!!!!\n\n"

# bluetoothsharing.sh
printf "* bluetoothsharing\n"
ds=$(defaults -currentHost read com.apple.bluetooth PrefKeyServicesEnabled 2>&1)
if [[ $ds == *"does not exist"* ]]; then
	ds="DOES NOT EXIST (fail)"
fi
printf "defaults -currentHost read com.apple.bluetooth PrefKeyServicesEnabled: %s\n\n" "$ds"

# ds_store.sh
printf "* ds_store\n"
ds=$(defaults read com.apple.desktopservices DSDontWriteNetworkStores 2>&1)
if [[ $ds == *"does not exist"* ]]; then
	ds="DOES NOT EXIST (fail)"
fi
printf "defaults read com.apple.desktopservices DSDontWriteNetworkStores: %s\n\n" "$ds"

# firewallenabled.sh
printf "* firewallenabled\n"
fe=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate)
printf "/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate: %s\n\n" "$fe"

# firewallstealth.sh
printf "* firewallstealth\n"
fs=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode)
printf "/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode: %s\n\n" "$fs"

# guestaccount.sh
printf "* guestaccount\n"
ga=$(defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled)
if [[ $ga == *"does not exist"* ]]; then
	ga="DOES NOT EXIST (pass?)"
fi
printf "defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled: %s\n\n" "$ga"

# networkguestshared.sh
printf "* networkguestshared\n"
gafs=$(defaults read /Library/Preferences/com.apple.AppleFileServer guestAccess 2>&1)
gsmb=$(defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess 2>&1)
if [[ $gafs == *"does not exist"* ]]; then
	gafs="DOES NOT EXIST (pass)"
fi
if [[ $gsmb == *"does not exist"* ]]; then
	gsmb="DOES NOT EXIST (pass)"
fi
printf "defaults read /Library/Preferences/com.apple.AppleFileServer guestAccess: %s\n" "$gafs"
printf "defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess: %s\n\n" "$gsmb"

# remotedesktopmanagement.sh
printf "* remotedesktopmanagement\n"
rdm=$(launchctl list | grep '^\d.*RemoteDesktop.*')
if [ "$rdm" = "" ]; then
	rdm="EMPTY STRING (pass)"
fi
printf "launchctl list | grep '^\d.*RemoteDesktop.*': %s\n\n" "$rdm"

# screensaver5sec.sh
printf "* screensaver5sec\n"
printf "defaults read com.apple.screensaver askForPassword: %s\n" $(defaults read com.apple.screensaver askForPassword)
printf "defaults read com.apple.screensaver askForPasswordDelay: %s\n\n" $(defaults read com.apple.screensaver askForPasswordDelay)

# screensaver10min.sh
printf "* screensaver10min\n"
printf "defaults -currentHost read com.apple.screensaver idleTime: %s\n\n" $(defaults -currentHost read com.apple.screensaver idleTime)
