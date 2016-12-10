#!/bin/sh
# -d = Description (returns "" if setting not applicable given user's OS Version )
# -pf = Pass Fail
# -w = Write (changes the settings)

################################################################################################################
# Notes:
#    2>&1 redirect doesn't work in Xcode Debug mode. But works in final Released app.
#    -d,-pf  must be run/called as the USER.
#    -w      must always be run/called as ROOT.
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
if [ "$1" != "-settingMeta" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-settingMeta [en|tr|ru] | -pf | -w]"
    exit 1
fi

if [ "$1" == "-settingMeta" ]; then
    # Note: format is: (1)||(2)||(3)
    #   All must be present, even if null!
    # (1) - Setting Description (user-friendly name of the Setting)
    # (2) - Run -pf as "root" or "user"
    # (3) - Run -w  as "root" or "user"
    # Note: if this setting is N/A given user's OS Version, return "" (empty string) for Setting Description

    # Get Localized Description
	if [ "$2" == "tr" ]; then
		desc="[tr]Security Setting Description"
	elif [ "$2" == "ru" ]; then
		desc="[ru]Security Setting Description"
    else
        desc="Security Setting Description"
	fi

    echo "$desc||user||root"
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
