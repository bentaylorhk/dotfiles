#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2025
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <path_to_ascii_art.txt>" >&2
  exit 1
fi

ascii_art_file="$1"

# Get the terminal width
cols=$(tput cols)

# Compute the maximum line length in the banner file
maxlen=0
while IFS= read -r line; do
  len=${#line}
  ((len > maxlen)) && maxlen=$len
done <"$ascii_art_file"

# Calculate left padding to center the entire block
left_pad=$((cols - maxlen))
padding=$(printf '%*s' "$left_pad" "")

# Print each line with uniform left padding
while IFS= read -r line; do
  echo "${padding}${line}"
done <"$ascii_art_file"
