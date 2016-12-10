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
        desc=".DS_Store Ağı kapalı"
	elif [ "$2" == "ru" ]; then
		desc="Сеть .DS_Store отключена"
	else
		desc="Network .DS_Store Disabled"
    fi
	
	echo "$desc||user||root"
	exit 0
fi

if [ "$1" == "-pf" ]; then
	# Run as "user"
    ds=$(defaults read /Library/Preferences/com.apple.desktopservices DSDontWriteNetworkStores)
	if [[ $ds == "1" ]]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
	# Run as "root"
	defaults write /Library/Preferences/com.apple.desktopservices DSDontWriteNetworkStores -bool true
    exit 0
fi
