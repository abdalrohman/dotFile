#!/usr/bin/env bash

# Copyright (C) 2018 Harsh 'MSF Jarvis' Shandilya
# Copyright (C) 2018 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only

# Script to setup an AOSP Build environment on Ubuntu and Linux Mint

LATEST_MAKE_VERSION="4.3"
UBUNTU_16_PACKAGES="libesd0-dev"
UBUNTU_20_PACKAGES="libncurses5 curl python-is-python3"
DEBIAN_10_PACKAGES="libncurses5"
PACKAGES=""

echo -e "\n================== Check linux version ==================\n"
# Install lsb-core packages
sudo apt update 
sudo apt upgrade -y 
#sudo apt install lsb-core -y
LSB_RELEASE="$(lsb_release -d | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//')"

if [[ ${LSB_RELEASE} =~ "Mint 18" || ${LSB_RELEASE} =~ "Ubuntu 16" ]]; then
    PACKAGES="${UBUNTU_16_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Ubuntu 20.04.1 LTS" ]]; then
    PACKAGES="${UBUNTU_20_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Debian GNU/Linux 10" ]]; then
    PACKAGES="${DEBIAN_10_PACKAGES}"
fi
echo "Done"

echo -e "\n================== Installing packages ==================\n"
sudo DEBIAN_FRONTEND=noninteractive \
    apt install \
    adb autoconf automake axel bc bison build-essential \
    clang cmake expat flex g++ \
    g++-multilib gawk gcc gcc-multilib gnupg gperf \
    htop imagemagick lib32ncurses5-dev lib32z1-dev libtinfo5 libc6-dev libcap-dev \
    libexpat1-dev libgmp-dev '^liblz4-.*' '^liblzma.*' libmpc-dev libmpfr-dev libncurses5-dev \
    libsdl1.2-dev libssl-dev libtool libxml2 libxml2-utils '^lzma.*' lzop \
    maven ncftp ncurses-dev patch patchelf pkg-config pngcrush \
    pngquant python2.7 python-all-dev re2c schedtool squashfs-tools subversion \
    texinfo unzip w3m xsltproc zip zlib1g-dev lzip \
    libxml-simple-perl apt-utils \
    jq nghttp2 libnghttp2-dev libz-dev libcurl4-gnutls-dev \
    libc6-dev-i386 x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev \
    python-mako ninja-build syslinux syslinux-utils gettext genisoimage xorriso make git ccache \
    ${PACKAGES} -y
    
echo "Done"

echo -e "\n================== Setting up udev rules for adb! ==================\n"
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo systemctl restart udev
echo "Done"

# echo -e "\n================== Installing latest make version ==================\n"
# if [[ "$(command -v make)" ]]; then
#     makeversion="$(make -v | head -1 | awk '{print $3}')"
#     if [[ ${makeversion} != "${LATEST_MAKE_VERSION}" ]]; then
#         echo "Installing make ${LATEST_MAKE_VERSION} instead of ${makeversion}"
#         cd /tmp || exit 1
#         axel -a -n 10 https://ftp.gnu.org/gnu/make/make-"${LATEST_MAKE_VERSION}".tar.gz
#         tar xvzf /tmp/make-"${LATEST_MAKE_VERSION}".tar.gz
#         cd /tmp/make-"${LATEST_MAKE_VERSION}" || exit 1
#         ./configure
#         bash ./build.sh
#         sudo install ./make /usr/local/bin/make
#         cd - || exit 1
#         rm -rf /tmp/make-"${LATEST_MAKE_VERSION}"{,.tar.gz}
#     fi
# fi
# echo "Done"

# echo -e "\n================== Installing latest git version ==================\n"
#LATEST_TAG=$(curl https://api.github.com/repos/git/git/tags | jq -r '.[0].name')
#cd /tmp || exit 1
#git clone https://github.com/git/git -b "$LATEST_TAG"
#cd git || exit
#make configure
#./configure --prefix=/usr/local --with-curl
#sudo make install -j"$(nproc)"
#git --version
#cd - || exit
#rm -rf git

#sudo apt-get install build-essential fakeroot dpkg-dev -y
#sudo apt-get build-dep git -y
#sudo apt-get install libcurl4-openssl-dev -y
#cd /tmp || exit 1
#mkdir source-git
#cd source-git/
#apt-get source git
#cd git-2.*.*/
#sed -i -- 's/libcurl4-gnutls-dev/libcurl4-openssl-dev/' ./debian/control
#sed -i -- '/TEST\s*=\s*test/d' ./debian/rules
#dpkg-buildpackage -rfakeroot -b -uc -us
#sudo dpkg -i ../git_*ubuntu*.deb
#cd - || exit 1
# echo "Done"

echo -e "\n================== Installing java-8 and set version 8 ==================\n"
sudo apt-get install openjdk-8-jdk -y
sudo update-alternatives --config java
sudo update-alternatives --config javac
echo "Done"

# echo -e "\n================== Installing latest ccache version ==================\n"
# cd /tmp || exit 1
# git clone git://github.com/ccache/ccache.git
# cd ccache || exit 1
# ./autogen.sh
# ./configure --disable-man --with-libzstd-from-internet --with-libb2-from-internet
# make -j"$(nproc)"
# sudo make install
# rm -rf "${PWD}"
# cd - || exit 1
# echo "Done"

echo -e "\n================== Installing repo ==================\n"
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod +x ~/bin/repo
echo "Done"

# Install Git LFS
echo -e "\n================== Installing git-lfs ==================\n"
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install git-lfs
echo "Done"

# Install Android SDK
# echo -e "\n================== INSTALLING ANDROID SDK ==================\n"
# wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
# unzip platform-tools-latest-linux.zip -d ~/
# rm platform-tools-latest-linux.zip
# echo "Done"

# Install repo
#echo -e "\n================== INSTALLING GIT-REPO ==================\n"
#wget https://storage.googleapis.com/git-repo-downloads/repo
#chmod a+x repo
#sudo install repo /usr/local/bin/repo
#echo "Done"

# Install google drive command line tool
# echo -e "\n================== INSTALLING GDRIVE CLI ==================\n"
# wget -O gdrive "https://docs.google.com/uc?id=0B3X9GlR6EmbnWksyTEtCM0VfaFE&export=download"
# chmod a+x gdrive
# sudo install gdrive /usr/local/bin/gdrive
# echo "Done"

# Set up environment
echo -e "\n================== SETTING UP ENV ==================\n"
# cat <<'EOF' >> ~/.bashrc
# # Super-fast repo sync
# repofastsync() { schedtool -B -n 1 -e ionice -n 1 `which repo` sync -c -f --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j8 "$@"; }

# # Enable CCACHE
# export USE_CCACHE=1
# # export CCACHE_NOCOMPRESS=true
# # $HOME/.ccache/ccache.conf fir set max-size

# export LC_ALL=C

# # Add java to path
# JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
# PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
# export JAVA_HOME

# # fix Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
# export _JAVA_OPTIONS="-Xmx4096m"

# memsize=$(($(grep MemTotal /proc/meminfo | awk '{print $2}')/(1024 * 1024)))
# if [ $memsize -lt 16 ]; then
#     export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx$(($memsize/2))g"
#     export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx$(($memsize/2))g"
# fi

# EOF


# Add android sdk to path
# cat <<'EOF' >> ~/.profile
# Add Android SDK platform tools to path
# if [ -d "$HOME/platform-tools" ] ; then
#     PATH="$HOME/platform-tools:$PATH"
# fi
# EOF
# echo "Done"

#echo -e "\n================== Set python2 default ==================\n"
#sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 2
#sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 3
#sudo update-alternatives --config python
#echo "Done"

# Configure git
echo -e "\n================== CONFIGURING GIT ==================\n"
git config --global user.email "abdd199719@gmail.com"
git config --global user.name "Abdalrohman N"
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=9999999'
echo "Done"

echo "You are now ready to build Android!"
