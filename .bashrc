#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Including bash files
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
[[ -f ~/.bash_variables ]] && . ~/.bash_variables

# Console Header
cbonsai -p
python /home/ben/scripts/bash_header.py --dir-path /home/ben/ascii-art/polyOS
