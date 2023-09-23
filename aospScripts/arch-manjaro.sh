#!/usr/bin/env bash
#-*- coding: utf-8 -*-
: '
@ File Name    :   arch-manjaro.sh
@ Created Time :   2021/06/01 6:26

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

# Script to setup an android build environment on Arch Linux and derivative distributions

echo "Setting up an Android build environment..."

# Uncomment the multilib repo, in case it was commented out
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

# Update system and install base packages
echo "Updating system and installing base packages..."
sudo pacman -Syyu base-devel git wget multilib-devel cmake svn clang lzip patchelf inetutils python2-distlib

# Install packages from AUR
aur_packages=(ncurses5-compat-libs lib32-ncurses5-compat-libs aosp-devel xml2 lineageos-devel)
for package in "${aur_packages[@]}"; do
    echo "Installing ${package} from AUR..."
    git clone "https://aur.archlinux.org/${package}.git"
    cd "${package}" && makepkg -si --noconfirm && cd ..
    rm -rf "${package}"
done

# Install Android platform tools and udev rules for adb
echo "Installing Android platform tools and udev rules for adb..."
sudo pacman -S android-tools android-udev

# Install additional packages
additional_packages=(gcc gnupg gperf sdl wxgtk2 squashfs-tools curl ncurses zlib schedtool perl-switch zip unzip libxslt bc rsync ccache lib32-zlib lib32-ncurses lib32-readline lib32-gcc-libs flex bison python2-virtualenv lzop pngcrush imagemagick)
echo "Installing additional packages..."
sudo pacman -S --needed "${additional_packages[@]}"

echo "Android build environment setup completed!"
