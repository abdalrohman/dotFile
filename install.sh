#!/usr/bin/env bash

export LC_MESSAGES=C
export LANG=C

app_name='dotFile'
[ -z "$APP_PATH" ] && APP_PATH="$HOME/.dotFile"
[ -z "$PLUG_URI" ] && PLUG_URI="https://github.com/junegunn/vim-plug.git"
[ -z "$PROJECT_URI" ] && PROJECT_URI="https://github.com/abdalrohman/dotFile.git"

disable_colors(){
    unset ALL_OFF BOLD BLUE GREEN RED YELLOW
}

enable_colors(){
    # prefer terminal safe colored and bold text when tput is supported
    if tput setaf 0 &>/dev/null; then
        ALL_OFF="$(tput sgr0)"
        BOLD="$(tput bold)"
        RED="${BOLD}$(tput setaf 1)"
        GREEN="${BOLD}$(tput setaf 2)"
        YELLOW="${BOLD}$(tput setaf 3)"
        BLUE="${BOLD}$(tput setaf 4)"
    else
        ALL_OFF="\e[0m"
        BOLD="\e[1m"
        RED="${BOLD}\e[31m"
        GREEN="${BOLD}\e[32m"
        YELLOW="${BOLD}\e[33m"
        BLUE="${BOLD}\e[34m"
    fi
    readonly ALL_OFF BOLD BLUE GREEN RED YELLOW
}

if [[ -t 2 ]]; then
    enable_colors
else
    disable_colors
fi

msg() {
    local mesg=$1; shift
    printf "${GREEN}==>${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

msg2() {
    local mesg=$1; shift
    printf "${BLUE}  ->${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

success() {
    local mesg=$1; shift
    printf "${GREEN}  ->[✔]SUCCESS:${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

error() {
    local mesg=$1; shift
    printf "${RED}==> [✘]ERROR:${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

warning() {
    local mesg=$1; shift
    printf "${YELLOW}  ->WARNING:${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}




program_exists() {
    local ret='0'
    command -v "$1" >/dev/null 2>&1 || { local ret='1'; }

    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi

    return 0
}

program_must_exist() {
    program_exists $1

    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        warning "You must have '$1' installed to continue."
        msg2 "Trying to install missing tool."
        sudo DEBIAN_FRONTEND=noninteractive \
            apt install $1 -y
    fi
}

variable_set() {
    if [ -z "$1" ]; then
        error "You must have your HOME environmental variable set to continue."
    fi
}

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
    ret="$?"
}

do_backup() {
    if [ -e "$1" ] || [ -e "$2" ] || [ -e "$3" ]; then
        msg2 "Attempting to back up your original configuration."
        today=$(date +%Y%m%d_%s)
        for i in "$1" "$2" "$3"; do
            [ -e "$i" ] && [ ! -L "$i" ] && mv -v "$i" "$i.$today";
        done
        ret="$?"
        success "Your original configuration has been backed up."
   fi
}

sync_repo() {
    local repo_path="$1"
    local repo_uri="$2"
    local repo_branch="$3"
    local repo_name="$4"

    msg2 "Trying to update $repo_name"

    if [ ! -e "$repo_path" ]; then
        mkdir -p "$repo_path"
        git clone -b "$repo_branch" "$repo_uri" "$repo_path"
        ret="$?"
        success "Successfully cloned $repo_name."
    else
        cd "$repo_path" && git pull origin "$repo_branch"
        ret="$?"
        success "Successfully updated $repo_name"
    fi
}

create_symlinks() {
    local source_path="$1"
    local target_path="$2"
    msg2 "Creat symlinks."

    lnif "$source_path/zsh/.zshrc" "$target_path/.zshrc"
    lnif "$source_path/vim/.vimrc" "$target_path/.vimrc"

    ret="$?"
    success "Setting up symlinks."
}

setup_plug() {
    local system_shell="$SHELL"
    export SHELL='/bin/sh'

    vim \
        -u "$1" \
        "+set nomore" \
        "+PlugInstall!" \
        "+PlugClean" \
        "+qall"

    export SHELL="$system_shell"

    success "Now updating/installing plugins using Plug"
}

############################ MAIN()
msg "Start installation dotFile"
echo ""
variable_set "$HOME"
if [ -e $HOME/.dotFile/ ]; then
    if [ -e $HOME/.dotFile/.git ]; then
        msg2 "Trying to update dotFile"
        sync_repo   "$HOME/.dotFile" \
                    "$PROJECT_URI" \
                    "main" \
                    "dotFile"
        success "Update dotFile success"
    else
        rm -rf $HOME/.dotFile
    fi
else
    msg2 "Trying to sync dotFile from github"
    sync_repo   "$HOME/.dotFile" \
                "$PROJECT_URI" \
                "main" \
                "dotFile"
    success "Sync dotFile success"
fi

program_must_exist "zsh"
program_must_exist "vim"
program_must_exist "git"

if [ -e "$HOME/.vim/autoload" ]; then
    rm -rf $HOME/.vim/autoload
    sync_repo   "$HOME/.vim/autoload" \
                "$PLUG_URI" \
                "master" \
                "plug"
else 
    sync_repo   "$HOME/.vim/autoload" \
                "$PLUG_URI" \
                "master" \
                "plug"

fi

do_backup "$HOME/.zshrc"

create_symlinks "$APP_PATH" "$HOME"

setup_plug "$APP_PATH/vim/.vimrc.plug"

msg "\nSuccesfully installing $app_name."
