#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025

# Save currently installed VS Code extensions to dotfiles repo

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_LIST="$DIR/extensions.list"

code --list-extensions > "$EXT_LIST"
echo "Saved VS Code extensions to $EXT_LIST"
