#
# ~/.bashrc
#

# Benjamin Michael Taylor (bentaylorhk)
# 2023 - 2025

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Including bash files
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
[[ -f ~/.bash_variables ]] && . ~/.bash_variables
[[ -f ~/.bash_prompts ]] && . ~/.bash_prompts
[[ -f ~/.bash_keys ]] && . ~/.bash_keys

# Setting to use .Xresources colors
if [ "$TERM" = "linux" ]; then
  _SEDCMD='s/.*\*color\([0-9]\{1,\}\).*#\([0-9a-fA-F]\{6\}\).*/\1 \2/p'
  for i in $(sed -n "$_SEDCMD" $HOME/.Xresources | awk '$1 < 16 {printf "\\e]P%X%s", $1, $2}'); do
    echo -en "$i"
  done
  clear
fi

# Console Header
# cbonsai -p
if [[ -n ${SSH_CONNECTION:-} ]]; then
  __header_hostname="${HOSTNAME:-$(uname -n)}"
  __header_ark_status="$(systemctl is-active ark-server.service 2>/dev/null || true)"
  [[ -n "$__header_ark_status" ]] || __header_ark_status=unknown
  python "$HOME/scripts/bash_header.py" \
    --dir-path "$HOME/ascii-art/bash-headers" \
    --hostname "$__header_hostname" \
    --ark-status "$__header_ark_status"
else
  python "$HOME/scripts/bash_header.py" --dir-path "$HOME/ascii-art/bash-headers"
fi
