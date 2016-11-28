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
		echo "[tr]Require password 5 seconds or less after sleep or screensaver is activated"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Require password 5 seconds or less after sleep or screensaver is activated"
		exit 0
	fi
	
	# English
	echo "Require password 5 seconds or less after sleep or screensaver is activated"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	afp=$(defaults read com.apple.screensaver askForPassword)
	afpd=$(defaults read com.apple.screensaver askForPasswordDelay)
    if [ $afp == "1" ] && [ $afpd -le "5" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # Note: DOES NOT NEED sudo
    defaults write /users/$SUDO_USER/Library/Preferences/com.apple.screensaver askForPassword -int 1

    # Note: DOES NOT NEED sudo
    defaults write /users/$SUDO_USER/Library/Preferences/com.apple.screensaver askForPasswordDelay -int 0

    exit 0
fi
