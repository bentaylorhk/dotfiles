#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2025

# Script which pushes animation files maintined upstream to
# relavant system files, and enables the service.

set -e

ANIMATION_DIR=~/scripts/boot-animation

sudo cp ~/ascii-art/polyOS/caligraphy.txt /usr/local/share/ascii-art/boot.txt

sudo chmod +x $ANIMATION_DIR/boot-animation.sh
sudo cp $ANIMATION_DIR/boot-animation.sh /usr/local/bin/.
sudo cp $ANIMATION_DIR/splash /usr/local/bin/.
sudo cp -r ~/systemd /etc/systemd/system/.

sudo systemctl enable boot-animation.service
sudo systemctl enable getty@tty1.service
