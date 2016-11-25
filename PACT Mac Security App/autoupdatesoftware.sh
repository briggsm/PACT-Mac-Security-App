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
		echo "[tr]Software Update Enabled"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Software Update Enabled"
		exit 0
	fi
	
	# English
    echo "Software Update Enabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
    #asu=$(Sudo softwareupdate --schedule)
    # Note: need to run this with administrator privileges!
    asu=$(softwareupdate --schedule)
	if [ "$asu" = "Automatic check is on" ]; then
        echo "pass"
	else
        echo "fail"
	fi
    exit 0
fi

if [ "$1" == "-w" ]; then
	# Note: need to run this with administrator privileges!
	softwareupdate --schedule on >/dev/null
    exit 0
fi
