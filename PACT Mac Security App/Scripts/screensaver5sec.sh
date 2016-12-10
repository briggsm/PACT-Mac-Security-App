#!/bin/sh

if [ "$1" != "-settingMeta" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-settingMeta [en|tr|ru] | -pf | -w]"
    exit 1
fi

if [ "$1" == "-settingMeta" ]; then
    # Note: format is: (1)||(2)||(3)
    #   All must be present, even if null!
    # (1) - App Description (user-friendly name of the App)
	# (2) - Run -pf as "root" or "user"
	# (3) - Run -w  as "root" or "user"
	
	# Get Localized Description
	if [ "$2" == "tr" ]; then
        desc="Ekran koruyucu veya uyku modu aktif olduğunda 5 sn içinde şifresiz girebilirsiniz"
	elif [ "$2" == "ru" ]; then
		desc="Требовать пароль через 5 секунд после включения заставки или спящего режима"
	else
		desc="Require password 5 seconds or less after sleep or screensaver is activated"
    fi
	
	echo "$desc||user||root"
	exit 0
fi

if [ "$1" == "-pf" ]; then
	# Run as "user"
	afp=$(defaults read com.apple.screensaver askForPassword)
	afpd=$(defaults read com.apple.screensaver askForPasswordDelay)
    if [ $afp == "1" ] && [ $afpd -le "5" ]; then
        echo "pass"
    else
        echo "fail"
    fi
    exit 0
fi

if [ "$1" == "-w" ]; then
    # Run as "root"
    if [[ $SUDO_USER != "" ]]; then
        userOfAdminPriv=$SUDO_USER  # sudo
    else
        userOfAdminPriv=$USER  # AppleScript 'with administrator privileges'
    fi
    sudo -u $userOfAdminPriv defaults write com.apple.screensaver askForPassword -int 1
    sudo -u $userOfAdminPriv defaults write com.apple.screensaver askForPasswordDelay -int 0
    exit 0
fi
