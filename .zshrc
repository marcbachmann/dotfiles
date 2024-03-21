# export DISABLE_MAGIC_FUNCTIONS=true
PATH=/usr/local/opt/curl/bin:/usr/local/opt/gnu-sed/libexec/gnubin:$PATH:/usr/local/bin:$HOME/bin
export DEFAULT_USER="marcbachmann"
setopt histignorespace
export EDITOR='nano'
source ~/.secrets

# Increase open file limit
ulimit -n 10000
# ulimit -u 2096

# iTerm configuration
# export TERM=xterm-256color
# test -e $HOME/.iterm2_shell_integration.zsh && source $HOME/.iterm2_shell_integration.zsh

# export NVM_DIR=$HOME/.nvm
# export NVM_SYMLINK_CURRENT=true
# export PATH=$PATH:$NVM_DIR/current/bin


# Node
alias inspect='node --inspect-brk'
alias npme='PATH=$(npm bin):$PATH'
alias npmo='npm install --offline'
alias npmclean="rm -Rf ./node_modules && npm install"
alias n='npm run'
alias h2url='execute-global h2url'
alias nvm=fnm

# alias livingdocs-server='./bin/index.js'
# alias nsenter='docker run -it --rm --privileged --pid=host alpine:edge nsenter -t 1 -m -u -n -i bash'
alias docker='lima nerdctl'
alias nerd='lima nerdctl'
alias nerdctl='lima nerdctl'

if [ $TERM_PROGRAM = "iTerm.app" ] || [ $TERM_PROGRAM = "Hyper" ] || [ $TERM_PROGRAM = "WarpTerminal" ]; then
  CASE_SENSITIVE="true"
  DISABLE_AUTO_UPDATE="true"
  COMPLETION_WAITING_DOTS="true"
  ZSH_DISABLE_COMPFIX=true
  source /opt/homebrew/share/antigen/antigen.zsh
  antigen init ~/.antigenrc
  eval "$(starship init zsh)"
fi


#autoload -U +X bashcompinit && bashcompinit
#complete -o nospace -C /usr/local/bin/terraform terraform

# fnm
eval "$(fnm env)"

# direnv
eval "$(direnv hook zsh)"

autoload -U add-zsh-hook
_fnm_autoload_hook () {
  if [[ -f .node-version && -r .node-version ]]; then
    fnm use --silent-if-unchanged --install-if-missing --log-level=error
  elif [[ -f .nvmrc && -r .nvmrc ]]; then
    fnm use --silent-if-unchanged --install-if-missing --log-level=error
  fi
}

add-zsh-hook chpwd _fnm_autoload_hook && _fnm_autoload_hook

FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

zstyle :compinstall filename '/Users/marcbachmann/.zshrc'
autoload -Uz compinit
compinit

# Source all completions
for f in ~/.dotfiles/.zsh/completions/*; do source $f; done
