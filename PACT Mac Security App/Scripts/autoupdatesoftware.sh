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
        desc="Yazılım güncelleştirmesi etkin"
	elif [ "$2" == "ru" ]; then
		desc="Обновление программ включено"
	else
		desc="Software Update Enabled"
    fi
	
	echo "$desc||user||root"
	exit 0
fi

if [ "$1" == "-pf" ]; then
	# Run as "user"
    asu=$(defaults read /Library/Preferences/com.apple.commerce AutoUpdate)
    aurr=$(defaults read /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired)
	if [[ $asu == "1" ]] && [[ $aurr == "1" ]]; then
        echo "pass"
	else
        echo "fail"
	fi
    exit 0
fi

if [ "$1" == "-w" ]; then
	# Run as "root"
	defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool TRUE
	defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool TRUE
	exit 0
fi
