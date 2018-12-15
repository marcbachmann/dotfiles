export PATH=$PATH:/usr/local/bin:$HOME/bin
export DEFAULT_USER="marcbachmann"
setopt histignorespace

# Increase open file limit
ulimit -n 10000
# ulimit -u 2096

# iTerm configuration
test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

if [ $TERM_PROGRAM = "iTerm.app" ] || [ $TERM_PROGRAM = "Hyper" ]; then
  CASE_SENSITIVE="true"
  DISABLE_AUTO_UPDATE="true"
  COMPLETION_WAITING_DOTS="true"
  ZSH_DISABLE_COMPFIX=true
  source /usr/local/share/antigen/antigen.zsh
  antigen init ~/.antigenrc
fi

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#  export EDITOR='nano'
# else
#  export EDITOR='subl'
# fi

# if [ -f ~/.gnupg/.gpg-agent-info ] && [ -n "$(pgrep gpg-agent)" ]; then
#    source ~/.gnupg/.gpg-agent-info
#    export GPG_AGENT_INFO
#else
#    eval $(gpg-agent --daemon --write-env-file ~/.gnupg/.gpg-agent-info)
#fi

# This gets loaded twice in the terminal
# source ~/.zshenv

# bindkey "^X\x7f" backward-kill-line
