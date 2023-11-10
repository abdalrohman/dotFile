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

if [[ -e "$HOME/miniconda3" ]]; then
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
            . "$HOME/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="$HOME/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
fi
