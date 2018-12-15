#!/usr/bin/env bash
brew -v > /dev/null && echo 'Homebrew is already present' || echo "Install homebrew" && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Change default shell to zsh"
chsh -s /bin/zsh

echo "Install apps listed in Brewfile"
brew bundle
# Set up git
# generate private key
# ssh-keygen -t rsa -b 4096 -C "your_email@example.com" eval "$(ssh-agent -s)" ssh-add ~/.ssh/id_rsa pbcopy < ~/.ssh/id_rsa.pub
# git credential-osxkeychain

./link.sh
