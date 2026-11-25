#!/bin/bash
# Symlink tracked configs/scripts from this repo into $HOME. Idempotent.
# Existing real files are moved to <name>.bak.<timestamp>, never deleted.
# Usage: scripts/05-link-dotfiles.sh [--dry-run]
set -eu
ROOT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
C="$HOME/.config"
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1

# "repo path (relative to repo)|destination"
LINKS=(
  "config/hypr|$C/hypr"
  "config/waybar|$C/waybar"
  "config/mako|$C/mako"
  "config/fuzzel|$C/fuzzel"
  "config/tmux/tmux.conf|$C/tmux/tmux.conf"
  "config/swayosd/config.toml|$C/swayosd/config.toml"
  "config/bbl/pretty.awk|$C/bbl/pretty.awk"
  "config/flags/electron.conf|$C/chrome-flags.conf"
  "config/flags/electron.conf|$C/code-flags.conf"
  "config/systemd/user/ollama.service|$C/systemd/user/ollama.service"
  "config/mise/config.toml|$C/mise/config.toml"
  "config/uwsm/env-hyprland|$C/uwsm/env-hyprland"
  "config/applications/ai-os-display.desktop|$HOME/.local/share/applications/ai-os-display.desktop"
  "config/ghostty/config.ghostty|$C/ghostty/config.ghostty"
  "config/ghostty/frame.css|$C/ghostty/frame.css"
  "config/nvim/init.lua|$C/nvim/init.lua"
  "config/nvim/lazy-lock.json|$C/nvim/lazy-lock.json"
  "config/fish/config.fish|$C/fish/config.fish"
  "config/fish/conf.d/ghostty_pane_tint.fish|$C/fish/conf.d/ghostty_pane_tint.fish"
)
for f in "$ROOT"/config/fish/functions/*.fish; do
  LINKS+=("config/fish/functions/$(basename "$f")|$C/fish/functions/$(basename "$f")")
done
for f in "$ROOT"/scripts/ai-os-*; do
  LINKS+=("scripts/$(basename "$f")|$HOME/.local/bin/$(basename "$f")")
done

n_ok=0; n_new=0
for entry in "${LINKS[@]}"; do
  src="$ROOT/${entry%%|*}"; dest="${entry##*|}"
  [ -e "$src" ] || { echo "MISSING in repo: $src" >&2; continue; }
  if [ "$(readlink "$dest" 2>/dev/null)" = "$src" ]; then n_ok=$((n_ok+1)); continue; fi
  echo "link $dest -> $src"
  [ "$DRY" = 1 ] && continue
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] || [ -L "$dest" ]; then mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"; fi
  ln -s "$src" "$dest"; n_new=$((n_new+1))
done
# Generated files that Hyprland/hyprlock source. hyprlang treats a missing source file as an error,
# so seed them empty; ai-os-theme, ai-os-display and ai-os-power fill them in.
for f in ai-os/power.conf ai-os/monitors.conf ai-os/theme/hypr.conf ai-os/theme/hyprlock.conf; do
  [ -e "$C/$f" ] && continue
  echo "seed $C/$f"; [ "$DRY" = 1 ] && continue
  mkdir -p "$(dirname "$C/$f")"; : > "$C/$f"
done
echo "done: $n_ok already linked, $n_new newly linked$([ "$DRY" = 1 ] && echo " (dry run)")"
