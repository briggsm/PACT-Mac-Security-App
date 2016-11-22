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
    echo "Guest Account Disabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	ga=$(defaults read  /Library/Preferences/com.apple.loginwindow GuestEnabled)
	if [ $ga == "0" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
	defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO
	/usr/bin/dscl . -mcxdelete /Users/Guest >/dev/null
    exit 0
fi
