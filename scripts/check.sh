#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2026

# Static checks for the dotfiles repo. Tools that aren't installed are skipped
# unless CI=true, where a missing tool is a failure.
#   --online   also verify package names against 'pacman -Sl' (Arch only)

set -uo pipefail

REPO_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
GIT=(git --git-dir="${DOTFILES_GIT_DIR:-$REPO_DIR/.dotfiles}" --work-tree="$REPO_DIR")
[[ -d "$REPO_DIR/.git" ]] && GIT=(git -C "$REPO_DIR")
cd "$REPO_DIR" || exit 1

ONLINE=0
[[ "${1:-}" == "--online" ]] && ONLINE=1
FAILED=0

fail() {
  echo "FAIL: $*" >&2
  FAILED=1
}

# Skips locally, fails in CI
need_tool() {
  command -v "$1" >/dev/null 2>&1 && return 0
  if [[ "${CI:-}" == "true" ]]; then
    fail "$1 is required in CI but not installed."
  else
    echo "skip: $1 not installed"
  fi
  return 1
}

mapfile -t TRACKED < <("${GIT[@]}" ls-files)

is_shell() {
  local f="$1" first
  [[ -f "$f" && ! -L "$f" ]] || return 1
  case "$f" in *.sh | *.bash) return 0 ;; esac
  IFS= read -r first <"$f" 2>/dev/null || return 1
  [[ "$first" =~ ^#!.*(ba|da|)sh ]]
}

echo "== shell syntax"
SHELL_FILES=()
for f in "${TRACKED[@]}"; do
  is_shell "$f" || continue
  SHELL_FILES+=("$f")
  IFS= read -r first <"$f" || true
  if [[ "$first" == *bash* ]]; then
    bash -n "$f" || fail "bash -n $f"
  else
    sh -n "$f" || fail "sh -n $f"
  fi
done
echo "${#SHELL_FILES[@]} scripts"

echo "== shellcheck"
if need_tool shellcheck; then
  # .bashrc-style files are excluded because they have no shebang
  shellcheck -S warning "${SHELL_FILES[@]}" || fail "shellcheck"
fi

echo "== python"
if command -v python3 >/dev/null 2>&1; then
  for f in "${TRACKED[@]}"; do
    [[ "$f" == *.py ]] || continue
    python3 -c 'import ast,sys; ast.parse(open(sys.argv[1]).read(), sys.argv[1])' "$f" ||
      fail "python syntax $f"
  done
fi

echo "== package files"
declare -A SEEN
for f in packages/*.txt; do
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line//[[:space:]]/}"
    [[ -n "$line" ]] || continue
    [[ "$line" =~ ^[a-zA-Z0-9@._+-]+$ ]] || fail "$f: invalid package name '$line'"
    [[ -z "${SEEN[$line]:-}" ]] || fail "$f: '$line' is already in ${SEEN[$line]}"
    SEEN[$line]="$f"
  done <"$f"
done
echo "${#SEEN[@]} packages"
if [[ "$ONLINE" -eq 1 ]]; then
  if need_tool pacman; then
    mapfile -t known < <(pacman -Sl | awk '{print $2}' | sort -u)
    for p in "${!SEEN[@]}"; do
      [[ "${SEEN[$p]}" == packages/aur.txt ]] && continue
      printf '%s\n' "${known[@]}" | grep -qxF -- "$p" || fail "${SEEN[$p]}: '$p' not in pacman repos"
    done
  fi
fi

echo "== host files"
for f in hosts/*.conf; do
  (
    ROLES=""
    # shellcheck disable=SC1090
    . "$f" || exit 1
    name="$(basename "$f" .conf)"
    POLYOS_HOSTNAME="$name" POLYOS_HOSTS_DIR="$REPO_DIR/hosts"
    export POLYOS_HOSTNAME POLYOS_HOSTS_DIR
    # shellcheck disable=SC1091
    . scripts/lib/host.sh
    [[ -n "$ROLES" ]] || exit 2
    for r in $ROLES; do [[ -f "packages/$r.txt" ]] || exit 3; done
  ) || fail "host file $f (bad syntax, empty ROLES or unknown role)"
done

echo "== i3 config"
if need_tool i3; then
  i3 -C -c .config/i3/config >/dev/null || fail "i3 -C"
fi

echo "== systemd units"
if need_tool systemd-analyze; then
  units=()
  for u in systemd/startup.service systemd/ark-*.service systemd/ark-*.timer; do
    [[ -f "$u" ]] && units+=("$u")
  done
  # Units reference files installed elsewhere, so only syntax errors matter
  out="$(systemd-analyze verify --man=no "${units[@]}" 2>&1 || true)"
  if grep -Eiq "syntax|unknown (section|key|lvalue)|invalid" <<<"$out"; then
    echo "$out" >&2
    fail "systemd-analyze verify"
  fi
fi

echo
if [[ "$FAILED" -eq 0 ]]; then echo "All checks passed."; else echo "Checks failed." >&2; fi
exit "$FAILED"
