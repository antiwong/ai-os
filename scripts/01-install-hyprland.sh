#!/usr/bin/env bash
# Step 1: install the Hyprland desktop stack from the distro's official repos only.
# CachyOS/Arch (pacman) or Ubuntu 26.04+ (apt). The existing desktop (Plasma or GNOME) stays installed;
# Hyprland shows up as an extra session at the login screen.
set -euo pipefail
[ "$EUID" -ne 0 ] || { echo "Run as your user, not root."; exit 1; }

if command -v pacman >/dev/null; then
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
    grim slurp satty wl-clipboard cliphist wf-recorder
    # system controls
    brightnessctl playerctl pamixer wiremix bluetui network-manager-applet
    # theming, fonts, viewers
    nwg-look ttf-jetbrains-mono-nerd imv
    # used by ai-os-* scripts
    jq socat imagemagick fish tmux wtype libnotify
  )
else
  # Ubuntu 26.04 names. Not packaged there: hyprsunset, satty (swappy is used instead), wiremix, bluetui,
  # mise, lazydocker, a Nerd Font (install JetBrainsMono Nerd Font into ~/.local/share/fonts).
  PKGS=(
    hyprland uwsm hyprland-qtutils
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpolkitagent
    qtwayland5 qt6-wayland qt5-gtk-platformtheme qt6-gtk-platformtheme
    hyprlock hypridle hyprpaper hyprpicker
    waybar fuzzel mako-notifier swayosd
    grim slurp swappy wl-clipboard cliphist wf-recorder
    brightnessctl playerctl pamixer pavucontrol network-manager-gnome power-profiles-daemon
    nwg-look imv
    jq socat imagemagick fish tmux wtype libnotify-bin lazygit btop
  )
fi

# Safety net: snapshot first if snapper is configured (non-fatal if not).
if command -v snapper >/dev/null && sudo snapper list-configs 2>/dev/null | grep -q root; then
  echo "==> snapper snapshot"
  sudo snapper -c root create -d "pre-hyprland-install"
else
  echo "==> snapper not configured for root; skipping snapshot"
fi

echo "==> installing ${#PKGS[@]} packages"
if command -v pacman >/dev/null; then
  sudo pacman -S --needed "${PKGS[@]}"
else
  sudo apt-get update
  sudo apt-get install -y "${PKGS[@]}"
  # Ubuntu's waybar and mako packages enable user units on graphical-session.target, which uwsm
  # reaches. Hyprland autostart.conf already execs both, so mask the units to avoid a second bar.
  systemctl --user mask waybar.service mako.service
fi

echo "==> done. Run scripts/03-verify.sh, then log out and pick 'Hyprland (uwsm-managed)' in the session menu."
