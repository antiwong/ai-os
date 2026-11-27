#!/usr/bin/env bash
# Read-only check of what is installed, which sessions the login manager offers, and (inside Hyprland)
# whether the session pieces are running. Prints ok / MISSING / optional lines; changes nothing.
for c in Hyprland uwsm waybar fuzzel mako swayosd-server hyprlock hypridle hyprpaper grim slurp cliphist jq socat fish \
         ghostty tmux nvim wl-copy notify-send playerctl powerprofilesctl podman dolt bd; do
  if command -v "$c" >/dev/null; then printf 'ok       %s\n' "$c"; else printf 'MISSING  %s\n' "$c"; fi
done
echo "--- one of each"
any() { # any <label> <cmd>...
  local l="$1" c; shift
  for c in "$@"; do command -v "$c" >/dev/null && { printf 'ok       %s (%s)\n' "$l" "$c"; return; }; done
  printf 'MISSING  %s (none of: %s)\n' "$l" "$*"
}
any "screenshot annotate" satty swappy
any "bluetooth manager" bluetui blueman-manager
any "volume mixer" wiremix pavucontrol
echo "--- optional"
for c in lazydocker lazygit btop mise hyprsunset whisper-cli snapper timeshift claude; do
  if command -v "$c" >/dev/null; then printf 'ok       %s\n' "$c"; else printf 'optional %s (not installed)\n' "$c"; fi
done
echo "--- fonts and services"
if fc-list 2>/dev/null | grep -qi 'nerd'; then echo "ok       Nerd Font"; else echo "MISSING  Nerd Font (bar and prompt icons)"; fi
if [ "$(systemctl is-enabled bluetooth.service 2>/dev/null)" = enabled ]; then echo "ok       bluetooth.service enabled"; else echo "MISSING  bluetooth.service not enabled"; fi
if [ -d /sys/module/nouveau ]; then
  if [ "$(systemctl is-enabled nouveau-reclock.service 2>/dev/null)" = enabled ]; then echo "ok       nouveau-reclock.service enabled"; else echo "MISSING  nouveau-reclock.service (GPU stays at boot clocks)"; fi
fi
for b in ai-os-menu ai-os-display ai-os-theme; do
  if [ -x "$HOME/.local/bin/$b" ]; then printf 'ok       %s linked\n' "$b"; else printf 'MISSING  %s in ~/.local/bin (run scripts/05-link-dotfiles.sh)\n' "$b"; fi
done
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  echo "--- running session"
  for p in waybar mako hypridle hyprpaper swayosd-server; do
    if pgrep -x "$p" >/dev/null; then printf 'ok       %s running\n' "$p"; else printf 'MISSING  %s not running\n' "$p"; fi
  done
  if pgrep -f 'ai-os-display watch' >/dev/null; then echo "ok       ai-os-display watch running"; else echo "MISSING  ai-os-display watch not running (monitor hotplug is not handled)"; fi
  errs="$(hyprctl configerrors 2>/dev/null | grep -c .)"
  if [ "$errs" = 0 ]; then echo "ok       Hyprland config has no errors"; else echo "MISSING  Hyprland config errors: run hyprctl configerrors"; fi
fi
echo "--- wayland sessions"
ls /usr/share/wayland-sessions
echo "--- versions"
Hyprland --version 2>/dev/null | head -1
dolt version 2>/dev/null | head -1
bd version 2>/dev/null | head -1
