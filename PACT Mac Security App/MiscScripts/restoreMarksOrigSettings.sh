#!/bin/sh

me=$(whoami)
if [[ $me != "root" ]]; then
	echo "ERROR: MUST BE RUN AS ROOT!"
	echo "Usage: sudo $0"
	exit 1
fi

echo

macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
if [[ $SUDO_USER != "" ]]; then
    userOfAdminPriv=$SUDO_USER  # sudo
else
    userOfAdminPriv=$USER  # AppleScript 'with administrator privileges'
fi

# autologindisabled.sh
echo "* RESTORING: autologindisabled (deleting key: autoLoginUser. removing: /etc/kcpassword)"
defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser
rm /etc/kcpassword
echo

# autoupdatesoftware.sh
echo "* RESTORING: autoupdatesoftware (turning ON)"
softwareupdate --schedule on
echo

# bluetoothsharing.sh
echo "* RESTORING: bluetoothsharing (deleting ByHost key: com.apple.Bluetooth PrefKeyServicesEnabled)"
#defaults delete /Library/Preferences/com.apple.Bluetooth PrefKeyServicesEnabled
sudo -u $userOfAdminPriv defaults delete /users/$userOfAdminPriv/Library/Preferences/ByHost/com.apple.Bluetooth.$macUUID PrefKeyServicesEnabled
echo

# ds_store.sh
echo "* RESTORING: ds_store (deleting key: DSDontWriteNetworkStores)"
# Note: DO NOT NEED sudo
#defaults delete com.apple.desktopservices DSDontWriteNetworkStores
# Note: DO NEED sudo
defaults delete /Library/Preferences/com.apple.desktopservices DSDontWriteNetworkStores
echo

# firewallenabled.sh
echo "* RESTORING: firewallenabled (turning OFF)"
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
echo

# firewallstealth.sh
echo "* RESTORING: firewallstealth (turning OFF)"
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode off
echo

# guestaccount.sh
echo "* RESTORING: guestaccount (writing key: GuestEnabled to: NO)"
defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO
echo

# networkguestshared.sh
echo "* RESTORING: networkguestshared (writing key: AppleFileServer guestAccess NO, deleting key: smb.server AllowGuestAccess"
defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool NO
defaults delete /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess
echo

# remotedesktopmanagement.sh
echo "* RESTORING: remotedesktopmanagement (kickstart -deactivate -stop)"
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop
echo

# screensaver5sec.sh
echo "* RESTORING: screensaver5sec (askForPassword: 1, askForPasswordDelay: 5)"
#defaults write com.apple.screensaver askForPasswordDelay -int 5
sudo -u $userOfAdminPriv defaults write com.apple.screensaver askForPassword -int 1
sudo -u $userOfAdminPriv defaults write com.apple.screensaver askForPasswordDelay -int 5
echo

# screensaver10min.sh
echo "* RESTORING: screensaver10min (setting to 1800)"
#defaults -currentHost write com.apple.screensaver idleTime 1800
sudo -u $SUDO_USER defaults write /users/$SUDO_USER/Library/Preferences/ByHost/com.apple.screensaver.$macUUID idleTime 1800

echo

# screenturnoff.sh
#echo "* RESTORING: screenturnoff ()"
