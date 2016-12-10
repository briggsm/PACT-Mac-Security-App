#!/bin/sh

if [ "$1" != "-settingMeta" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-settingMeta [en|tr|ru] | -pf | -w]"
    exit 1
fi

if [ "$1" == "-settingMeta" ]; then
    # Note: format is: (1)||(2)||(3)
    #   All must be present, even if null!
    # (1) - App Description (user-friendly name of the App)
	# (2) - Run -pf as "root" or "user"
	# (3) - Run -w  as "root" or "user"
	
	# Get Localized Description
	if [ "$2" == "tr" ]; then
        desc="Bluetooth paylaşımı kapalı"
	elif [ "$2" == "ru" ]; then
		desc="Общий доступ по блютуз выключен"
	else
		desc="Bluetooth Sharing Disabled"
    fi
	
	echo "$desc||user||root"
	exit 0
fi

if [[ "$1" == "-pf" ]]; then
	# Run as "user"
    ds=$(defaults -currentHost read com.apple.Bluetooth PrefKeyServicesEnabled)

	if [[ $ds == "0" ]]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [[ "$1" == "-w" ]]; then
    # Run as "root"
    macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
    if [[ $SUDO_USER != "" ]]; then
        userOfAdminPriv=$SUDO_USER  # sudo
    else
        userOfAdminPriv=$USER  # AppleScript 'with administrator privileges'
    fi
    sudo -u $userOfAdminPriv defaults write /users/$userOfAdminPriv/Library/Preferences/ByHost/com.apple.Bluetooth.$macUUID PrefKeyServicesEnabled 0
    exit 0
fi
