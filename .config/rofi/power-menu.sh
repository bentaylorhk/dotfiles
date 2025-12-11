#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025

options="Update\nLogout\nSuspend\nReboot\nShutdown"

theme_str="inputbar { enabled: false; visible: false; height: 0px; margin: 0px; border: 0px; padding: 0px; } prompt { enabled: false; visible: false; height: 0px; margin: 0px; padding: 0px; }"

chosen=$(echo -e "$options" | rofi -i -dmenu -p '' -lines 5 -theme-str "$theme_str" -no-custom)

case "$chosen" in
    Update)
        $HOME/scripts/floating_update_polyos.sh
        ;;
    Logout)
        i3-msg exit
        ;;
    Suspend)
        systemctl suspend
        ;;
    Reboot)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    *)
        # Do nothing if the user closes the menu or chooses nothing
        ;;
esac
