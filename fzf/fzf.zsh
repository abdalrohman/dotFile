# Setup fzf
# ---------
if [[ ! "$PATH" == *"$HOME"/.dotFile/fzf/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.dotFile/fzf/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.dotFile/fzf/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.dotFile/fzf/fzf/shell/key-bindings.zsh"


# Use ag for feeding into fzf for searching files.
export FZF_DEFAULT_COMMAND='ag -U --hidden --ignore .git -g ""'

# Color: https://github.com/junegunn/fzf/wiki/Color-schemes - Seoul256 Dusk
# Bind F1 key to toggle preview window on/off
export FZF_DEFAULT_OPTS='--bind "F1:toggle-preview" --preview "rougify {} 2> /dev/null || cat {} 2> /dev/null || tree -C {} 2> /dev/null | head -100" --color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108 --color info:108,prompt:109,spinner:108,pointer:168,marker:168'

# Show long commands if needed
# From https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings
# Bind F1 key to toggle preview window on/off
export FZF_CTRL_R_OPTS='--bind "F1:toggle-preview" --preview "echo {}" --preview-window down:3:hidden:wrap'
