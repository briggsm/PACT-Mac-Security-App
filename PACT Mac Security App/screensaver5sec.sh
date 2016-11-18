#!/bin/sh
# -a = OS Version check
# -d = Discription
# -pf = Pass Fail
# -w = Write (changes the settings)
if [ "$1" != "-a" ] && [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-a|-d|-pf|-w]"
    exit 1
fi

if [ "$1" == "-a" ]; then
#	osversionlong=$(uname -r)
#	osvers=${osversionlong/.*/}
#	if [[ ${osvers} -eq 16 ]]; then
    	echo "true"
#    # Don't really know what to do next here.
    exit 0
#    fi
fi

if [ "$1" == "-d" ]; then
    echo "Require password 5 seconds or less after sleep or screensaver is activated"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	afp=$(defaults read com.apple.screensaver askForPassword)
	afpd=$(defaults read com.apple.screensaver askForPasswordDelay)
    if [ $afp == "1" ] && [ $afpd > "6" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0	
	exit 0
fi
