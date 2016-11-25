#!/bin/sh

me=$(whoami)
if [[ $me != "root" ]]; then
	echo "ERROR: MUST BE RUN AS ROOT!"
	echo "Usage: sudo $0"
	exit 1
fi
# autologindisabled
echo "RESTORING: autologindisabled (deleting key: autoLoginUser. removing: /etc/kcpassword)"
defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser
rm /etc/kcpassword

# autoupdatesoftware
echo "RESTORING: autoupdatesoftware (turning ON)"
softwareupdate --schedule on

# bluetoothsharing.sh
echo "RESTORING: bluetoothsharing"
echo "!!!!! Not sure what to do yet !!!!!"
# sudo -u$USERNAME defaults -currentHost write com.apple.bluetooth PrefKeyServicesEnabled 0

# ds_store.sh
echo "RESTORING: ds_store (deleting key: DSDontWriteNetworkStores)"
# Note: DO NOT NEED sudo
defaults delete com.apple.desktopservices DSDontWriteNetworkStores

# firewallenabled.sh
echo "RESTORING: firewallenabled (turning OFF)"
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off

# firewallstealth.sh
echo "RESTORING: firewallstealth (turning OFF)"
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode off

# guestaccount.sh
echo "RESTORING: guestaccount (writing key: GuestEnabled to: NO)"
defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO

# networkguestshared.sh
echo "RESTORING: networkguestshared (writing key: AppleFileServer guestAccess NO, deleting key: smb.server AllowGuestAccess"
defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool NO
defaults delete /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess

# remotedesktopmanagement.sh
echo "RESTORING: remotedesktopmanagement (kickstart -deactivate -stop)"
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop

# screensaver5sec.sh
echo "RESTORING: screensaver5sec (setting to 5)"
defaults write com.apple.screensaver askForPasswordDelay -int 5

# screensaver10min.sh
echo "RESTORING: screensaver10min (setting to 1800)"
defaults -currentHost write com.apple.screensaver idleTime 1800

# screenturnoff.sh
#echo "RESTORING: screenturnoff ()"
