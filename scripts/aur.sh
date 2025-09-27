#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2024 - 2025

set -e

mkdir -p "$HOME/aur"
pushd "$HOME/aur"
rm -rf "$1"
git clone "https://aur.archlinux.org/$1.git"
pushd "$1"
makepkg --syncdeps --rmdeps --clean --noconfirm --install
