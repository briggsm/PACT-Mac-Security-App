#!/bin/sh

if [ "$1" != "-a" ] && [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-a|-d|-pf|-w]"
    exit 1
fi

if [ "$1" == "-a" ]; then
    	echo "true"
    exit 0
fi

if [ "$1" == "-d" ]; then
	# Turkish
	if [ "$2" == "tr" ]; then
		echo "[tr]Software Update Enabled"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Software Update Enabled"
		exit 0
	fi
	
	# English
    echo "Software Update Enabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
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
	# Remember: -w ALWAYS gets run as root!
	defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool TRUE
	defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool TRUE
	exit 0
fi
