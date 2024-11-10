#!/bin/bash

# Disable Desktop Icons
defaults write com.apple.finder CreateDesktop false

# Hide Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 9999

# Hide Menu Bar
defaults write -g AppleMenuBarVisibleInFullscreen -bool false && defaults write -g _HIHideMenuBar -bool true

# Disable workspace edge
defaults write com.apple.dock workspaces-edge-delay -float 9999

# Apply Changes
killall Dock Finder
osascript -e 'tell app "System Events" to log out'

