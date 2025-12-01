#!/bin/sh

# Benjamin Michael Taylor (bentaylorhk)
# 2025

IMGS_PATH=$HOME/images/dashboard

WORKSPACE=1

IS_POLYPHONIC=0
if [ "$IS_POLYPHONIC" -eq 1 ]; then
    i3-msg "workspace $WORKSPACE"
    i3-msg "append_layout /home/ben/.config/i3/polyphonic.json"
    alacritty -o font.size=6 -e ~/repos/polymorphism/polymorphism_wrapper.sh

    sleep 1

    i3-msg '[title="alacritty"] focus'

    exit
fi

if xrandr | grep -q "^DVI-0 connected"; then
    i3-msg "workspace $WORKSPACE"
    i3-msg "append_layout $HOME/.config/i3/crt_terminal.json"
    sleep 0.1
    alacritty -o font.size=6 --title crt &

    WORKSPACE=2
fi

HOSTNAME=$(cat /etc/hostname)

if [ "$HOSTNAME" = "gpd-pocket-3-polyos" ]; then
    FEH_ZOOM=35
elif [ "$HOSTNAME" = "atx-polyos" ]; then
    FEH_ZOOM=40
else
    FEH_ZOOM=70
fi

i3-msg "workspace $WORKSPACE"
i3-msg "append_layout $HOME/.config/i3/boot_layout.json"
sleep 0.1
feh --zoom $FEH_ZOOM "$IMGS_PATH" &
alacritty --title cbonsai -e sh -c 'cbonsai -li' &
alacritty --title neofetch -e sh -c 'echo && echo && neofetch && tput civis && read -r -s' &
alacritty --title htop -e sh -c 'htop' &
