#!/usr/bin/env bash
#-*- coding: utf-8 -*-
: '
@ File Name    :   android_build_env.sh
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

# Exit if any command fails
set -e

# Define packages for different distributions
declare -A PACKAGES=(
    ["Ubuntu 16.04"]="libesd0-dev"
    ["Ubuntu 20.04"]="libncurses5 curl python-is-python3"
    ["Debian GNU/Linux 10"]="libncurses5"
)

# Define common packages to be installed
COMMON_PACKAGES=(
    adb autoconf automake axel bc bison build-essential clang cmake expat flex g++
    g++-multilib gawk gcc gcc-multilib gnupg gperf htop imagemagick lib32ncurses5-dev
    lib32z1-dev libtinfo5 libc6-dev libcap-dev libexpat1-dev libgmp-dev '^liblz4-.*'
    '^liblzma.*' libmpc-dev libmpfr-dev libncurses5-dev libsdl1.2-dev libssl-dev libtool
    libxml2 libxml2-utils '^lzma.*' lzop maven ncftp ncurses-dev patch patchelf pkg-config
    pngcrush pngquant python2.7 python-all-dev re2c schedtool squashfs-tools subversion
    texinfo unzip w3m xsltproc zip zlib1g-dev lzip libxml-simple-perl apt-utils jq nghttp2
    libnghttp2-dev libz-dev libcurl4-gnutls-dev libc6-dev-i386 x11proto-core-dev libx11-dev
    lib32z-dev libgl1-mesa-dev python3-mako ninja-build syslinux syslinux-utils gettext
    genisoimage xorriso make git ccache openjdk-8-jdk
)

# Update system and install lsb-core
sudo apt update && sudo apt upgrade -y && sudo apt install lsb-core -y

# Check the distribution and set the packages to be installed
LSB_RELEASE=$(lsb_release -d | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//')
for dist in "${!PACKAGES[@]}"; do
    [[ ${LSB_RELEASE} =~ ${dist} ]] && DIST_PACKAGES="${PACKAGES[$dist]}"
done

# Install packages
sudo DEBIAN_FRONTEND=noninteractive apt install -y ${DIST_PACKAGES} "${COMMON_PACKAGES[@]}"

# Set up udev rules for adb
echo -e "\nSetting up udev rules for adb...\n"
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo systemctl restart udev

# Install Java 8 and set it as the default version
echo -e "\nInstalling Java 8 and setting it as the default version...\n"
sudo update-alternatives --config java
sudo update-alternatives --config javac

# Install repo
echo -e "\n Installing repo \n"
sudo curl --create-dirs -L -o /usr/local/bin/repo -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod +x /usr/local/bin/repo

# Install git-lfs
echo -e "\n Installing git-lfs \n"
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install git-lfs

# Set up environment variables
append_env_settings() {
    cat <<'EOF' >>"$1"
# Super-fast repo sync
repofastsync() { schedtool -B -n 1 -e ionice -n 1 `which repo` sync -c -f --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j8 "$@"; }

# Enable CCACHE
export USE_CCACHE=1

export LC_ALL=C

# Add java to path
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$PATH:$HOME/bin:$JAVA_HOME/bin

# fix Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
export _JAVA_OPTIONS="-Xmx4096m"

memsize=$(($(grep MemTotal /proc/meminfo | awk '{print $2}')/(1024 * 1024)))
if [ $memsize -lt 16 ]; then
    export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx$(($memsize/2))g"
    export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx$(($memsize/2))g"
fi

EOF
}

# Set up environment in .bashrc
append_env_settings "$HOME/.bashrc"

# Set up environment in .zshrc
append_env_settings "$HOME/.zshrc"

# Add android sdk to path
cat <<'EOF' >>~/.profile
# Add Android SDK platform tools to path
if [ -d "$HOME/platform-tools" ] ; then
    PATH="$HOME/platform-tools:$PATH"
fi
EOF

echo "You are now ready to build Android!"
