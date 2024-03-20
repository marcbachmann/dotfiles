#!/usr/bin/env bash

YAML='home:
  ~/.zshrc: .zshrc
  ~/.zshenv: .zshenv
  ~/.gitconfig: .gitconfig
  ~/.gitignore_global: .gitignore_global
  ~/.gnupg/gpg-agent.conf: .gnupg/gpg-agent.conf
  ~/.antigenrc: .antigenrc
  ~/.tmux.conf: .tmux.conf
  ~/.nanorc: .nanorc
  ~/.nano: .nano
  ~/.grc: .grc
  ~/.ssh/config: .ssh/config
  ~/.hammerspoon: .hammerspoon
  ~/.iterm2: iterm2
  ~/Library/Application Support/Sublime Text 3/Packages/User/: .sublime
  # ~/.homebridge: homebridge
  # ~/.homeassistant: homeassistant
  #

system:
  /Library/LaunchDaemons/local.marcbachmann.pfctl.plist: /Users/marcbachmann/.dotfiles/coredns/pfctl.plist
  /Library/LaunchDaemons/local.marcbachmann.coredns.plist: /Users/marcbachmann/.dotfiles/coredns/service.plist
  /Library/LaunchDaemons/local.marcbachmann.node_exporter.plist: /Users/marcbachmann/.dotfiles/prometheus/node_exporter.plist
  /Library/LaunchDaemons/local.marcbachmann.prometheus.plist: /Users/marcbachmann/.dotfiles/prometheus/prometheus.plist

'

if [ "$(id -u)" != "0" ]; then 1>&2 echo Please execute the script using sudo. && exit 1; fi

SCRIPT=$(
cat <<EOF
rm -Rf \(.key) && su marcbachmann -c 'ln -s \(.key) \(.value)'
EOF
)

yq r - 'home' -j <<<"$YAML" | jq -r "to_entries | .[] | \"$SCRIPT\""
yq r - 'system' -j <<<"$YAML" | jq -r "to_entries | .[] | \"rm -Rf \(.key) && ln -s \(.key) \(.value)\""

launchctl load -w /Library/LaunchDaemons/local.marcbachmann.coredns.plist
launchctl load -w /Library/LaunchDaemons/local.marcbachmann.pfctl.plist
