#!/bin/bash

# Configure Git
function configure_git() {
    # Set the GitHub username and email
    git config --global user.name "$GITHUB_USERNAME"
    git config --global user.email "$GITHUB_EMAIL"

    # Set the default editor for Git
    git config --global core.editor "$EDITOR"

    # Enable Git status coloring
    git config --global color.ui true

    # Enable Git line breaks conversion
    git config --global core.autocrlf false

    # Set default branch name
    git config --global init.defaultBranch main

    # Enable Git merge conflict highlighting
    git config --global merge.tool vimdiff

    # Enable Git diff highlighting
    git config --global diff.tool vimdiff

    # Set the default commit message editor
    git config --global commit.editor "$EDITOR"

    # Set the default push mode to current
    git config --global push.default current

    # Set the default pull mode to rebase
    git config --global pull.rebase true

    # Enable Git credential to store
    git config --global credential.helper store

    # # Set the credential cache timeout to 1 hour
    # git config --global credential.helper.cache.timeout 3600

    # Generate SSH key if it doesn't exist
    if [ ! -f "~/.ssh/id_rsa" ]; then
        ssh-keygen -t rsa -b 4096 -C "$GITHUB_EMAIL"
    fi

    # Add your GitHub SSH key to the ssh-agent
    ssh-add ~/.ssh/id_rsa

    # Set additional Git options that are useful for developers
    git config --global core.excludesfile ~/.gitignore_global
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.lg log
}

# Get the GitHub username and email from the user
function get_github_credentials() {
    local github_username
    local github_email

    read -p "Enter your GitHub username: " github_username
    read -p "Enter your GitHub email: " github_email

    export GITHUB_USERNAME="$github_username"
    export GITHUB_EMAIL="$github_email"

}

# Get the editor from the user
function get_editor() {
    local editor

    read -p "Enter your preferred editor: " editor

    export EDITOR="$editor"
}

# Check if the user has already configured Git
function is_git_configured() {
    [[ -f ~/.gitconfig ]]
}

# Reconfigure Git
function reconfigure_git() {
    echo "Reconfiguring Git..."

    # Remove the existing Git configuration file
    rm ~/.gitconfig

    # Reconfigure Git
    configure_git
}

# Main function
function main() {
    # Get the GitHub credentials and preferred editor from the user
    get_github_credentials
    get_editor

    # Configure Git
    if is_git_configured; then
        echo "Git is already configured."

        # Ask the user if they want to reconfigure Git
        echo "Do you want to reconfigure Git? (y/n)"
        read answer

        if [[ "$answer" == "y" ]]; then
            reconfigure_git
        fi
    else
        # Configure Git for the first time
        configure_git
    fi

    echo "Git has been configured with email: $GITHUB_EMAIL and name: $GITHUB_USERNAME"
}

# Run the main function
main
