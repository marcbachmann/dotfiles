#!/usr/bin/env zsh

if [ "$(id -u)" != "0" ]; then 1>&2 echo Please execute the script using sudo. && exit 1; fi

rm -Rf ~/.zshrc && su marcbachmann -c 'ln -s $PWD/.zshrc ~/.zshrc'
rm -Rf ~/.zshenv && su marcbachmann -c 'ln -s $PWD/.zshenv ~/.zshenv'
rm -Rf ~/.gitconfig && su marcbachmann -c 'ln -s $PWD/.gitconfig ~/.gitconfig'
rm -Rf ~/.gitignore_global && su marcbachmann -c 'ln -s $PWD/.gitignore_global ~/.gitignore_global'
rm -Rf ~/.gnupg/gpg-agent.conf && su marcbachmann -c 'ln -s $PWD/.gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf'
rm -Rf ~/.antigenrc && su marcbachmann -c 'ln -s $PWD/.antigenrc ~/.antigenrc'
rm -Rf ~/.tmux.conf && su marcbachmann -c 'ln -s $PWD/.tmux.conf ~/.tmux.conf'
rm -Rf ~/.nanorc && su marcbachmann -c 'ln -s $PWD/.nanorc ~/.nanorc'
rm -Rf ~/.nano && su marcbachmann -c 'ln -s $PWD/.nano ~/.nano'
rm -Rf ~/.grc && su marcbachmann -c 'ln -s $PWD/.grc ~/.grc'
rm -Rf ~/.gnupg/gpg-agent.conf && su marcbachmann -c 'ln -s $PWD/.gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf'
rm -Rf ~/.ssh/config && su marcbachmann -c 'ln -s $PWD/.ssh/config ~/.ssh/config'
rm -Rf ~/.hammerspoon && su marcbachmann -c 'ln -s $PWD/.hammerspoon ~/.hammerspoon'
rm -Rf ~/.iterm2 && su marcbachmann -c 'ln -s $PWD/iterm2 ~/.iterm2'
rm -Rf ~/.config/starship.toml && su marcbachmann -c 'ln -s $PWD/.config/starship.toml ~/.config/starship.toml'

rm -Rf /Library/LaunchDaemons/local.marcbachmann.pfctl.plist && ln -s /Library/LaunchDaemons/local.marcbachmann.pfctl.plist /Users/marcbachmann/.dotfiles/coredns/pfctl.plist
rm -Rf /Library/LaunchDaemons/local.marcbachmann.coredns.plist && ln -s /Library/LaunchDaemons/local.marcbachmann.coredns.plist /Users/marcbachmann/.dotfiles/coredns/service.plist
rm -Rf /Library/LaunchDaemons/local.marcbachmann.node_exporter.plist && ln -s /Library/LaunchDaemons/local.marcbachmann.node_exporter.plist /Users/marcbachmann/.dotfiles/prometheus/node_exporter.plist
rm -Rf /Library/LaunchDaemons/local.marcbachmann.prometheus.plist && ln -s /Library/LaunchDaemons/local.marcbachmann.prometheus.plist /Users/marcbachmann/.dotfiles/prometheus/prometheus.plist

launchctl load -w /Library/LaunchDaemons/local.marcbachmann.coredns.plist
launchctl load -w /Library/LaunchDaemons/local.marcbachmann.pfctl.plist
