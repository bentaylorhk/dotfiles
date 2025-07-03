#!/bin/sh

# Benjamin Michael Taylor (bentaylorhk)
# 2025

set -e

FONT_SIZE=21

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Array of font names to process
FONT_NAMES="scientifica scientificaBold scientificaItalic"

for FONT_NAME in $FONT_NAMES; do
    FONT_PATH="$SCRIPT_DIR/../ttf/$FONT_NAME.ttf"
    
    if [ ! -f "$FONT_PATH" ]; then
        echo "Error: Font file not found at: $FONT_PATH" >&2
        continue
    fi
    
    echo "Using font file: $FONT_PATH"
    
    # Generate the PF2 font file in the script directory
    OUTPUT_FILE="$SCRIPT_DIR/$FONT_NAME.pf2"
    echo "Generating GRUB font: $OUTPUT_FILE"
    grub-mkfont --output="$OUTPUT_FILE" --size=$FONT_SIZE "$FONT_PATH"
    
    echo "Generated: $OUTPUT_FILE"
    echo ""
done

