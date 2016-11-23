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
		echo "[tr]Firewall Stealth Enabled"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Firewall Stealth Enabled"
		exit 0
	fi
	
	# English
    echo "Firewall Stealth Enabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	fs=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode)
	if [ "$fs" = "Stealth mode enabled" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
	/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on >/dev/null
    exit 0
fi
