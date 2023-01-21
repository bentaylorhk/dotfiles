#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

#
# Console Header
#
cbonsai -p
python /home/ben/scripts/bash_header.py --dir-path /home/ben/ascii-art/polyOS
