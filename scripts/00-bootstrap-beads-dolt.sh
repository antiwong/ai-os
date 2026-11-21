#!/usr/bin/env bash
# Step 0: install dolt (official repo) and beads (AUR binary) so tasks can be tracked.
# Neither was installed on this machine, so this is an install, not an upgrade.
set -euo pipefail
[ "$EUID" -ne 0 ] || { echo "Run as your user, not root (paru refuses root)."; exit 1; }

echo "==> dolt (extra repo)"
# -Syu (not -S): a stale sync db 404s on replaced builds, and -Sy alone risks partial upgrades.
sudo pacman -Syu --needed dolt

echo "==> beads-bin (AUR, prebuilt release binary)"
echo "    AUR PKGBUILDs run external code. Review it when paru offers to."
paru -S --needed beads-bin

echo "==> versions"
dolt version
bd version
