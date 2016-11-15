#!/bin/sh

if [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-d|-r|-w]"
    exit 1
fi

if [ "$1" == "-d" ]; then
    echo "Screensaver is set to activate after 10 minutes of inactivity"
    exit 0
fi

if [ "$1" == "-pf" ]; then
    #defaults -currentHost read com.apple.screensaver idleTime
    # TODO - add logic to determine pass/fail
    echo "fail"
    exit 0
fi

if [ "$1" == "-w" ]; then
    defaults -currentHost write com.apple.screensaver idleTime 600

    # Note: Mark's setting
    #defaults -currentHost write com.apple.screensaver idleTime 1800
fi
