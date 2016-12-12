#!/bin/sh

if [[ "$1" != "-settingMeta"* ]] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-settingMeta [en|tr|ru] | -pf | -w]"
    exit 1
fi

if [[ "$1" == "-settingMeta"* ]]; then
    # Note: format is: (1)||(2)||(3)
    #   All must be present, even if null!
    # (1) - App Description (user-friendly name of the App)
	# (2) - Run -pf as "root" or "user"
	# (3) - Run -w  as "root" or "user"
	
	# Get Localized Description
	if [ "$1" == "-settingMeta tr" ]; then
        desc="Ekran koruyucu, 10 dakika boyunca işlem yapılmadığında etkinleştirilecek"
	elif [ "$1" == "-settingMeta ru" ]; then
		desc="Заставка будет включена через 10 минут отсутствия активности"
	else
		desc="Screensaver is set to activate after 10 minutes of inactivity"
    fi
	
	echo "$desc||user||user"
	exit 0
fi

if [ "$1" == "-pf" ]; then
	# Run as "user"
    it=$(defaults -currentHost read com.apple.screensaver idleTime)
    if [ $it -le "600" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # # Run as "root"
    # macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
    # if [[ $SUDO_USER != "" ]]; then
    #     userOfAdminPriv=$SUDO_USER  # sudo
    # else
    #     userOfAdminPriv=$USER  # AppleScript 'with administrator privileges'
    # fi
    # sudo -u $userOfAdminPriv defaults write /users/$userOfAdminPriv/Library/Preferences/ByHost/com.apple.screensaver.$macUUID idleTime 600
    # exit 0
	
	# Run as "user"
	defaults -currentHost write com.apple.screensaver idleTime 600
fi
