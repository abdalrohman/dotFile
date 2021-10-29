#!/usr/bin/env bash
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# shellcheck disable=SC2059

export LC_MESSAGES=C
export LANG=C

# Colors
disable_colors() {
    unset CLR_RST CLR_BLD CLR_MAG CLR_GRN CLR_BLD_RED CLR_BLD_YLW CLR_BLD_GRN CLR_BLD_MAG
}

enable_colors() {
    # prefer terminal safe colored and bold text when tput is supported
    if tput setaf 0 &>/dev/null; then
        CLR_RST="$(tput sgr0)"
        CLR_BLD="$(tput bold)"
        CLR_BLD_RED="${CLR_BLD}$(tput setaf 1)"
        CLR_BLD_GRN="${CLR_BLD}$(tput setaf 2)"
        CLR_BLD_YLW="${CLR_BLD}$(tput setaf 3)"
        CLR_BLD_MAG="${CLR_BLD}$(tput setaf 5)"
    else
        CLR_RST="\e[0m"
        CLR_BLD="\e[1m"
        CLR_BLD_RED="${CLR_BLD}\e[31m"
        CLR_BLD_GRN="${CLR_BLD}\e[32m"
        CLR_BLD_YLW="${CLR_BLD}\e[33m"
        CLR_BLD_MAG="${CLR_BLD}\e[35m"
    fi
    readonly CLR_RST CLR_BLD CLR_BLD_RED CLR_BLD_YLW CLR_BLD_GRN CLR_BLD_MAG
}

if [[ -t 2 ]]; then
    enable_colors
else
    disable_colors
fi

# Set functions
msg() {
    local mesg=$1
    shift
    printf "${CLR_BLD_MAG}${mesg}${CLR_RST}\n" "$@" >&2
}

msg2() {
    local val=$1
    local mesg=$2
    shift
    printf "${CLR_BLD_GRN}==> ${val}${CLR_RST}${CLR_BLD} ${mesg}\n" "$@" >&2
}

warning() {
    local mesg=$1
    shift
    printf "${CLR_BLD_YLW}[!]WARNING:${CLR_RST}${CLR_BLD} ${mesg}${CLR_RST}\n" "$@" >&2
}

success() {
    local mesg=$1
    shift
    printf "${CLR_BLD_GRN}[✔]SUCCESS:${CLR_RST}${CLR_BLD} ${mesg}${CLR_RST}\n" "$@" >&2
}

error() {
    local mesg=$1
    shift
    printf "${CLR_BLD_RED}[✘]ERROR:${CLR_RST}${CLR_BLD} ${mesg}${CLR_RST}\n" "$@" >&2
}

[ -z "$APP_PATH" ] && APP_PATH="$HOME/.dotFile"
[ -z "$PLUG_URI" ] && PLUG_URI="https://github.com/junegunn/vim-plug.git"
[ -z "$PROJECT_URI" ] && PROJECT_URI="https://github.com/abdalrohman/dotFile.git"

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
    program_exists "$1"

    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        warning "You must have '$1' installed to continue."
        msg2 "Trying to:" "install missing tool."
        sudo DEBIAN_FRONTEND=noninteractive \
            apt install "$1" -y
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
        msg2 "Attempting to:" "back up your original configuration."
        today=$(date +%Y%m%d_%s)
        for i in "$1" "$2" "$3"; do
            [ -e "$i" ] && [ ! -L "$i" ] && mv -v "$i" "$i.$today"
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

    msg2 "Trying to:" "update $repo_name"

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
    msg2 "Creat:" "symlinks."

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
# Check the starting time (of the real build process)
TIME_START=$(date +%s.%N)

msg "Start installation dotFile"
echo ""
variable_set "$HOME"
if [ -e "$HOME"/.dotFile/ ]; then
    rm -rf "$HOME"/.dotFile
    sync_repo "$HOME/.dotFile" \
        "$PROJECT_URI" \
        "main" \
        "dotFile"
else
    sync_repo "$HOME/.dotFile" \
        "$PROJECT_URI" \
        "main" \
        "dotFile"
fi

program_must_exist "zsh"
program_must_exist "vim"
program_must_exist "git"

if [ -e "$HOME/.vim/autoload/" ]; then
    if [ -e "$HOME/.vim/autoload/.git" ]; then
        sync_repo "$HOME/.vim/autoload" \
            "$PLUG_URI" \
            "master" \
            "plug"
    else
        rm -rf "$HOME"/.vim/autoload
        sync_repo "$HOME/.vim/autoload" \
            "$PLUG_URI" \
            "master" \
            "plug"
    fi
else
    sync_repo "$HOME/.vim/autoload" \
        "$PLUG_URI" \
        "master" \
        "plug"
fi

do_backup "$HOME/.zshrc"

create_symlinks "$APP_PATH" "$HOME"

setup_plug "$APP_PATH/vim/.vimrc.plug"

# Check the finishing time
TIME_END=$(date +%s.%N)

# Log those times at the end
msg "Total time elapsed: $(echo "(${TIME_END} - ${TIME_START}) / 60" | bc) minutes ($(echo "${TIME_END} - ${TIME_START}" | bc) seconds)"
echo -e ""

exit 0
