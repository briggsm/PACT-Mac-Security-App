#!/bin/sh

if [[ "$1" != "-settingMeta"* ]] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-settingMeta [en|tr|ru] | -pf | -w]"
    exit 1
fi

if [[ "$1" == "-settingMeta"* ]]; then
    # Note: format is: (1)||(2)||(3)
    #   All must be present, even if null!
    # (1) - App Description (user-friendly name of the App)
	# (2) - Run -pf as "root" or "user"
	# (3) - Run -w  as "root" or "user"
	
	# Get Localized Description
	if [ "$1" == "-settingMeta tr" ]; then
        desc="Gizlilik modunu etkinleştir"
	elif [ "$1" == "-settingMeta ru" ]; then
		desc="Включен режим невидимки"
	else
		desc="Firewall Stealth Enabled"
    fi
	
	echo "$desc||user||root"
	exit 0
fi

if [ "$1" == "-pf" ]; then
	# Run as "user"
	fs=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode)
	if [[ $fs == *"Stealth mode enabled"* ]]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # Run as "root"
	/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on >/dev/null
    exit 0
fi
