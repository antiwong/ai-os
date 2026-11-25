# ai-os on Ubuntu 26.04 (desktop)

The same repo runs on an Ubuntu 26.04 desktop: Ryzen 7 5800X, NVIDIA GTX TITAN Black (Kepler) on the
open nouveau driver, two 4K monitors (DP-1, HDMI-A-1), ext4 root, GNOME kept as the fallback session.

## Setup

1. `scripts/00-bootstrap-beads-dolt.sh` - only checks: `bd` and `dolt` are not packaged; install them from their release pages.
2. `scripts/01-install-hyprland.sh` - picks the apt package list (Hyprland 0.53.3 from the Ubuntu archive).
3. `scripts/03-verify.sh`
4. `scripts/05-link-dotfiles.sh`, then `ai-os-theme catppuccin-mocha`.
5. Log out, choose **Hyprland (uwsm-managed)** in GDM.

## Differences from the CachyOS laptop

- **Config format**: Hyprland 0.53 reads hyprlang, so `config/hypr/*.conf` replaced the Lua modules. Logic that
  needs a shell (NVIDIA vars, `DOCKER_HOST`, Qt platform theme) lives in `config/uwsm/env-hyprland`.
- **No snapshots**: the root is ext4, so there is no snapper. `ai-os-update` says so and continues with
  `apt full-upgrade`; take a backup before risky changes. `scripts/04-setup-snapper.sh` does not apply.
- **GPU**: nouveau cannot reclock Kepler cards, so the GPU runs at boot clocks. `ai-os-power` turns blur off
  when nouveau is loaded (`~/.config/ai-os/power.conf`). Do not install the NVIDIA proprietary driver for this
  card: Kepler support ended with the 470 series, which does not work with current kernels and Wayland compositors.
- **Not packaged** (skipped): hyprsunset, satty (screenshots annotate with swappy), wiremix (volume click opens
  pavucontrol), bluetui, mise, lazydocker, walker. Install them from upstream if wanted.
- **Shared settings with GNOME**: `ai-os-theme` changes GTK colour scheme and theme only when run inside Hyprland,
  because gsettings are shared with the GNOME session.
- **Laptop-only pieces** (`ai-os-panel`, battery mode, trackpad gestures, brightness keys) do nothing here.

## Status

Verified by running Hyprland nested inside GNOME: config parses with no errors, theme colours and wallpaper load,
waybar renders with the theme CSS, blur is off on nouveau, `ai-os-shot` captures. Not yet verified: a real login
into the Hyprland session on the two 4K screens, monitor hotplug events, hyprlock, suspend/resume on nouveau.
