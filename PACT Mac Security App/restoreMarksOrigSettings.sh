#!/bin/sh

# Require password 5 seconds after sleep or screensaver is activated
defaults write com.apple.screensaver askForPasswordDelay -int 5

# Screensaver is set to activate after 10 minutes of inactivity
defaults -currentHost write com.apple.screensaver idleTime 1800
