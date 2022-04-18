#!/usr/bin/env bash
# -*- coding: utf-8 -*-

version="16.14.2"

wget -O /tmp/nodejs.tar.xz https://nodejs.org/dist/v$version/node-v$version-linux-x64.tar.xz

if [ "$?" -eq 0 ]; then
  echo "export PATH=/usr/local/lib/nodejs/node-v$version-linux-x64/bin:"'$PATH' >>"$HOME"/.profile
fi

if [ -f "/tmp/nodejs.tar.xz" ]; then
  sudo mkdir -p /usr/local/lib/nodejs
  sudo tar -xJf /tmp/nodejs.tar.xz -C /usr/local/lib/nodejs
  if [ "$?" -eq 0 ]; then
    rm /tmp/nodejs.tar.xz
  fi
fi

sudo DEBIAN_FRONTEND=noninteractive \
  apt install npm -y

if [ "$(command -v npm)" ]; then
  sudo npm i -g yarn
fi
