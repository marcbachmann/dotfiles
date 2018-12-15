#!/usr/bin/env bash
echo "Disable MOTD on new terminal session"
touch ~/.hushlogin

echo "Configure Finder and the Desktop"
defaults write com.apple.dock tilesize -int 38
defaults write com.apple.dock autohide -int 1
defaults write com.apple.finder ShowHardDrivesOnDesktop -int 1
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -int 1
defaults write com.apple.finder ShowRemovableMediaOnDesktop -int 1
defaults write com.apple.finder NewWindowTarget PfHm

echo "Enable subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

echo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# defaults write -g AppleKeyboardUIMode -int 3

echo "Show all extensions in Finder"
defaults write -g AppleShowAllExtensions -int 1

echo "Allow quitting Finder via ⌘ + Q; doing so will also hide desktop icons"
defaults write com.apple.finder QuitMenuItem -bool true

echo "Make Dock icons of hidden applications translucent"
defaults write com.apple.dock showhidden -bool true

echo "Show indicator lights for open applications in the Dock"
defaults write com.apple.dock show-process-indicators -bool true

echo "Configure keyboard key repeat"
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2

echo "Add a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

echo "Kill affected applications"
for app in Safari Finder Dock Mail SystemUIServer; do killall "$app" >/dev/null 2>&1; done
