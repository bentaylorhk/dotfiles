#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2025

# Script which pushes animation files maintined upstream to
# relavant system files, and enables the service.

set -e

ANIMATION_DIR=~/scripts/startup

sudo cp ~/ascii-art/polyOS/caligraphy.txt /usr/local/share/ascii-art/boot.txt
sudo cp ~/ascii-art/gecko.txt /usr/local/share/ascii-art/login.txt

sudo cp ~/scripts/startup/formatted-issue /usr/local/share/.

sudo chmod +x $ANIMATION_DIR/startup.sh
sudo cp $ANIMATION_DIR/startup.sh /usr/local/bin/.
sudo cp $ANIMATION_DIR/boot-animation /usr/local/bin/.
sudo cp -r ~/systemd/. /etc/systemd/system/.

sudo chmod +x ~/scripts/right-justify.sh
sudo cp ~/scripts/right-justify.sh /usr/local/bin/.

sudo systemctl enable startup.service
sudo systemctl enable getty@tty1.service
