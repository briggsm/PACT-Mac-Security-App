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
    echo ".DS_Store files on network volumes Disabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	ds=$(defaults read com.apple.desktopservices DSDontWriteNetworkStores)
	if [ $ds == "1" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    exit 0
fi
