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
		echo "[tr]Bluetooth Sharing Disabled"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Bluetooth Sharing Disabled"
		exit 0
	fi
	
	# English
    echo "Bluetooth Sharing Disabled"
    exit 0
fi

if [[ "$1" == "-pf" ]]; then
	ds=$(defaults -currentHost read com.apple.Bluetooth PrefKeyServicesEnabled 2>&1)
	if [[ $ds == "0" ]]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [[ "$1" == "-w" ]]; then
    # Note: need to run this with administrator privileges!
    macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
    if [[ $SUDO_USER != "" ]]; then
        userOfAdminPriv=$SUDO_USER  # sudo
    else
        userOfAdminPriv=$USER  # AppleScript 'with administrator privileges'
    fi
    #sudo -u $USER defaults write /users/$USER/Library/Preferences/ByHost/com.apple.Bluetooth.$macUUID PrefKeyServicesEnabled 0
    sudo -u $userOfAdminPriv defaults write /users/$userOfAdminPriv/Library/Preferences/ByHost/com.apple.Bluetooth.$macUUID PrefKeyServicesEnabled 0
    exit 0
fi
