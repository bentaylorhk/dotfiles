# polyOS dotfiles

Dotfiles for my Arch Linux machines (i3, polybar, rofi, picom, alacritty, neovim).
They are kept in a **bare git repo** at `~/.dotfiles` with `$HOME` as the work tree.

## Using the repo

The `dotfiles` alias (in `.bash_aliases`) is:

```sh
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

`status.showUntrackedFiles` is `no` and `.gitignore` is a deny-list, so new files
must be added explicitly (including `~/.github`):

```sh
dotfiles status
dotfiles add .config/foo/config      # start tracking
dotfiles rm --cached path            # stop tracking, keep the file
dotfiles commit -m "..." && dotfiles push
```

### Bootstrap a new machine

```sh
git clone --bare git@github.com:bentaylorhk/dotfiles.git ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config status.showUntrackedFiles no
dotfiles checkout
```

If checkout complains that files would be overwritten, move them aside and retry:

```sh
mkdir -p ~/dotfiles-backup
dotfiles checkout 2>&1 | grep -E '^\s+' | awk '{print $1}' | \
  xargs -I{} sh -c 'mkdir -p ~/dotfiles-backup/$(dirname {}) && mv ~/{} ~/dotfiles-backup/{}'
dotfiles checkout
```

Then add the host file (below), run `update-polyos packages`, and
`scripts/install-system.sh` if you want the boot banner.

### Recovering from a bad pull

```sh
dotfiles reflog              # find the commit before the pull
dotfiles reset --hard HEAD@{1}
```

`reset --hard` discards uncommitted changes to tracked files, so check
`dotfiles status` first.

## Layout

| Path | Purpose |
| --- | --- |
| `packages/<role>.txt` | One pacman package per line; `aur.txt` is installed with `yay` |
| `hosts/default.conf`, `hosts/<hostname>.conf` | Per-host `ROLES` and CRT display settings |
| `scripts/lib/host.sh` | Sourced loader: default, then `/etc/hostname` file |
| `scripts/update_polyos.sh` (`update-polyos`) | Updater with subcommands |
| `scripts/install-system.sh` | Installs system-level files with backup and rollback |
| `scripts/check.sh`, `scripts/audit.sh` | Static checks and repo audit |
| `systemd/`, `scripts/startup/` | System-level files, see `docs/system-files.md` |
| `.config/` | Per-application user config |

## Package roles and hosts

Roles: `common`, `desktop`, `dev`, `laptop`, `optional`, `aur`. A package belongs
to exactly one file. `hosts/<hostname>.conf` is plain shell:

```sh
ROLES="common desktop dev optional"
CRT_OUTPUT="DVI-0"            # optional, used by .xinitrc and polybar
CRT_MODE_NAME="320x240_60.00"
CRT_MODELINE="6.08 320 328 360 400 240 243 247 253 -HSync +VSync"
```

Unknown hostnames fall back to `hosts/default.conf` (`common desktop`).

## Updater

```
update-polyos <sync|packages|aur|system-config|upgrade|all> [--roles a,b] [--dry-run] [--yes]
```

| Command | Action |
| --- | --- |
| `sync` | `git pull --ff-only` of the dotfiles |
| `packages` | `pacman -S --needed` for this host's roles |
| `aur` | `yay -S --needed` from `packages/aur.txt` (skipped without `yay`) |
| `system-config` | `scripts/install-system.sh` |
| `upgrade` | `pacman -Syu` |
| `all` | `sync`, `upgrade`, `packages`, `aur` (used by the polybar/rofi menus) |

Run it as your normal user; it uses `sudo` for pacman. Use `--dry-run` first.

## Checks

```sh
scripts/check.sh            # syntax, shellcheck, packages, hosts, i3, systemd
scripts/check.sh --online   # also check package names with pacman -Sl
scripts/audit.sh            # keys, tokens, caches, large files in tracked files
```

GitHub Actions runs both on every push. `shellcheck`, `i3` and
`systemd-analyze` are skipped locally when missing but required in CI.
