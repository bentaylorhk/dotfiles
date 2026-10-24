#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2025-2026

# Installs the polyOS startup animation and tty1 login banner, plus the
# console font. The file copying lives in scripts/install-system.sh.

set -euo pipefail

"$HOME/scripts/install-system.sh" --enable "$@"
"$HOME/fonts/scientifica/psf/push_font.sh"
echo "Installed. Reboot polyOS to re-run the startup banner before tty1 login."
