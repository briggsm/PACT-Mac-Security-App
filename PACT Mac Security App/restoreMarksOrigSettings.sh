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

# Require password 5 seconds after sleep or screensaver is activated
echo "RESTORING: screensaver5sec (setting to 5)"
defaults write com.apple.screensaver askForPasswordDelay -int 5

# Screensaver is set to activate after 10 minutes of inactivity
echo "RESTORING: screensaver10min (setting to 1800)"
defaults -currentHost write com.apple.screensaver idleTime 1800

