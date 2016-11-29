#!/bin/sh

if [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-d|-pf|-w]"
    exit 1
fi

if [ "$1" == "-d" ]; then
	# Turkish
	if [ "$2" == "tr" ]; then
		echo "[tr]Auto Login Disabled"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Auto Login Disabled"
		exit 0
	fi
	
	# English
    echo "Auto Login Disabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
    ald=$(defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser)
    if [[ $ald == "" ]] && [[ ! -e /etc/kcpassword ]]; then
		echo "pass"
	else
		echo "fail"
	fi
	exit 0
fi

if [ "$1" == "-w" ]; then
    # Remember: -w ALWAYS gets run as root!
	defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser
	rm /etc/kcpassword
	exit 0
fi
