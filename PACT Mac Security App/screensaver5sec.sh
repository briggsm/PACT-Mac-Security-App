#!/bin/sh

#if [ "$1" != "-d" ] && [ "$1" != "-r" ] && [ "$1" != "-w" ]; then
if [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-d|-r|-w]"
    exit 1
fi

if [ "$1" == "-d" ]; then
    echo "Require password 5 seconds after sleep or screensaver is activated"
    exit 0
fi

#if [ "$1" == "-r" ]; then
#    defaults read com.apple.screensaver
#    exit 0
#fi

if [ "$1" == "-pf" ]; then
#afp = defaults read com.apple.screensaver askForPassword
#afpd = defaults read com.apple.screensaver askForPasswordDelay
#TODO - add logic to determine whether the current security settings of computer result in "pass" or "fail". Note: only allow this to output "pass" or "fail" to stdout (everything else should be sent to /dev/null
    echo "pass"
    exit 0
fi

if [ "$1" == "-w" ]; then
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    # Note: Mark's setting
    #defaults write com.apple.screensaver askForPasswordDelay -int 5
fi
