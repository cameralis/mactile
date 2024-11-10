#!/bin/bash

# Enable Desktop Icons
defaults write com.apple.finder CreateDesktop true

# Show Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0

# Show Menu Bar
defaults write -g AppleMenuBarVisibleInFullscreen -bool false && defaults write -g _HIHideMenuBar -bool false

# Enable workspace edge
defaults write com.apple.dock workspaces-edge-delay -float 0.75

# Apply Changes
killall Dock Finder
osascript -e 'tell app "System Events" to log out'

