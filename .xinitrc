#!/bin/sh
# Benjamin Michael Taylor (bentaylorhk)
# 2023-2025

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

if [ -f "$sysresources" ]; then
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

if [ "$COLOURSCHEME" = "choihung" ]; then
  xsetroot -solid "#000000"
elif [ "$COLOURSCHEME" = "gruvbox" ]; then
  xsetroot -solid "#f2e5bc"
else
  xsetroot -solid "#000000"
fi

# Autorandr profiles cannot create custom modes; add the CRT mode before
# applying a profile that uses it.
if xrandr --query | grep -q '^DVI-0 connected'; then
  if ! xrandr --query | grep -q '320x240_60.00'; then
    xrandr --newmode "320x240_60.00" 6.08 320 328 360 400 240 243 247 253 -HSync +VSync
  fi
  if ! xrandr --query | awk '
      /^DVI-0 connected/ { in_dvi = 1; next }
      /^[^[:space:]]/ { in_dvi = 0 }
      in_dvi && /320x240_60.00/ { found = 1 }
      END { exit !found }
    '; then
    xrandr --addmode DVI-0 320x240_60.00
  fi
fi

# Apply the saved layout instead of overriding it with xrandr --auto.
if ! autorandr --change; then
  echo "autorandr could not apply a profile; using connected outputs' preferred modes." >&2
  xrandr --auto
fi

exec i3
