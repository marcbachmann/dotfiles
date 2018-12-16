#!/usr/bin/env bash
set -eu

# Set default configs
./defaults.sh

brew -v > /dev/null && echo 'Homebrew is already present' || echo "Install homebrew" && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Change default shell to zsh"
chsh -s /bin/zsh

echo "Install apps listed in Brewfile"
brew bundle

bonclay sync bonclay.conf.yaml
