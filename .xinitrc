#!/bin/sh
# Benjamin Michael Taylor (bentaylorhk)
# 2023-2025

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

if [ -f $sysresources ]; then
  xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
  xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
  xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
  xmodmap "$usermodmap"
fi

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# TODO: Conditionally execute based off /etc/hostname

# Setting the background to a solid colour
xsetroot -solid "#f2e5bc"

# Save monitor configuration with 'autorandr --save <layout_name>'
# Touchscreen is mapped by hook in '.config/autorandr/postswitch'
autorandr --change

exec i3
