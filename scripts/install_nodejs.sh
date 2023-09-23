#!/usr/bin/env bash
#-*- coding: utf-8 -*-
: '
@ File Name    :   install_nodejs.sh
@ Created Time :   2023/09/23 16:21:10

Copyright (C) <2023>  <Abdulrahman Alnaseer>

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

# version="16.14.2"
# Fetch the latest version number from the Node.js website
version=$(curl -s https://nodejs.org/dist/latest/ | grep 'node-v' | awk -F\" '{print $2}' | awk -F\/ '{print $1}' | awk -Fv '{print $2}' | grep 'linux-x64' | awk -F- '{print $1}' | head -n 1)

nodejs_url="https://nodejs.org/dist/latest/node-v$version-linux-x64.tar.xz"
nodejs_dir="/usr/local/lib/nodejs/node-v$version-linux-x64"

# Download Node.js
wget -O /tmp/nodejs.tar.xz $nodejs_url

# Check if download was successful
if [ "$?" -ne 0 ]; then
    echo "Failed to download Node.js"
    exit 1
fi

# Extract Node.js
sudo mkdir -p /usr/local/lib/nodejs
sudo tar -xJf /tmp/nodejs.tar.xz -C /usr/local/lib/nodejs

# Check if extraction was successful
if [ "$?" -ne 0 ]; then
    echo "Failed to extract Node.js"
    exit 1
fi

# Remove the downloaded tar file
rm /tmp/nodejs.tar.xz

# Add Node.js to PATH
echo "export PATH=$nodejs_dir/bin:"'$PATH' >>"$HOME"/.profile
source "$HOME"/.profile

# Check if Node.js was installed successfully
if ! command -v node &>/dev/null; then
    echo "Node.js could not be installed"
    exit 1
fi

# Install npm
sudo DEBIAN_FRONTEND=noninteractive apt install npm -y

# Check if npm was installed successfully
if ! command -v npm &>/dev/null; then
    echo "npm could not be installed"
    exit 1
fi

# Install yarn
sudo npm i -g yarn

# Check if yarn was installed successfully
if ! command -v yarn &>/dev/null; then
    echo "Yarn could not be installed"
    exit 1
fi

echo "Installation completed successfully"
