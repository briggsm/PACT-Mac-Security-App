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
    echo "Software Update On"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	asu=$(Sudo softwareupdate --schedule)
	if [ "$asu" = "Automatic check is on" ]; then
        echo "pass"
	else
        echo "fail"
	fi
    exit 0
fi

if [ "$1" == "-w" ]; then
	softwareupdate --schedule on >/dev/null
    exit 0
fi
