#!/bin/sh

if [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-d|-pf|-w]"
    exit 1
fi

if [ "$1" == "-d" ]; then
	# Turkish
    if [ "$2" == "tr" ]; then
		echo "Ekran koruyucu veya uyku modu aktif olduğunda 5 sn içinde şifresiz girebilirsiniz"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "Требовать пароль через 5 секунд после включения заставки или спящего режима"
		exit 0
	fi
	
	# English
	echo "Require password 5 seconds or less after sleep or screensaver is activated"
    exit 0
fi

if [ "$1" == "-pf" ]; then
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
    # Remember: -w ALWAYS gets run as root!
    if [[ $SUDO_USER != "" ]]; then
        userOfAdminPriv=$SUDO_USER  # sudo
    else
        userOfAdminPriv=$USER  # AppleScript 'with administrator privileges'
    fi
    sudo -u $userOfAdminPriv defaults write com.apple.screensaver askForPassword -int 1
    sudo -u $userOfAdminPriv defaults write com.apple.screensaver askForPasswordDelay -int 0
    exit 0
fi
