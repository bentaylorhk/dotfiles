<!--
Benjamin Michael Taylor (bentaylorhk)
2026
-->

# polyOS improvement backlog

Items here are proposals, not authorization to change the configuration.

| Status | Improvement | Next step |
| --- | --- | --- |
| pending | Consolidate the duplicate package-updater entry points | Make one updater canonical and retain the other as a compatibility wrapper. |
| pending | Unify the choi-hung visual system | Define shared palette tokens for the terminal, launcher, bar, editor, and X resources. |
| pending | Separate hostname-selected configuration overlays | Extend the package-role model to narrowly cover display, laptop, CRT, WSL, and server configuration. |
| approved | Restore the polymorphism boot-animation integration | Add `boot-animation <art-file>` to polymorphism, then clone/build/install it over SSH and validate it from the desktop startup module. |
| pending | Remove the custom screensaver integration | Delete the `.xscreensaver` entry and its wrappers after the startup work is approved. |
| pending | Modularize polymorphism | Separate exhibition components into selectable boot-animation, screensaver, and other modes; add responsive layouts beyond CRT dimensions. |
| pending | Create an idempotent polyOS system bootstrap | Install approved system-level configuration from a fresh clone by hostname and role, including boot/startup integration. |
| done | Adopt host roles and system setup | Use hosts/<hostname>.conf and the checked system installer; keep ARK setup manual. |
| approved | Add role-aware display setup | Keep autorandr runtime-driven, gate CRT mode on role plus DVI output, and calibrate laptop typography before applying a scaling overlay. |
| approved | Add safe role-aware GRUB setup | Install/configure GRUB on all mapped desktops, use dual-boot roles for os-prober, and defer BIOS hosts until an explicit disk is registered. |
| approved | Add desktop networking and SSH access | Enable NetworkManager on desktops and harden SSH only on polyphonic-1 with key preflight; ssh-polyos is already available. |
| approved | Simplify shell bootstrap | Retain ~/scripts and current tty1 X startup, remove the stale ~/bin PATH entry, and preserve prompts/aliases. |
| pending | Audit shell prompt and aliases | Review shell ergonomics and cleanup separately from bootstrap behavior. |
| done | Add role-scoped AUR management | Track scientifica-font, cbonsai, and spicetify-cli for base desktop plus steamcmd for server; rebuild cached clones when their source commit changes. |
