#!/bin/sh

if [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-d|-pf|-w]"
    exit 1
fi

if [ "$1" == "-d" ]; then
	# Turkish
	if [ "$2" == "tr" ]; then
		echo "[tr]Network .DS_Store Disabled"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Network .DS_Store Disabled"
		exit 0
	fi
	
	# English
    echo "Network .DS_Store Disabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
    ds=$(defaults read /Library/Preferences/com.apple.desktopservices DSDontWriteNetworkStores)
	if [[ $ds == "1" ]]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # Remember: -w ALWAYS gets run as root!
	defaults write /Library/Preferences/com.apple.desktopservices DSDontWriteNetworkStores -bool true
    exit 0
fi
