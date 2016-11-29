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
		echo "[tr]Network Guest Shared Disabled"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Network Guest Shared Disabled"
		exit 0
	fi
	
	# English
    echo "Network Guest Shared Disabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
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
    # Remember: -w ALWAYS gets run as root!
	defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool NO
	defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool NO
    exit 0
fi
