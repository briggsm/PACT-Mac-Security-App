#!/bin/sh

if [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-d|-pf|-w]"
    exit 1
fi

if [ "$1" == "-d" ]; then
	# Turkish
	if [ "$2" == "tr" ]; then
		echo "Bluetooth paylaşımı kapalı"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "Общий доступ по блютуз выключен"
		exit 0
	fi
	
	# English
    echo "Bluetooth Sharing Disabled"
    exit 0
fi

if [[ "$1" == "-pf" ]]; then
    ds=$(defaults -currentHost read com.apple.Bluetooth PrefKeyServicesEnabled)

	if [[ $ds == "0" ]]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [[ "$1" == "-w" ]]; then
    # Remember: -w ALWAYS gets run as root!
    macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
    if [[ $SUDO_USER != "" ]]; then
        userOfAdminPriv=$SUDO_USER  # sudo
    else
        userOfAdminPriv=$USER  # AppleScript 'with administrator privileges'
    fi
    sudo -u $userOfAdminPriv defaults write /users/$userOfAdminPriv/Library/Preferences/ByHost/com.apple.Bluetooth.$macUUID PrefKeyServicesEnabled 0
    exit 0
fi
