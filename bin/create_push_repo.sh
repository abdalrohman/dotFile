#!/bin/bash

# Check if gh is installed
if ! command -v gh &>/dev/null; then
    echo "gh could not be found, installing..."

    # Check if the system is Ubuntu or Arch Linux
    if grep -q 'ID=ubuntu' /etc/os-release; then
        # Install on Ubuntu
        sudo apt update
        sudo apt install gh
    elif grep -q 'ID=arch' /etc/os-release; then
        # Install on Arch Linux
        sudo pacman -S github-cli
    else
        echo "This script only supports Ubuntu and Arch Linux."
        exit 1
    fi
else
    echo "gh is already installed."
fi

# Check if the user is logged in with gh
if ! gh auth status &>/dev/null; then
    echo "You are not logged in with gh. Please log in."
    gh auth login
else
    echo "You are already logged in with gh."
fi

# Ask the user for their GitHub username
read -p "Enter your GitHub username: " github_username

# Use the GitHub API to check if the username exists
if curl --silent "https://api.github.com/users/$github_username" | grep -q "Not Found"; then
    echo "The username you entered was not found on GitHub."
    exit 1
else
    echo "The username you entered was found on GitHub."

    # Continue with the rest of your script here...
fi

# Get the repository name from the user
read -p "Enter the name of your new GitHub repository: " repo_name

# Ask the user to enter the path to their local repository
read -e -p "Enter the path to your local repository: " repo_path

# Check if the path is a valid directory
if [ -d "$repo_path" ]; then
    echo "You entered: $repo_path"
else
    echo "The path you entered is not a valid directory."
    exit 1
fi

# Create a new repository on GitHub
gh repo create $repo_name --public -y

# Navigate to your local repository
cd $repo_path

# Initialize the local directory as a Git repository
git init

# Add the files in your new local repository
git add .

# Commit the files that you've staged in your local repository
git commit -m "Initial commit"

# Set the new remote
git remote add origin https://github.com/$github_username/$repo_name.git

# Verifies the new remote URL
git remote -v

# Push the changes in your local repository to GitHub
git push -u origin main
