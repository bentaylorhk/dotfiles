<!--
Benjamin Michael Taylor (bentaylorhk)
2026
-->

# Dotfiles agent guide

This repository uses a bare Git directory at `~/.dotfiles` and `$HOME` as its
worktree. Always run Git commands with:

```sh
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" <command>
```

It configures Arch Linux installations collectively named **polyOS**.

## External components

- The boot animation belongs to `~/repos/polymorphism`; do not vendor its
  source or binary into this repository.
- Treat the dotfiles startup integration as a consumer of a separately
  installed polymorphism boot-animation command.

## Machine roles

- The common base is the shared desktop experience used by every non-WSL
  polyOS host, including `polyphonic-1`.
- WSL is the current exception and must use its own explicit profile.
- `polyos/hosts.conf` is the authoritative hostname-to-role registry for
  machine-specific packages and behavior; never infer a role from hardware.
- Keep each role overlay narrow. Use separate overlays for desktop, laptop,
  CRT, WSL, and server needs.
- `polyos/ssh-hosts.conf` holds non-sensitive SSH connection targets for the
  `ssh-polyos` helper; never put keys or credentials there.

## Working safely

- Treat every tracked file as a portable dotfile shared between machines.
- Check status before editing and preserve unrelated local changes.
- Keep host-specific paths, credentials, tokens, private keys, and machine
  state untracked.
- Prefer existing scripts and configuration conventions over adding new tooling.
- Do not recursively delete from `$HOME`; limit changes to the requested,
  tracked configuration files.

## Personal file headers

For new personal scripts and configuration files that support comments, add a
language-appropriate header after any required interpreter or format preamble:

```text
Benjamin Michael Taylor (bentaylorhk)
YYYY
```

Use the current year (`2026`) for new files. When materially updating an
existing personal file, retain its existing header style and update its
inclusive year range when appropriate.

## Commits

Use a very short, lowercase subject with no body or trailers.

## Improvement backlog

Track deferred polyOS improvements in `POLYOS_TODO.md`. When asked for
recommendations, review it and propose one item at a time; do not implement an
item until its scope has been explicitly approved.

## AUR packages

- Track AUR package names in role-specific manifests.
- Use cached clones in `~/aur`, update them with `git pull --ff-only`, and
  rebuild them with `makepkg` only when their source commit changes.
- Build as the invoking non-root user and allow missing build dependencies to
  use the bootstrap's existing sudo session.
- When working on a new polyOS host, compare `pacman -Qm` with the AUR
  manifests and propose untracked packages one at a time.

## Validation

- Validate the changed file with its native tool when one is available.
- For shell scripts, run `bash -n <file>`.
- For JSON files, run `jq empty <file>`.
- For TOML files, use an installed parser or the relevant application's
  validation command.
