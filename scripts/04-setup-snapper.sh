#!/usr/bin/env bash
# Step 4: finish the snapper setup. Idempotent; safe to rerun.
# Already present on this machine: snapper, snap-pac (pre/post snapshot on every pacman run),
# limine-snapper-sync (adds snapshots to the Limine boot menu), btrfs-assistant, a 'root' config.
# Gaps this script closes:
#   - timeline snapshots were off (TIMELINE_CREATE=no)
#   - /home (@home subvolume) had no config, so ~/code, dotfiles and agent work were unprotected
#   - your user could not list snapshots without sudo
#   - no named baseline snapshot before the Hyprland work
set -euo pipefail
[ "$EUID" -ne 0 ] || { echo "Run as your user, not root."; exit 1; }
ME="$USER"

echo "==> root config: timeline on, user access"
sudo snapper -c root set-config \
  TIMELINE_CREATE=yes TIMELINE_LIMIT_HOURLY=5 TIMELINE_LIMIT_DAILY=7 \
  TIMELINE_LIMIT_WEEKLY=2 TIMELINE_LIMIT_MONTHLY=0 TIMELINE_LIMIT_YEARLY=0 \
  ALLOW_USERS="$ME" SYNC_ACL=yes

echo "==> home config"
if ! sudo snapper list-configs | grep -qE '^home\b'; then
  sudo snapper -c home create-config /home
fi
sudo snapper -c home set-config \
  TIMELINE_CREATE=yes TIMELINE_LIMIT_HOURLY=5 TIMELINE_LIMIT_DAILY=7 \
  TIMELINE_LIMIT_WEEKLY=2 TIMELINE_LIMIT_MONTHLY=0 TIMELINE_LIMIT_YEARLY=0 \
  ALLOW_USERS="$ME" SYNC_ACL=yes

echo "==> timers"
sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

echo "==> baseline snapshots"
sudo snapper -c root create -c number -d "baseline: before Hyprland work"
sudo snapper -c home create -c number -d "baseline: before Hyprland work"

echo "==> state"
snapper list-configs
snapper -c root list | tail -5
snapper -c home list | tail -5
systemctl is-enabled snapper-timeline.timer snapper-cleanup.timer
