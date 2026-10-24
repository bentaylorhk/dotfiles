#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Audits tracked files for things that shouldn't live in a public dotfiles
# repo: private keys, tokens, caches, history and oversized files.
# Exits non-zero if anything is found.

set -uo pipefail

REPO_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
GIT=(git --git-dir="${DOTFILES_GIT_DIR:-$REPO_DIR/.dotfiles}" --work-tree="$REPO_DIR")
[[ -d "$REPO_DIR/.git" ]] && GIT=(git -C "$REPO_DIR")
cd "$REPO_DIR" || exit 1

MAX_KB="${AUDIT_MAX_KB:-512}"
FOUND=0

flag() {
  echo "FOUND: $*"
  FOUND=1
}

mapfile -t TRACKED < <("${GIT[@]}" ls-files)

for f in "${TRACKED[@]}"; do
  [[ -f "$f" ]] || continue

  case "$f" in
    *.bak | *.log | *.pyc | *.db | *.sqlite* | *.lock | */__pycache__/* | .cache/* | .viminfo | *history* | .Xauthority | *.pem | *.key | id_rsa* | id_ed25519*)
      flag "$f: cache, history, key or state file"
      continue
      ;;
  esac

  size_kb=$(($(stat -c %s "$f") / 1024))
  [[ "$size_kb" -le "$MAX_KB" ]] || flag "$f: ${size_kb}KB exceeds ${MAX_KB}KB"

  # Binary files can't hold readable secrets
  grep -Iq . "$f" 2>/dev/null || continue

  if grep -q -- '-----BEGIN [A-Z ]*PRIVATE KEY-----' "$f"; then
    flag "$f: private key"
  fi
  if grep -Eq '(ghp_|gho_|github_pat_|xox[baprs]-|AKIA|sk-[A-Za-z0-9]{20,})[A-Za-z0-9_-]{10,}' "$f"; then
    flag "$f: token-like string"
  fi
done

# Tracked files the ignore rules would now hide
while IFS= read -r f; do
  flag "$f: tracked but ignored"
done < <("${GIT[@]}" ls-files -ci --exclude-standard)

if [[ "$FOUND" -eq 0 ]]; then echo "Audit clean (${#TRACKED[@]} files)."; fi
exit "$FOUND"
