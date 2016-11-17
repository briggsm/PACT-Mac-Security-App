#!/bin/sh

if [ "$1" != "-a" ] && [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-a|-d|-pf|-w]"
    exit 1
fi

if [ "$1" == "-a" ]; then
    # TODO - add OS Version logic here
    echo "true"
    exit 0
fi

if [ "$1" == "-d" ]; then
    echo "Screensaver is set to activate after 10 minutes of inactivity"
    exit 0
fi

if [ "$1" == "-pf" ]; then
    #defaults -currentHost read com.apple.screensaver idleTime
    # TODO - add logic to determine pass/fail
    #echo "fail"
    it=$(defaults -currentHost read com.apple.screensaver idleTime)
    if [ $it -le "600" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    defaults -currentHost write com.apple.screensaver idleTime 600

    # Note: Mark's setting
    #defaults -currentHost write com.apple.screensaver idleTime 1800
	exit 0
fi
