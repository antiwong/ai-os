# Turning CachyOS into ai-os

*Status as of 2026-11-22. Source of truth for tasks is beads (`bd list`); source of truth for configuration is this repo.*

## 1. What ai-os is

An Omarchy-style, keyboard-driven Hyprland desktop on the existing CachyOS install, built around AI coding agents. One theme drives the whole desktop, agents run in disposable git worktrees inside tmux, and everything is tracked in git so the machine can be rebuilt from this repo.

It is a layer on top of the machine you already had, not a new distro.

## 2. Starting point and constraints

| | |
|---|---|
| OS | CachyOS (Arch-based), KDE Plasma 6 on Wayland, fish login shell |
| Hardware | Laptop, AMD Phoenix1 iGPU (no dGPU), 1920x1200 panel |
| Login | plasma-login-manager (not SDDM); lists sessions from `/usr/share/wayland-sessions` |
| Existing safety | snapper + snap-pac + limine-snapper-sync, btrfs |

Constraints that shaped the design:
- **Plasma stays as the fallback.** Hyprland is an extra session, selected at the login screen.
- **Don't run the Omarchy installer.** It assumes a fresh Arch install. Ideas were copied, not the script.
- **Official repos first.** AUR packages are installed by you, from commands in scripts you review. `sudo` is never run by the agent.
- **Keep what works.** QGIS stays on flatpak 3.28 LTS; Obsidian, VS Code and Chrome are kept (with Wayland flags).

## 3. Architecture

Four layers, each independent enough to fail without taking down the others.

```
 Safety      snapper (root + home) -> limine boot menu -> ai-os-update, docs/updates.md
 AI work     push-to-talk, local models, Obsidian memory           (planned)
 AI coding   Claude Code scratchpad, agent worktrees, nvim, MCP, lazygit
 Desktop     Hyprland + waybar + fuzzel + mako + swayosd + hyprlock, one theme
 Foundation  this repo (symlinked dotfiles) + beads task tracking
```

### Repo layout
```
config/   hypr waybar mako fuzzel swayosd ghostty tmux nvim fish mcp bbl flags themes
scripts/  00-05 numbered setup scripts, plus the ai-os-* commands
docs/     plan.md (decisions), updates.md (update + rollback), this file
```
`config/` and `scripts/` are symlinked into `~/.config` and `~/.local/bin` by `scripts/05-link-dotfiles.sh`. **Edit files in the repo, not in `~/.config`.** Generated files (theme output, btop/lazygit config, wallpapers) are rebuilt by `ai-os-theme` and are not tracked.

## 4. What was built

### Foundation
- **beads** (`bd`) with a local Dolt database tracks every task; this document describes the closed ones.
- **Dotfiles** are plain symlinks managed by one idempotent script (`--dry-run` supported; existing files are kept as `.bak.<timestamp>`). chezmoi and stow were considered and skipped: neither was installed and the symlink repo already existed.
- **Snapshots**: `root` and `home` both have timeline snapshots; `04-setup-snapper.sh` closed the gaps (home config, user access, timers).

### Desktop (Hyprland 0.57, Lua config)
- Config split into `monitors / input / env / look / binds / rules / autostart`, started through uwsm.
- **Keys** are Omarchy-style: `SUPER+RETURN` terminal, `SUPER+SPACE` launcher, `SUPER+1..0` workspaces, `SUPER+ESCAPE` system menu. Full list in `~/Desktop/ai-os-hotkeys.html`.
- **waybar** with pill-styled status modules; wifi, bluetooth and volume are clickable (floating `nmtui`, `bluetui`, `pavucontrol`).
- **fuzzel** launcher and system menu, **mako** notifications, **swayosd** volume/brightness OSD, **hyprlock/hypridle** lock and idle, **hyprpaper** wallpaper.
- **Screenshots**: hyprshot + satty (annotate) + cliphist (clipboard history).
- **Mixed apps**: GTK and Qt/KDE (Dolphin) follow the theme; Chrome, Code and Obsidian get Wayland flags from one shared file. HiDPI: the laptop panel is pinned to scale 1.0.

### One theme for everything
`ai-os-theme [name]` (or `SUPER+SHIFT+T`) renders templates from `config/themes/templates/` using a small palette file per theme (`catppuccin-mocha` default, `catppuccin-latte`, `gruvbox-dark`, `tokyo-night`) and reloads the apps. Covered: waybar, mako, fuzzel, hyprlock, hypr borders, swayosd, ghostty, tmux, neovim (catppuccin flavour + palette overrides), btop, lazygit, lazydocker, wallpaper, GTK and Qt colour scheme. To add a theme, add `config/themes/<name>/colors.env`.

### AI coding layer
- **Claude Code scratchpad** (`SUPER+C`): a floating Ghostty on a hidden special workspace. First press launches, later presses show/hide; the session keeps running.
- **Screenshot to agent** (`SUPER+SHIFT+A`): capture a region, open the scratchpad, type `@<path>` so you only add the question.
- **Agent worktrees** (`agent <branch>` / `ai-os-agent`): one git worktree and one tmux window per agent, so parallel agents never share a working tree. `ai-os-agents` lays out panes. tmux prefix is `Ctrl+Space`.
- **Neovim**: `claudecode.nvim` (`SPACE a ...`) shares buffers/selections with Claude Code and shows its diffs as nvim diffs.
- **Review tools**: `lazygit` (`SUPER+G`) and `lazydocker` (`SUPER+SHIFT+D`).
- **Shared MCP servers** (`config/mcp/servers.json`, applied with `ai-os-mcp claude`): filesystem (scoped to `~/code`), context7 (library docs), playwright. Secrets are never stored in the repo.

### Safety
- `ai-os-update` (also in the system menu): lists pending updates, takes named root + home snapshots, runs `paru -Syu`, flatpak, re-links dotfiles, then reports reboot needs, `.pacnew` files, orphans and failed units. `docs/updates.md` has the rollback ladder, from one package to a full Limine snapshot boot.

## 5. Daily workflow

1. Open a terminal (`SUPER+RETURN`); tmux gives panes, `prefix+A` makes a main pane plus two agent panes.
2. Start an agent on a branch: `agent feature-x` (its own worktree and tmux window).
3. Need a quick answer without leaving what you are doing: `SUPER+C`.
4. Something looks wrong on screen: `SUPER+SHIFT+A`, select it, ask.
5. Review what agents changed in `lazygit` before merging.
6. Weekly: `SUPER+ESCAPE` -> Update, then merge `.pacnew` files if the report lists any.

## 6. Rebuilding on a fresh install
1. Install CachyOS, enable snapper per `scripts/04-setup-snapper.sh`.
2. `git clone` this repo to `~/code/ai-os`.
3. Run the numbered scripts in order (see `README.md`): beads/dolt, Hyprland stack, verify, optional AUR extras.
4. `scripts/05-link-dotfiles.sh`, then `ai-os-theme catppuccin-mocha`.
5. `ai-os-mcp claude` to restore MCP servers.
6. Not in git: the `bbl` binary and Bible packs, browser profiles, Obsidian vaults, git identity, tokens.

## 7. Known gaps and caveats
- **lazydocker** shows "cannot connect to the Docker daemon" until a container runtime is installed (`ai-os-61m`).
- **mise** (node/python runtimes) is not installed yet (`ai-os-6uj.2`; needs `sudo pacman -S mise`).
- `libxcrypt-compat` was added only because the copied `bbl` binary needs `libcrypt.so.1`.
- Six `.pacnew` files (pacman.conf, resolv.conf, mirrorlists) were waiting for a merge when this was written.
- Some tools replace symlinks when they write (e.g. nvim's `lazy-lock.json`); re-run `05-link-dotfiles.sh` to restore.
- Window rules only apply to windows opened after a reload.
- Several pieces were verified by running them, but not every hotkey was pressed on the real keyboard; see commit messages and bead close reasons for what was and was not tested.

## 8. Roadmap (open beads)
| Bead | Item |
|---|---|
| ai-os-6uj.2 | mise + default node/python |
| ai-os-6uj.7 | Evaluate OpenCode / aider as model-agnostic agents |
| ai-os-6yv.1 | Ollama + local model choice for AMD Phoenix1 (ROCm/Vulkan) |
| ai-os-6yv.3 | Push-to-talk dictation (whisper.cpp) on a hotkey |
| ai-os-6yv.2 | Open WebUI on localhost |
| ai-os-6yv.5 | Obsidian vault as agent memory/notes |
| ai-os-l9q.1 | Agent sandboxing: scoped permissions / containers for untrusted runs |
| ai-os-61m | Container runtime (podman/docker) |
| ai-os-x51 | GitHub MCP server (needs a token) |

Local models are bounded by shared memory on the iGPU; expect small to mid-size quantised models, not 70B.
