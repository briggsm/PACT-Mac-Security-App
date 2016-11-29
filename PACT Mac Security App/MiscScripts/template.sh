#!/bin/sh
# -a = OS Version check
# -d = Discription
# -pf = Pass Fail
# -w = Write (changes the settings)

################################################################################################################
# Notes:
#    2>&1 redirect doesn't work in Xcode Debug mode. But works in final Released app.
#    -a,-d,-pf  must be run as the USER.
#   -w          must always be run as ROOT.
#
#  Note: when called from command-line prepended with "sudo":
#    $USER ==> root
#    $SUDO_USER ==> username
#  When called from AppleScript "with administrator privileges":
#    $USER ==> username
#    $SUDO_USER ==> ""
#
#  If need to drop from root, the user of root/sudo:
#    macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
#    if [[ $SUDO_USER != "" ]]; then
#        userOfAdminPriv=$SUDO_USER  # sudo
#    else
#        userOfAdminPriv=$USER  # AppleScript 'with administrator privileges'
#    fi
#    sudo -u $userOfAdminPriv defaults write ...
#
#  osvers is 10 for 10.6, 11 for 10.7, 12 for 10.8, 13 for 10.9 etc. 16 for 10.12
#  osversionlong=$(uname -r)
#  osvers=${osversionlong/.*/}
#  if [[ ${osvers} -ge 16 ]]; then ...
#
################################################################################################################
if [ "$1" != "-a" ] && [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-a | -d [en|tr|ru] | -pf | -w]"
    exit 1
fi

if [ "$1" == "-a" ]; then
    # -a => Applicable given user's OS Version.
	# Must echo only "true" or "false". *Nothing* else!
    echo "true"
    exit 0
fi

if [ "$1" == "-d" ]; then
	# -d => This Security Setting's Description (will show up as the line-item in the GUI)
	# Turkish
	if [ "$2" == "tr" ]; then
		echo "[tr]Security Setting Description"
		exit 0
	fi
	
	# Russian
	if [ "$2" == "ru" ]; then
		echo "[ru]Security Setting Description"
		exit 0
	fi
	
	# English
	echo "Security Setting Description"
	exit 0
fi

if [ "$1" == "-pf" ]; then
	# -pf => Does this security setting currently "pass" or "fail" on user's system
	# Must echo only "pass" or "fail". *Nothing* else!
    echo "pass"
    exit 0
fi

if [ "$1" == "-w" ]; then
	# -w => Write the Setting to user's system (eg. "defaults write" command)
	# Currently no need to echo anything. If anything is echo'd it's not currently used by the app

    # Remember: -w ALWAYS gets run as root!
    exit 0
fi
