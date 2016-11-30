#!/bin/sh

if [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-d|-pf|-w]"
    exit 1
fi

if [ "$1" == "-d" ]; then
	# Turkish
	if [ "$2" == "tr" ]; then
		echo "Gizlilik modunu etkinleştir"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "Gizlilik modunu etkinleştir"
		exit 0
	fi
	
	# English
    echo "Firewall Stealth Enabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	fs=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode)
	if [[ $fs == *"Stealth mode enabled"* ]]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # Remember: -w ALWAYS gets run as root!
	/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on >/dev/null
    exit 0
fi
