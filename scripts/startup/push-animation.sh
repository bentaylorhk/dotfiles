#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2025

# Script which pushes animation files maintined upstream to
# relavant system files, and enables the service.

set -e

ANIMATION_DIR=~/scripts/startup

SYSTEM_ASCII_ART_DIR=/usr/local/share/ascii-art

sudo mkdir -p $SYSTEM_ASCII_ART_DIR
sudo cp ~/ascii-art/polyOS/caligraphy.txt $SYSTEM_ASCII_ART_DIR/boot.txt
sudo cp ~/ascii-art/gecko.txt $SYSTEM_ASCII_ART_DIR/login.txt

sudo cp ~/scripts/startup/formatted-issue /usr/local/share/.

sudo chmod +x $ANIMATION_DIR/startup.sh
sudo cp $ANIMATION_DIR/startup.sh /usr/local/bin/.
sudo cp $ANIMATION_DIR/boot-animation /usr/local/bin/.
sudo cp -r ~/systemd/. /etc/systemd/system/.

sudo chmod +x ~/scripts/right-justify.sh
sudo cp ~/scripts/right-justify.sh /usr/local/bin/.

sudo systemctl enable startup.service
sudo systemctl enable getty@tty1.service
