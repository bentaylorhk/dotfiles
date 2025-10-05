#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025

# Install VS Code extensions from extensions.list in the script's directory

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_LIST="$DIR/extensions.list"

if [ ! -f "$EXT_LIST" ]; then
  echo "No extension list found at $EXT_LIST"
  exit 1
fi

echo "Installing extensions from $EXT_LIST..."
xargs -n 1 code --install-extension < "$EXT_LIST"
echo "VS Code extensions installation complete."
