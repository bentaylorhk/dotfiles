#
# ~/.bash_profile
#

# Sourcing .bashrc
[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
  # Hosts with WIFI_ONLY_IN_X_SESSION=yes (see hosts/) keep Wi-Fi off except in X
  [[ -f ~/scripts/lib/host.sh ]] && . ~/scripts/lib/host.sh
  if [[ "${WIFI_ONLY_IN_X_SESSION:-no}" == yes ]] && command -v nmcli >/dev/null; then
    nmcli radio wifi on 2>/dev/null || true
    startx
    nmcli radio wifi off 2>/dev/null || true
  else
    startx
  fi
fi
