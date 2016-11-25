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
	gafs=$(defaults read /Library/Preferences/com.apple.AppleFileServer guestAccess 2>&1)
	gsmb=$(defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess 2>&1)
	if [[ $gafs == *"does not exist"* ]] || [[ $gafs == *"0"* ]]; then
       if [[ $gsmb == *"does not exist"* ]] || [[ $gsmb == *"0"* ]]; then
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
    # Note: need to run this with administrator privileges!
	defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool NO

    # Note: need to run this with administrator privileges!
	defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool NO
    exit 0
fi
