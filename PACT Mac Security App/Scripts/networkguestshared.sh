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
        desc="Ziyaretçi Ağ paylaşımı kapalı"
	elif [ "$2" == "ru" ]; then
		desc="Общий доступ для гостей отключен"
	else
		desc="Network Guest Shared Disabled"
    fi
	
	echo "$desc||user||root"
	exit 0
fi

if [ "$1" == "-pf" ]; then
	# Run as "user"
    gafs=$(defaults read /Library/Preferences/com.apple.AppleFileServer guestAccess)
    gsmb=$(defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess)

    if [[ $gafs == "" ]] || [[ $gafs == "0" ]]; then
        if [[ $gsmb == "" ]] || [[ $gsmb == "0" ]]; then
            echo "pass"
        else
            echo "fail"
        fi
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # Run as "root"
	defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool NO
	defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool NO
    exit 0
fi
