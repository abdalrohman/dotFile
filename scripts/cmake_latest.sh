#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# https://github.com/Kitware/CMake/releases/latest
# https://api.github.com/repos/Kitware/CMake/releases/latest

cmake_version=$(curl -s https://api.github.com/repos/Kitware/CMake/releases/latest | grep "tag_name" | cut -d':' -f 2 | tr -d "\"" | tr -d "," | tr -d "v" | xargs)

latest_cmake_url=$(curl -s https://api.github.com/repos/Kitware/CMake/releases/latest | grep "browser_download_url.*linux-x86_64.tar.gz" | cut -d':' -f 2,3 | tr -d "\"" | xargs)

wget -O /tmp/cmake_"$cmake_version".tar.gz "$latest_cmake_url"

tar -xzf /tmp/cmake_"$cmake_version".tar.gz -C /tmp && rm /tmp/cmake_"$cmake_version".tar.gz

sudo cp -rv /tmp/cmake-"$cmake_version"-linux-x86_64 /usr/local/

# cmake_version=$(curl -s https://api.github.com/repos/Kitware/CMake/releases/latest | grep "tag_name" | cut -d':' -f 2 | tr -d "\"" | tr -d "," | tr -d "v" | xargs)

# latest_cmake_url=$(curl -s https://api.github.com/repos/Kitware/CMake/releases/latest | grep "browser_download_url.*linux-x86_64.sh" | cut -d':' -f 2,3 | tr -d "\"" | xargs)

# wget -O /tmp/cmake_"$cmake_version".sh "$latest_cmake_url"

# sudo sh /tmp/cmake_"$cmake_version".sh --prefix=/usr/local/ --exclude-subdir && rm /tmp/cmake_"$cmake_version".sh


# qttools5-dev 