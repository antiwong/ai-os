#!/usr/bin/env bash
# Step 0: install dolt (official repo) and beads (AUR binary) so tasks can be tracked.
# Neither was installed on this machine, so this is an install, not an upgrade.
set -euo pipefail
[ "$EUID" -ne 0 ] || { echo "Run as your user, not root (paru refuses root)."; exit 1; }

if ! command -v pacman >/dev/null; then
  # Ubuntu/Debian: neither is packaged. Use the upstream release installers (they install to ~/.local/bin or /usr/local/bin).
  command -v dolt >/dev/null || { echo "dolt missing: see https://docs.dolthub.com/introduction/installation/linux"; exit 1; }
  command -v bd   >/dev/null || { echo "bd missing: see https://github.com/gastownhall/beads#installation"; exit 1; }
  dolt version; bd version; exit 0
fi

echo "==> dolt (extra repo)"
# -Syu (not -S): a stale sync db 404s on replaced builds, and -Sy alone risks partial upgrades.
sudo pacman -Syu --needed dolt

echo "==> beads-bin (AUR, prebuilt release binary)"
echo "    AUR PKGBUILDs run external code. Review it when paru offers to."
paru -S --needed beads-bin

echo "==> versions"
dolt version
bd version
