#!/usr/bin/env bash
# Read-only check of what is installed and which sessions the login manager will offer.
for c in Hyprland uwsm waybar fuzzel mako swayosd-server hyprlock hypridle hyprpaper grim slurp cliphist jq socat fish dolt bd; do
  if command -v "$c" >/dev/null; then printf 'ok      %s\n' "$c"; else printf 'MISSING %s\n' "$c"; fi
done
echo "--- wayland sessions"
ls /usr/share/wayland-sessions
echo "--- versions"
Hyprland --version 2>/dev/null | head -1
dolt version 2>/dev/null | head -1
bd version 2>/dev/null | head -1
