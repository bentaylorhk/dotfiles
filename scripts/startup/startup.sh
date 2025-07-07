#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025

set -e

# Doubling font size for login readability
setfont -d scientifica.psf

# Boot splash
clear
/usr/local/bin/boot-animation /usr/local/share/ascii-art/boot.txt

# Injecting welcome message
echo "" >/etc/issue
echo "" >>/etc/issue
echo "Welcome to polyOS!" | /usr/local/bin/justify.sh center >>/etc/issue
echo "==================" | /usr/local/bin/justify.sh center >>/etc/issue
echo "" >>/etc/issue

# Injecting login banner
/usr/local/bin/justify.sh right /usr/local/share/ascii-art/login.txt | sed 's/\\/\\\\/g' >>/etc/issue
cat /usr/local/share/formatted-issue >>/etc/issue
echo "" >>/etc/issue
echo "" >>/etc/issue
