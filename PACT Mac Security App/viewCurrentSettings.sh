#!/bin/sh

printf "\n"

printf "* Require password 5 seconds after sleep or screensaver is activated\n"
printf "defaults read com.apple.screensaver askForPassword: %s\n" $(defaults read com.apple.screensaver askForPassword)
printf "defaults read com.apple.screensaver askForPasswordDelay: %s\n" $(defaults read com.apple.screensaver askForPasswordDelay)
printf "\n"

printf "* Screensaver is set to activate after 10 minutes of inactivity\n"
printf "defaults -currentHost read com.apple.screensaver idleTime: %s\n" $(defaults -currentHost read com.apple.screensaver idleTime)
printf "\n"
