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

# Use ag for feeding into fzf for searching files.
export FZF_DEFAULT_COMMAND='ag -U --hidden --ignore .git -g ""'
# Color: https://github.com/junegunn/fzf/wiki/Color-schemes - Solarized Dark
# Bind F1 key to toggle preview window on/off
export FZF_DEFAULT_OPTS='--bind "F1:toggle-preview" --preview "rougify {} 2> /dev/null || cat {} 2> /dev/null || tree -C {} 2> /dev/null | head -100" --color dark,hl:33,hl+:37,fg+:235,bg+:136,fg+:254 --color info:254,prompt:37,spinner:108,pointer:235,marker:235'

# Show long commands if needed
# From https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings
# Bind F1 key to toggle preview window on/off
export FZF_CTRL_R_OPTS='--bind "F1:toggle-preview" --preview "echo {}" --preview-window down:3:hidden:wrap'

export PATH=$HOME/.dotFile//bin:$PATH
export PATH=$HOME/.dotFile/bin:$PATH

JAVA_HOME=/usr/lib/jvm/java-8-openjdk
PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
export JAVA_HOME
#export _JAVA_OPTIONS=-Xmx4096m

# Add Android SDK platform tools to path
if [ -d "$HOME/platform-tools" ] ; then
    PATH="$HOME/platform-tools:$PATH"
fi

# Base16 Shell
BASE16_SHELL="$HOME/.dotFile/base16-shell/base16-default.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
