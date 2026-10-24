<!-- Benjamin Michael Taylor (bentaylorhk) -->
<!-- 2026 -->

# ARK: Survival Evolved server

`ark-server.service` runs TheIsland (`SessionName=Green Out Land`) at boot, with
no login needed. `ConditionHost=polyphonic-1` stops it starting elsewhere.
Game files, saves and `GameUserSettings.ini` / `Game.ini` live in `/srv/ark-se`,
not in this repo. Keep passwords out of Git.

## Setup (run on polyphonic-1)

1. Enable multilib: uncomment `[multilib]` and its `Include` line in
   `/etc/pacman.conf`, then `sudo pacman -Syu`.
2. Install build tools and steamcmd from the AUR:
   ```sh
   sudo pacman -S --needed base-devel git
   ~/scripts/aur.sh steamcmd
   ```
3. Put the public key of the machine you will SSH from in
   `~/.ssh/authorized_keys` (paste it locally; sshd is not up yet).
4. Run `sudo ~/scripts/ark/setup.sh`. It installs ufw, creates the `ark`
   user, installs the server (SteamCMD app 376030), sets `vm.max_map_count`,
   hardens and enables SSH, configures the firewall, and enables
   `ark-server.service`. It refuses to run until `authorized_keys` is
   non-empty, to avoid locking you out.
5. On the router, reserve 192.168.1.146 for this PC and forward UDP 7777,
   7778 and 27015 to it. Do not forward TCP 22.

Check with `systemctl status ark-server`, `journalctl -u ark-server -f` and
`ss -ulnp`. Stop the server before editing config in
`/srv/ark-se/ShooterGame/Saved/Config/LinuxServer/` (ARK rewrites it on exit),
then `sudo systemctl start ark-server`.

## Backups and config repo

`ark-backup.timer` (installed by `scripts/ark/install-backup.sh`, also run by
`setup.sh`) archives `SavedArks` and `Config` nightly at 04:00 to
`/srv/ark-backups` (7 daily, 4 weekly). To also copy them off this disk, create
`/etc/default/ark-backup` with `ARK_BACKUP_RSYNC_TARGET=user@host:/path/`.
Run `sudo systemctl start ark-backup` for an immediate backup.

Sanitised config is tracked in the separate `~/repos/ark-server` repo.
Refresh it with `~/scripts/ark/sync-config.sh` (no sudo; needs the `ark` group),
then deploy with `~/scripts/ark/deploy-config.sh`. Deployment stops the server,
backs up its saves/config, preserves live passwords, and starts it again.
The service checks SteamCMD for updates on each start. After changing the
tracked service unit, install it once with `sudo ~/scripts/ark/install-service.sh`.

## Agent / non-root access

So `ben` (and tools running as `ben`) can manage the server without a password:

- `sudo usermod -aG ark ben` and `UMask=0007` in a `systemctl edit ark-server`
  drop-in make the files under `/srv/ark-se/ShooterGame/Saved` group-writable.
- `sudo usermod -aG systemd-journal ben` allows `journalctl -u ark-server`.
- `/etc/sudoers.d/ark` allows passwordless `systemctl start|stop|restart|status`
  and `reset-failed` for `ark-server`, plus `start ark-backup`.

Everything here only runs on `polyphonic-1`: the units use `ConditionHost` and
the scripts check `/etc/hostname`.

For a small private server, keeping this deployment note and the host-specific
systemd unit here is enough. If server configuration or update scripts grow,
put those in a separate `ark-server` repository; track only configs and
deployment code there, never the installed game files or world saves.

## SSH access (LAN only)

The setup script writes `/etc/ssh/sshd_config.d/10-hardening.conf` (keys only,
no root login) and ufw allows port 22 only from `192.168.1.0/24`. Connect with
`ssh ben@192.168.1.146`; run long tools inside `tmux`.
