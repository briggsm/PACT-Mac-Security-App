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
    echo "Auto Login Disabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	ald=$(defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser)
	if [ "$ald" = "1" ]; then
        echo "fail"
    else
        echo "pass"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
	defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser
	rm /etc/kcpassword
    exit 0
fi
