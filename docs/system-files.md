# System files

Most dotfiles live in `$HOME`. These files are installed outside it and need root.

| Source (in `$HOME`) | Installed to | Owner |
| --- | --- | --- |
| `ascii-art/polyOS/caligraphy.txt` | `/usr/local/share/ascii-art/boot.txt` | `install-system.sh` |
| `ascii-art/gecko.txt` | `/usr/local/share/ascii-art/login.txt` | `install-system.sh` |
| `scripts/startup/formatted-issue` | `/usr/local/share/formatted-issue` | `install-system.sh` |
| `scripts/startup/startup.sh`, `boot-animation` | `/usr/local/bin/` | `install-system.sh` |
| `scripts/justify.sh` | `/usr/local/bin/justify.sh` | `install-system.sh` |
| `systemd/startup.service` | `/etc/systemd/system/` | `install-system.sh` |
| `systemd/getty@tty1.service.d/override.conf` | `/etc/systemd/system/getty@tty1.service.d/` | `install-system.sh` |
| `systemd/ark-*.service`, `ark-backup.timer` | `/etc/systemd/system/` | Manual, ARK host only (`systemd/ark-server.md`) |
| `.config/grub/update_grub.sh` | `/etc/default/grub` | Manual, GPD and ATX hosts |
| `fonts/scientifica/psf/push_font.sh` | Console font | `scripts/startup/push-animation.sh` |

## Install

```sh
scripts/install-system.sh --dry-run    # show diffs only
scripts/install-system.sh              # install, back up what is replaced
scripts/install-system.sh --enable     # also daemon-reload and enable services
```

`scripts/startup/push-animation.sh` runs the install with `--enable` and then
pushes the console font.

## Rollback

Each install that changes something saves the replaced files and a manifest in
`~/.local/state/polyos/system-backups/<timestamp>/`.

```sh
scripts/install-system.sh --rollback              # newest backup
scripts/install-system.sh --rollback 20260101-120000
scripts/install-system.sh --rollback --dry-run    # preview
```

Rollback restores replaced files and removes files the install created. It does
not disable services; use `systemctl disable` if needed.
