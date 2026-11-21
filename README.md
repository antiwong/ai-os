# ai-os

Turning this CachyOS machine (Plasma 6, Wayland) into an Omarchy-style, AI-first workstation:
Hyprland next to Plasma, keyboard-driven, themed as one system, with agents and local models wired in.

Task tracking lives in beads (`bd ready`, `bd list`). Design notes are in `docs/`.

## Run order
1. `scripts/00-bootstrap-beads-dolt.sh`  - dolt + beads
2. `scripts/seed-beads.sh`               - create epics/tasks (Claude runs this)
3. `scripts/01-install-hyprland.sh`      - Hyprland stack (official repos)
4. `scripts/03-verify.sh`                - read-only check
5. `scripts/02-install-aur-extras.sh`    - optional Walker + elephant (AUR)

Log out and pick the Hyprland session at the login screen. Plasma remains as fallback.
