#!/bin/bash

cd ~/Library/Preferences
cp -a com.apple.dock.plist com.apple.dock.plist.bak
defaults delete com.apple.dock persistent-apps; killall Dock

# To restore run:
#  cd ~/Library/Preferences; rm com.apple.dock.plist; cp -a com.apple.dock.plist.bak com.apple.dock.plist; killall Dock
