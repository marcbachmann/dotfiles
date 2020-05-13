# export DISABLE_MAGIC_FUNCTIONS=true
PATH=/usr/local/opt/curl/bin:/usr/local/opt/gnu-sed/libexec/gnubin:$PATH:/usr/local/bin:$HOME/bin
export DEFAULT_USER="marcbachmann"
setopt histignorespace

# Increase open file limit
ulimit -n 10000
# ulimit -u 2096

# iTerm configuration
export TERM=xterm-256color
test -e $HOME/.iterm2_shell_integration.zsh && source $HOME/.iterm2_shell_integration.zsh

# export NVM_DIR=$HOME/.nvm
# export NVM_SYMLINK_CURRENT=true
# export PATH=$PATH:$NVM_DIR/current/bin

if [ $TERM_PROGRAM = "iTerm.app" ] || [ $TERM_PROGRAM = "Hyper" ]; then
  CASE_SENSITIVE="true"
  DISABLE_AUTO_UPDATE="true"
  COMPLETION_WAITING_DOTS="true"
  ZSH_DISABLE_COMPFIX=true
  source /usr/local/share/antigen/antigen.zsh
  antigen init ~/.antigenrc
fi

# Node
alias inspect='node --inspect-brk'
alias npme='PATH=$(npm bin):$PATH'
alias npmo='npm install --offline'
alias npmclean="rm -Rf ./node_modules && npm install"
alias n='npm run'
alias h2url='execute-global h2url'
alias nvm=fnm

nvm_switch_if_needed () {
  local NVM_RC_FILE=$(nvm_find_nvmrc)
  if [ $NVM_RC_FILE ]; then
    local DESIRED_VERSION=`nvm_version $(cat $NVM_RC_FILE)`
    local DESIRED_BIN=`nvm_version_path $DESIRED_VERSION`/bin
    [ "$DESIRED_BIN" = "$NVM_BIN" ] || nvm use $DESIRED_VERSION
  fi
}

# cd () { builtin cd "$@"; nvm_switch_if_needed; }

meteo () { curl -4 "http://wttr.in/$(echo ${@:-zurich} | tr ' ' _)" }

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# fnm
eval "$(fnm env --multi)"

autoload -U add-zsh-hook
_fnm_autoload_hook () {
  if [[ -f .node-version && -r .node-version ]]; then
    fnm use --quiet
  elif [[ -f .nvmrc && -r .nvmrc ]]; then
    fnm use --quiet
  fi
}

add-zsh-hook chpwd _fnm_autoload_hook && _fnm_autoload_hook

source /Users/marcbachmann/Library/Preferences/org.dystroy.broot/launcher/bash/br

# The following lines were added by compinstall
zstyle :compinstall filename '/Users/marcbachmann/.zshrc'

autoload -Uz compinit
compinit

# End of lines added by compinstall

# Source all completions
for f in ~/.dotfiles/.zsh/completions/*; do source $f; done
