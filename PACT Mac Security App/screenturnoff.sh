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
		echo "[tk]Screen Turn off 5 min or less"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Screen Turn off 5 min or less"
		exit 0
	fi
	
	# English
    echo "Screen Turn off 5 min or less"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	cst=$(sudo pmset -g | awk '$1=="sleep" {print $2}')
	dst=$(sudo pmset -g | awk '$1=="displaysleep" {print $2}')
	echo "$cst"
	echo "$dst"
	if [[ $cst -le 5 ]] && [[ $dst -le 5  ]]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    #defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    exit 0
fi
