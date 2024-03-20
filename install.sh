#!/usr/bin/env bash
set -eu

echo "Set default OSX configs"
./defaults.sh

# brew -v > /dev/null && echo 'Homebrew is already present' || echo "Install homebrew" && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

echo "Install apps listed in Brewfile"
brew bundle install

echo "Copy all dotfiles into $HOME"
./sync.sh

# Fix compaudit permissions
compaudit | xargs chmod g-w

# launchctl load ~/Library/LaunchAgents/local.marcbachmann.coredns.plist
