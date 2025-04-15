#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2025
set -e

# Doubling font size for login readability
setfont -d

# Boot splash
clear
/usr/local/bin/boot-animation /usr/local/share/ascii-art/boot.txt

# Injecting login banner
/usr/local/bin/right-justify.sh /usr/local/share/ascii-art/login.txt | sed 's/\\/\\\\/g' >/etc/issue
cat /usr/local/share/formatted-issue >>/etc/issue
