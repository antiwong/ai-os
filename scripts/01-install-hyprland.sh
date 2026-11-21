#!/usr/bin/env bash
# Step 1: install the Hyprland desktop stack from official/CachyOS repos only.
# Plasma stays installed; Hyprland shows up as an extra session at the login screen.
set -euo pipefail
[ "$EUID" -ne 0 ] || { echo "Run as your user, not root."; exit 1; }

PKGS=(
  # compositor + session
  hyprland uwsm hyprland-guiutils
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpolkitagent
  qt5-wayland qt6-wayland
  # hypr ecosystem
  hyprlock hypridle hyprpaper hyprpicker hyprsunset
  # bar, launcher, notifications, OSD
  waybar fuzzel mako swayosd
  # screenshots, clipboard
  grim slurp hyprshot satty wl-clipboard cliphist wf-recorder
  # system controls
  brightnessctl playerctl pamixer wiremix bluetui network-manager-applet
  # theming, fonts, viewers
  nwg-look ttf-jetbrains-mono-nerd imv
)

# Safety net: snapshot first if snapper is configured (non-fatal if not).
if command -v snapper >/dev/null && sudo snapper list-configs 2>/dev/null | grep -q root; then
  echo "==> snapper snapshot"
  sudo snapper -c root create -d "pre-hyprland-install"
else
  echo "==> snapper not configured for root; skipping snapshot (see bead for snapshot setup)"
fi

echo "==> installing ${#PKGS[@]} packages"
sudo pacman -S --needed "${PKGS[@]}"

echo "==> done. Run scripts/03-verify.sh, then log out and pick 'Hyprland (uwsm-managed)' in the session menu."
