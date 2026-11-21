# Plan and decisions

## Facts (checked 2026-11-21)
- Display manager: plasma-login-manager (`plasmalogin.service`), not SDDM. It lists sessions from /usr/share/wayland-sessions.
- GPU: AMD Phoenix1 iGPU. No dGPU, so local LLM size is bounded by shared memory.
- Repo versions: hyprland 0.57.2, waybar 0.16.0, mako 1.11.0, uwsm 0.27.2, walker 2.17.2, dolt 2.7.3 (upstream 2.7.6).
- beads latest is 1.3.4 (AUR `beads-bin`). `bd` and `dolt` were not installed before this work.
- `elephant` (Walker 2.x backend) is AUR-only; use `elephant-all-bin` (core + providers). fuzzel is the default launcher.

- Hyprland 0.57 uses a Lua config (`hyprland.lua`), not `hyprland.conf`. Config lives in `config/hypr/` and is symlinked to `~/.config/hypr`.
- `elephant-all-bin` installed (verified).

## Decisions
- Do not run the Omarchy installer; it assumes a fresh Arch install. Copy ideas, not the script.
- Hyprland is an additional session; Plasma is the fallback.
- Official repos first; AUR only in scripts the user runs and reviews.
- Config files get tracked in a dotfiles repo (see beads).
