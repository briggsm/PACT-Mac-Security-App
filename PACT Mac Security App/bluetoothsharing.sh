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
    echo "Bluetooth Sharing Disabled"
    exit 0
fi

if [ "$1" == "-pf" ]; then
	osversionlong=$(uname -r)
	osvers=${osversionlong/.*/}
	if [[ ${osvers} -ge 12 ]]; then
		ds=$(defaults -currentHost read com.apple.bluetooth)
	else
		ds=$(defaults -currentHost read com.apple.Bluetooth)
	fi
	if [ $ds == "1" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
	osversionlong=$(uname -r)
	osvers=${osversionlong/.*/}
	if [[ ${osvers} -ge 12 ]]; then
		sudo -u$USERNAME defaults -currentHost write com.apple.bluetooth PrefKeyServicesEnabled 0
	else
  		sudo -u$USERNAME defaults -currentHost write com.apple.Bluetooth PrefKeyServicesEnabled 0
	fi
    exit 0
fi