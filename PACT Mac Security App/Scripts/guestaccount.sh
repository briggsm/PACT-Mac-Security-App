#!/bin/sh

if [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-d|-pf|-w]"
    exit 1
fi

if [ "$1" == "-d" ]; then
	# Turkish
	if [ "$2" == "tr" ]; then
		echo "[tr]Guest Account Disabled"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Guest Account Disabled"
		exit 0
	fi
	
	# English
    echo "Guest Account Disabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	ga=$(defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled)
	if [ $ga == "0" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # Remember: -w ALWAYS gets run as root!
	defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO
    /usr/bin/dscl . -mcxdelete /Users/Guest >/dev/null
    exit 0
fi
