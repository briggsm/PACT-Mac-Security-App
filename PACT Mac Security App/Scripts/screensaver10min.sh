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
		echo "[tr]Screensaver is set to activate after 10 minutes of inactivity"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Screensaver is set to activate after 10 minutes of inactivity"
		exit 0
	fi
	
	# English
    echo "Screensaver is set to activate after 10 minutes of inactivity"
    exit 0
fi

if [ "$1" == "-pf" ]; then
    it=$(defaults -currentHost read com.apple.screensaver idleTime)
    if [ $it -le "600" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # Note: DOES NOT NEED sudo
    macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
    defaults write /users/$SUDO_USER/Library/Preferences/ByHost/com.apple.screensaver.$macUUID idleTime 600
    exit 0
fi
