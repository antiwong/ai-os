# ai-os

Turning this CachyOS machine (Plasma 6, Wayland) into an Omarchy-style, AI-first workstation:
Hyprland next to Plasma, keyboard-driven, themed as one system, with agents and local models wired in.

Task tracking lives in beads (`bd ready`, `bd list`). Start with `docs/ai-os-transformation.md` (what was built and why).
Other docs: `plan.md` (decisions), `updates.md` (update + rollback), `sandbox.md` (agent sandbox), `local-models.md` (Ollama).

## Commands (installed to ~/.local/bin)
`ai-os-theme` theme switcher · `ai-os-update` update routine · `ai-os-agent`/`ai-os-agents` worktree agents · `ai-os-sandbox` containerised agent · `ai-os-claude` scratchpad · `ai-os-shot[-agent]` screenshots · `ai-os-dictate` voice typing · `ai-os-mcp` shared MCP servers · `ai-os-note` Obsidian quick capture · `ai-os-menu` system menu · `ai-os-popup` TUI popups

## Run order
1. `scripts/00-bootstrap-beads-dolt.sh`  - dolt + beads
2. `scripts/seed-beads.sh`               - create epics/tasks (Claude runs this)
3. `scripts/01-install-hyprland.sh`      - Hyprland stack (official repos)
4. `scripts/03-verify.sh`                - read-only check
   `scripts/04-setup-snapper.sh`         - finish snapper (timeline, /home config, user access)
5. `scripts/02-install-aur-extras.sh`    - optional Walker + elephant (AUR)
6. `scripts/05-link-dotfiles.sh`         - symlink tracked configs and scripts into ~/.config and ~/.local/bin
   (idempotent; `--dry-run` to preview; existing files are kept as `.bak.<timestamp>`)

Then `ai-os-theme catppuccin-mocha` and `ai-os-mcp claude`. Log out and pick the Hyprland session at the login screen. Plasma remains as fallback.

## Dotfiles
This repo is the dotfiles repo: `config/` and `scripts/` are symlinked into `$HOME` by
`scripts/05-link-dotfiles.sh` (add new files to its `LINKS` list). Edit files here, not in
`~/.config`. Generated files (`~/.config/ai-os/theme/`, btop/lazygit/lazydocker config, wallpapers)
are rebuilt by `ai-os-theme <theme>` and are not tracked. Some tools replace symlinks when they write
(e.g. nvim's `lazy-lock.json`); re-run the link script to restore them.
