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
        desc="Ziyaretçi hesabı kapalı"
	elif [ "$1" == "-settingMeta ru" ]; then
		desc="Гостевой вход отключен"
	else
		desc="Guest Account Disabled"
    fi
	
	echo "$desc||user||root"
	exit 0
fi

if [ "$1" == "-pf" ]; then
	# Run as "user"
	ga=$(defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled)
	if [ $ga == "0" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # Run as "root"
	defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO
    /usr/bin/dscl . -mcxdelete /Users/Guest >/dev/null
    exit 0
fi
