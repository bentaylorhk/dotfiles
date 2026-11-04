#!/usr/bin/env bash

# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Reports display density to guide a deliberate Xft.dpi choice.

set -euo pipefail

usage() {
  echo "Usage: display-calibrate.sh [--output OUTPUT]" >&2
}

output=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      [[ $# -ge 2 ]] || {
        usage
        exit 1
      }
      output="$2"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
  shift
done

command -v xrandr >/dev/null || {
  echo "xrandr is required." >&2
  exit 1
}

query="$(xrandr --query)"
if [[ -n "$output" ]]; then
  lines="$(awk -v output="$output" '$1 == output && $2 == "connected"' <<<"$query")"
  [[ -n "$lines" ]] || {
    echo "Output '$output' is not connected." >&2
    exit 1
  }
else
  lines="$(awk '$2 == "connected"' <<<"$query")"
fi

current_dpi="$(awk '/^Xft\.dpi:/ { print $2; exit }' "$HOME/.Xresources" 2>/dev/null || true)"
printf 'Current Xft.dpi: %s\n\n' "${current_dpi:-not set}"

while IFS= read -r line; do
  [[ "$line" =~ ^([^[:space:]]+) ]] || continue
  name="${BASH_REMATCH[1]}"
  if [[ ! "$line" =~ ([0-9]+)x([0-9]+)\+ ]] ||
    [[ ! "$line" =~ ([0-9]+)mm[[:space:]]x[[:space:]]([0-9]+)mm ]]; then
    printf '%s: unable to determine active resolution or physical size\n' "$name"
    continue
  fi

  width_px="${BASH_REMATCH[1]}"
  height_px="${BASH_REMATCH[2]}"
  if [[ "$line" =~ ([0-9]+)x([0-9]+)\+ ]]; then
    width_px="${BASH_REMATCH[1]}"
    height_px="${BASH_REMATCH[2]}"
  fi
  if [[ "$line" =~ ([0-9]+)mm[[:space:]]x[[:space:]]([0-9]+)mm ]]; then
    width_mm="${BASH_REMATCH[1]}"
    height_mm="${BASH_REMATCH[2]}"
  fi

  x_dpi="$(awk -v px="$width_px" -v mm="$width_mm" 'BEGIN { printf "%.0f", px / mm * 25.4 }')"
  y_dpi="$(awk -v px="$height_px" -v mm="$height_mm" 'BEGIN { printf "%.0f", px / mm * 25.4 }')"
  printf '%s: %sx%s px, %sx%s mm, %s x %s physical DPI\n' \
    "$name" "$width_px" "$height_px" "$width_mm" "$height_mm" "$x_dpi" "$y_dpi"
done <<<"$lines"

cat <<'EOF'

Use this as a reference only: choose an Xft.dpi value by visual comfort, then
update .Xresources and restart X. Common trial values are 96, 120, 144, and 168.
EOF
