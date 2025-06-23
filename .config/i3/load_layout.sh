#!/bin/sh

# Benjamin Michael Taylor (bentaylorhk)
# 2025

IMGS_PATH=$HOME/images/dashboard

WORKSPACE=1

if xrandr | grep -q "^DVI-0 connected"; then
    i3-msg "workspace $WORKSPACE; move workspace to output DVI-0"
    i3-msg "workspace $WORKSPACE"
    i3-msg "append_layout /path/to/your/workspace1_layout.json"
    alacritty -o font.size=6 --title crt &

    WORKSPACE=2
fi

if [ "$(hostname)" = "gpd-pocket-3-polyos" ]; then
    FEH_ZOOM=35
else
    FEH_ZOOM=70
fi

i3-msg "workspace $WORKSPACE"
i3-msg "append_layout /home/ben/.config/i3/boot_layout.json"
sleep 1
feh --zoom $FEH_ZOOM "$IMGS_PATH" &
alacritty --title cbonsai -e sh -c 'cbonsai -li' &
alacritty --title neofetch -e sh -c 'echo && echo && neofetch && tput civis && read -r -s' &
alacritty --title htop -e sh -c 'htop' &
