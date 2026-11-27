# ai-os on Ubuntu 26.04 (desktop)

The same repo runs on an Ubuntu 26.04 desktop: Ryzen 7 5800X, NVIDIA GTX 1080 on the
proprietary driver (nvidia-driver-580), two 4K monitors (DP-2, HDMI-A-1), ext4 root, GNOME kept as the fallback session.

## Setup

1. `scripts/00-bootstrap-beads-dolt.sh` - only checks: `bd` and `dolt` are not packaged; install them from their release pages.
2. `scripts/01-install-hyprland.sh` - picks the apt package list (Hyprland 0.53.3 from the Ubuntu archive).
3. `scripts/03-verify.sh`
4. `scripts/05-link-dotfiles.sh`, then `ai-os-theme catppuccin-mocha` and `ai-os-mcp claude`.
5. `ai-os-sandbox build` (podman is in the package list) if you want the agent sandbox.
6. Log out, choose **Hyprland (uwsm-managed)** in GDM. The plain **Hyprland** session also works (Hyprland adds
   `~/.local/bin` to `PATH` itself), but it skips `config/uwsm/env-hyprland`, so the Qt theme variable is not set.

## Differences from the CachyOS laptop

- **Config format**: Hyprland 0.53 reads hyprlang, so `config/hypr/*.conf` replaced the Lua modules. Logic that
  needs a shell (NVIDIA vars, `DOCKER_HOST`, Qt platform theme) lives in `config/uwsm/env-hyprland`.
- **Containers**: this desktop also runs a docker daemon. `DOCKER_HOST` points at the podman socket only when
  that socket exists (`systemctl --user enable --now podman.socket`); otherwise docker tools keep using docker.
- **Snapshots**: the root is ext4, so there is no snapper. `ai-os-update` takes a timeshift (rsync) snapshot of
  the system before `apt full-upgrade` and keeps the two newest. Snapshots hold the OS only, not `/home`, and live
  in `/timeshift` on the same disk, so they do not protect against disk failure. Rollback steps are in
  [updates.md](updates.md). `scripts/04-setup-snapper.sh` does not apply.
- **GPU**: GTX 1080 on `nvidia-driver-580` (`nvidia_drm.modeset=1`, the nvidia suspend/resume units enabled).
  The NVIDIA Wayland variables are set in `config/uwsm/env-hyprland`, so they apply only in the uwsm-managed
  session. Full effects (blur, shadows) are on.
  Until late November 2026 this machine had a GTX TITAN Black (Kepler) on nouveau; that path is still supported: the
  install script adds `nouveau-reclock.service` (lifts the card from boot clocks, experimental) and `ai-os-power`
  turns blur, shadows and inactive translucency off while nouveau is loaded. Kepler cards cannot use the
  proprietary driver: support ended with the 470 series.
- **Not packaged** (skipped): hyprsunset, satty (screenshots annotate with swappy), wiremix (volume click opens
  pavucontrol), bluetui (the Bluetooth pill opens blueman-manager), mise, lazydocker, walker. Install them from upstream if wanted.
- **Suspend**: hypridle never suspends a machine without a battery. Manual suspend (system menu) has not been
  tried on this machine yet. The menu hides **Suspend** while nouveau is loaded, because nouveau on older cards
  can resume to a black screen.
- **Shared settings with GNOME**: `ai-os-theme` changes GTK colour scheme and theme only when run inside Hyprland,
  because gsettings are shared with the GNOME session.
- **Laptop-only pieces** (`ai-os-panel`, battery mode, trackpad gestures, brightness keys) do nothing here.

## Status

Verified in a real login session (plain Hyprland session from GDM) on both 4K screens: config parses with no
errors, theme colours and wallpaper load, waybar renders with the theme CSS, the display
watcher runs and reconnects, the sandbox image builds and runs. `scripts/03-verify.sh` reports the same checks.
Monitor removal and return was tested by disabling and re-enabling an output; hyprlock locks, reaches the password
prompt and unlocks by signal. Not yet verified: a physical cable unplug/replug, typing the password at the lock
screen, a login through the uwsm-managed session. Suspend/resume has not been tried.

`scripts/06-manual-checks.sh` walks through these hands-on checks (lock screen, suspend/resume, config check, pull
request), asks before each one and logs the results to `~/.local/state/ai-os/manual-checks.log`.
