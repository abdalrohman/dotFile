# Use powerline
USE_POWERLINE="true"
# Source zsh-configuration
if [[ -e $HOME/.dotFile/zsh/zsh-config ]]; then
  source $HOME/.dotFile/zsh/zsh-config
fi
# Use zsh prompt
if [[ -e $HOME/.dotFile/zsh/zsh-prompt ]]; then
  source $HOME/.dotFile/zsh/zsh-prompt
fi

export PATH=$HOME/.dotFile/scripts:$PATH
export PATH=$HOME/.dotFile/bin:$PATH

JAVA_HOME=/usr/lib/jvm/java-8-openjdk
PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
export JAVA_HOME
#export _JAVA_OPTIONS=-Xmx4096m

# Add Android SDK platform tools to path
if [ -d "$HOME/platform-tools" ] ; then
    PATH="$HOME/platform-tools:$PATH"
fi

[ -f $HOME/.dotFile/fzf/fzf.zsh ] && source $HOME/.dotFile/fzf/fzf.zsh

# rust env
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
