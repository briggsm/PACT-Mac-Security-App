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
    echo "Firewall Enabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	fe=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate)
	if [ $fe == "Firewall is enabled. (State = 1)" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
	/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on >/dev/null
    exit 0
fi