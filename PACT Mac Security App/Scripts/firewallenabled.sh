#!/bin/sh

if [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-d|-pf|-w]"
    exit 1
fi

if [ "$1" == "-d" ]; then
	# Turkish
	if [ "$2" == "tr" ]; then
		echo "Güvenlik duvarı etkin"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "Güvenlik duvarı etkin"
		exit 0
	fi
	
	# English
    echo "Firewall Enabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	fe=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate)
	if [[ $fe == *"Firewall is enabled. (State = 1)"* ]]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # Remember: -w ALWAYS gets run as root!
    /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on >/dev/null
    exit 0
fi
