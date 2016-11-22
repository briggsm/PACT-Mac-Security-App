#!/bin/sh
# -a = OS Version check
# -d = Discription
# -pf = Pass Fail
# -w = Write (changes the settings)

if [ "$1" != "-a" ] && [ "$1" != "-d" ] && [ "$1" != "-pf" ] && [ "$1" != "-w" ]; then
    echo "Usage: $0 [-a|-d|-pf|-w]"
    exit 1
fi

# osvers is 10 for 10.6, 11 for 10.7, 12 for 10.8, 13 for 10.9 etc. 16 for 10.12
if [ "$1" == "-a" ]; then
    # -a => Applicable given user's OS Version.
	# Must echo only "true" or "false". *Nothing* else!
#	osversionlong=$(uname -r)
#	osvers=${osversionlong/.*/}
#	if [[ ${osvers} -ge 16 ]]; then
    	echo "true"
#    else
#    	echo "false"
#	fi
    exit 0
fi

if [ "$1" == "-d" ]; then
	# -d => This Security Setting's Description (will show up as the line-item in the GUI)
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
    exit 0
fi
