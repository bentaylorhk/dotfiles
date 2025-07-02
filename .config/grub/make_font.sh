#!/bin/sh

# Benjamin Michael Taylor (bentaylorhk)
# 2025

set -e

# Get font name from command line argument
if [ $# -eq 0 ]; then
    echo "Error: Font name not provided." >&2
    echo "Usage: $0 <font_name>" >&2
    exit 1
fi

FONT_NAME="$1"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Searching for $FONT_NAME font..."
FONT_PATH=$(fc-list | grep -i "$FONT_NAME" | grep -i "\.ttf" | head -n1 | cut -d':' -f1 | tr -d ' ')

if [ -z "$FONT_PATH" ]; then
    echo "Error: Could not find $FONT_NAME TTF font in system." >&2
    exit 1
fi

echo "Found $FONT_NAME font at: $FONT_PATH"

# Generate the PF2 font file in the script directory
OUTPUT_FILE="$SCRIPT_DIR/theme/$FONT_NAME.pf2"
echo "Generating GRUB font: $OUTPUT_FILE"
grub-mkfont --output="$OUTPUT_FILE" --size=16 "$FONT_PATH"

if [ -f "$OUTPUT_FILE" ]; then
    echo "Successfully created $FONT_NAME.pf2 font file!"
else
    echo "Error: Failed to create font file." >&2
    exit 1
fi
