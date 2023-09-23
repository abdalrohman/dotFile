#!/usr/bin/env bash
#-*- coding: utf-8 -*-
: '
@ File Name    :   install.sh
@ Created Time :   2021/10/29 4:08:01

Copyright (C) <2021>  <Abdulrahman Alnaseer>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
'
# Set locale environment variables
export LC_MESSAGES=C LANG=C

# Function to set color variables
set_colors() {
    if tput setaf 0 &>/dev/null; then
        CLR_RST="$(tput sgr0)"
        CLR_BLD="$(tput bold)"
        CLR_BLD_RED="${CLR_BLD}$(tput setaf 1)"
        CLR_BLD_GRN="${CLR_BLD}$(tput setaf 2)"
        CLR_BLD_YLW="${CLR_BLD}$(tput setaf 3)"
        CLR_BLD_MAG="${CLR_BLD}$(tput setaf 5)"
    else
        unset CLR_RST CLR_BLD CLR_BLD_RED CLR_BLD_YLW CLR_BLD_GRN CLR_BLD_MAG
    fi
}

# Check if standard error is a terminal and set color variables
[[ -t 2 ]] && set_colors

# Function to print a message
print_msg() {
    local color=$1 mesg=$2
    shift 2
    printf "${!color}${mesg}${CLR_RST}\n" "$@" >&2
}

# Define message functions
msg() { print_msg CLR_BLD_MAG "$@"; }
msg2() { print_msg CLR_BLD_GRN "==> $1 ${CLR_BLD}$2" "${@:3}"; }
warning() { print_msg CLR_BLD_YLW "[!]WARNING: ${CLR_BLD}$1" "${@:2}"; }
success() { print_msg CLR_BLD_GRN "[✔]SUCCESS: ${CLR_BLD}$1" "${@:2}"; }
error() { print_msg CLR_BLD_RED "[✘]ERROR: ${CLR_BLD}$1" "${@:2}"; }

# Set default values for APP_PATH and PROJECT_URI if they are not set
: "${APP_PATH:="$HOME/.dotFile"}"
: "${PROJECT_URI:="https://github.com/abdalrohman/dotFile.git"}"

# Function to ensure a program must exist
program_must_exist() {
    command -v "$1" >/dev/null 2>&1 || {
        warning "You must have '$1' installed to continue."
        msg2 "INFO" "Trying to install missing tool."
        sudo DEBIAN_FRONTEND=noninteractive apt install "$1" -y
    }
}

# Function to create a symbolic link if the source file exists
lnif() {
    [ -e "$1" ] && ln -sf "$1" "$2"
}

# Function to backup existing files
do_backup() {
    local today=$(date +%Y%m%d_%s)
    for file in "$@"; do
        [ -e "$file" ] && [ ! -L "$file" ] && mv -v "$file" "$file.$today"
    done
    success "Your original configuration has been backed up."
}

# Function to sync a git repository
sync_repo() {
    local repo_path="$1"
    local repo_uri="$2"
    local repo_branch="$3"
    local repo_name="$4"

    msg2 "INFO" "Trying to update $repo_name"

    if [ ! -e "$repo_path" ]; then
        mkdir -p "$repo_path"
        git clone --recurse-submodules --depth 1 -b "$repo_branch" "$repo_uri" "$repo_path"
        success "Successfully cloned $repo_name."
    else
        cd "$repo_path" && git pull origin "$repo_branch"
        success "Successfully updated $repo_name"
    fi
}

# Function to create symbolic links
create_symlinks() {
    local source_path="$1"
    local target_path="$2"

    lnif "$source_path/zsh/.zshrc" "$target_path/.zshrc"
    lnif "$source_path/vim/.vimrc" "$target_path/.vimrc"

    success "Setting up symlinks."
}

# Function to install android sdk tool
install_android_sdk_tool() {
    if [ ! -d "$HOME/platform-tools" ]; then
        msg2 "INFO" "Installing android sdk"
        curl -L https://dl.google.com/android/repository/platform-tools-latest-linux.zip -o /tmp/platform-tools.zip
        unzip /tmp/platform-tools.zip -d ~/
        rm /tmp/platform-tools.zip
        success "Installing android sdk"
    fi
}

# Function to install fzf
install_fzf() {
    local version=$(grep -m 1 "version=" "$HOME"/.dotFile/fzf/fzf/install | tr -d '\r' | sed 's/.*=//')
    curl -L https://github.com/junegunn/fzf/releases/download/"$version"/fzf-"$version"-linux_amd64.tar.gz -o /tmp/fzf-"$version".tar.gz
    tar -xzf /tmp/fzf-"$version".tar.gz -C "$HOME/.dotFile/bin"
    rm /tmp/fzf-"$version".tar.gz
}

# Function to install dotfile
install_dotfile() {
    sync_repo "$HOME/.dotFile" "$PROJECT_URI" "dev" "dotFile"
}

# Function to install powerlevel10k
install_powerlevel10k() {
    sync_repo "$HOME/.dotFile/zsh/zsh-theme-powerlevel10k" "https://github.com/romkatv/powerlevel10k.git" "master" "powerlevel10k"
}

# Main function
main() {
    msg "Start installation dotFile"
    echo ""

    program_must_exist "zsh"
    program_must_exist "git"
    program_must_exist "bc"
    program_must_exist "silversearcher-ag"
    program_must_exist "unzip"

    install_dotfile
    install_powerlevel10k

    chsh "$USER" -s /bin/zsh

    install_fzf
    install_android_sdk_tool

    do_backup "$HOME/.zshrc"

    create_symlinks "$APP_PATH" "$HOME"

    msg "Total time elapsed: $(echo "($(date +%s.%N) - $SECONDS) / 60" | bc) minutes ($(echo "$(date +%s.%N) - $SECONDS" | bc) seconds)"
    echo ""
}

# Run the main function
main
