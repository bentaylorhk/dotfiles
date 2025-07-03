#!/bin/bash

# Benjamin Michael Taylor (bentaylorhk)
# 2025

set -e

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <justification> [path_to_ascii_art.txt]" >&2
  echo "Justification options: left, right, center" >&2
  echo "If no file is provided, reads from stdin" >&2
  exit 1
fi

justification="$1"
ascii_art_file="$2"

case "$justification" in
  left|right|center)
    ;;
  *)
    echo "Error: Invalid justification '$justification'. Use 'left', 'right', or 'center'." >&2
    exit 1
    ;;
esac

cols=$(tput cols)

lines=()
maxlen=0

if [ -n "$ascii_art_file" ]; then
  # Read from file
  while IFS= read -r line; do
    lines+=("$line")
    len=${#line}
    ((len > maxlen)) && maxlen=$len
  done <"$ascii_art_file"
else
  # Read from stdin
  while IFS= read -r line; do
    lines+=("$line")
    len=${#line}
    ((len > maxlen)) && maxlen=$len
  done
fi

for line in "${lines[@]}"; do
  case "$justification" in
    left)
      echo "$line"
      ;;
    right)
      left_pad=$((cols - maxlen))
      padding=$(printf '%*s' "$left_pad" "")
      echo "${padding}${line}"
      ;;
    center)
      line_len=${#line}
      left_pad=$(((cols - line_len) / 2))
      padding=$(printf '%*s' "$left_pad" "")
      echo "${padding}${line}"
      ;;
  esac
done