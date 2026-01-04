#!/bin/bash

# Set three-finger drag
# TODO: Does not work...
defaults -currentHost write com.apple.AppleMultitouchTrackpad Dragging -bool true
defaults -currentHost write com.apple.AppleMultitouchTrackpad DraggingStyle 3

# Set default display to "More space"
# TODO: Does not work...
defaults -currentHost write com.apple.windowserver DisplayResolutionForSpaces -dict-add "$(ioreg -rd1 -c AppleClocks | grep -w "IODisplayConnect" | sed -e 's/.*"IODisplayConnect" = "//' -e 's/".*//')" "{\"scale-factor\" = 1;}"

# Disable Key Hold
defaults -currentHost write -g ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
defaults delete -g ApplePressAndHoldEnabled

# Set key repeat. For bluetooth keyboards (glove80 in particular) do not set to 10/2 as it may cause lags.
defaults write -g InitialKeyRepeat -int 50
defaults write -g KeyRepeat -int 1


# Privacy: don't send Safari search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 64
defaults write com.apple.dock minimize-to-application -bool true
# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock "autohide-delay" -float "0"
defaults write com.apple.dock "autohide-time-modifier" -float "0.2"
# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true
# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false


###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

###############################################################################
# Finder                                                                       #
###############################################################################

# Show path bar at bottom of Finder windows
defaults write com.apple.finder ShowPathbar -bool true
# Show status bar (item count, disk space)
defaults write com.apple.finder ShowStatusBar -bool true
# Search current folder by default (not "This Mac")
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Always show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

###############################################################################
# Auto-correction                                                              #
###############################################################################

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Disable auto-capitalize
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

###############################################################################
# Mission Control                                                              #
###############################################################################

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false
# Don't group windows by application in Mission Control
defaults write com.apple.dock expose-group-apps -bool false
# Hot corner top-right: Notification Center
defaults write com.apple.dock wvous-tr-corner -int 12
defaults write com.apple.dock wvous-tr-modifier -int 0

###############################################################################
# Mouse                                                                        #
###############################################################################

# Disable mouse acceleration (1:1 linear tracking)
defaults write NSGlobalDomain "com.apple.mouse.linear" -bool true

###############################################################################
# Stage Manager                                                                #
###############################################################################

# Disable Stage Manager (using AeroSpace for workspace management instead)
defaults write com.apple.WindowManager GloballyEnabled -bool false

# Restart affected applications
pkill "Dock"
pkill "Finder"
