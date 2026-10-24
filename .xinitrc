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

# Autorandr profiles cannot create custom modes; add this host's CRT mode
# before applying a profile that uses it.
[ -f "$HOME/scripts/lib/host.sh" ] && . "$HOME/scripts/lib/host.sh"
if [ -n "${CRT_OUTPUT:-}" ] && [ -n "${CRT_MODE_NAME:-}" ] &&
  xrandr --query | grep -q "^$CRT_OUTPUT connected"; then
  if ! xrandr --query | grep -q "$CRT_MODE_NAME"; then
    # shellcheck disable=SC2086
    xrandr --newmode "$CRT_MODE_NAME" $CRT_MODELINE
  fi
  if ! xrandr --query | awk -v out="$CRT_OUTPUT" -v mode="$CRT_MODE_NAME" '
      $1 == out && $2 == "connected" { in_out = 1; next }
      /^[^[:space:]]/ { in_out = 0 }
      in_out && $1 == mode { found = 1 }
      END { exit !found }
    '; then
    xrandr --addmode "$CRT_OUTPUT" "$CRT_MODE_NAME"
  fi
fi

# Apply the saved layout instead of overriding it with xrandr --auto.
if ! autorandr --change; then
  echo "autorandr could not apply a profile; using connected outputs' preferred modes." >&2
  xrandr --auto
fi

exec i3
