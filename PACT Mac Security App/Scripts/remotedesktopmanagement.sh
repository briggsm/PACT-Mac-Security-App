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
        desc="Uzaktan yönetim kapalıd"
	elif [ "$1" == "-settingMeta ru" ]; then
		desc="Удаленное управление отключено"
	else
		desc="Remote Management Disabled"
    fi
	
	echo "$desc||user||root"
	exit 0
fi

if [ "$1" == "-pf" ]; then
	# Run as "user"
	rdm=$(launchctl list | grep '^\d.*RemoteDesktop.*')
	if [ "$rdm" = "" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # Run as "root"
	/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop >/dev/null
    exit 0
fi
