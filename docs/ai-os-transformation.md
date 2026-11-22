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

Five layers, each independent enough to fail without taking down the others.

```
 Safety      snapper (root + home) -> limine boot menu -> ai-os-update, docs/updates.md
 AI work     Obsidian capture + agent notes (done); voice, local/remote models (parked)
 AI coding   Claude Code scratchpad, agent worktrees, nvim, MCP, lazygit
 Desktop     Hyprland + waybar + fuzzel + mako + swayosd + hyprlock, one theme
 Foundation  this repo (symlinked dotfiles) + beads task tracking
```

### Repo layout
```
config/   hypr waybar mako fuzzel swayosd ghostty tmux nvim fish mise mcp sandbox systemd bbl flags themes
scripts/  00-05 numbered setup scripts, plus the ai-os-* commands (theme, update, power, sandbox, ...)
docs/     this file, plan.md (decisions), updates.md (update + rollback), sandbox.md,
          local-models.md (parked), hotkeys.md (keys, gestures, tmux, nvim)
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
- **Trackpad** (`config/hypr/input.lua`): natural scrolling, tap-to-click and tap-and-drag, two-finger click = right click, palm rejection; 3-finger swipe left/right switches workspace, 3-finger up opens the launcher, 4-finger up/down opens the Claude scratchpad / system menu, `SUPER` + 3/4-finger swipe moves / resizes a window. Applied and accepted by Hyprland, but not tried with real fingers.
- **Mixed apps**: GTK and Qt/KDE (Dolphin) follow the theme; Chrome, Code and Obsidian get Wayland flags from one shared file. HiDPI: the laptop panel is pinned to scale 1.0.

### One theme for everything
`ai-os-theme [name]` (or `SUPER+SHIFT+T`) renders templates from `config/themes/templates/` using a small palette file per theme (`catppuccin-mocha` default, `catppuccin-latte`, `gruvbox-dark`, `tokyo-night`) and reloads the apps. Covered: waybar, mako, fuzzel, hyprlock, hypr borders, swayosd, ghostty, tmux, neovim (catppuccin flavour + palette overrides), btop, lazygit, lazydocker, wallpaper, GTK and Qt colour scheme. To add a theme, add `config/themes/<name>/colors.env`.

### AI coding layer
- **Claude Code scratchpad** (`SUPER+C`): a floating Ghostty on a hidden special workspace. First press launches, later presses show/hide; the session keeps running.
- **Screenshot to agent** (`SUPER+SHIFT+A`): capture a region, open the scratchpad, type `@<path>` so you only add the question.
- **Agent worktrees** (`agent <branch>` / `ai-os-agent`): one git worktree and one tmux window per agent, so parallel agents never share a working tree. `ai-os-agents` lays out panes. tmux prefix is `Ctrl+Space`.
- **Runtimes** (mise): global node (LTS) and python 3.13 from `config/mise/config.toml`, activated in fish; a project's `mise.toml` overrides them (verified with node 22). uv stays for Python projects.
- **Neovim**: `claudecode.nvim` (`SPACE a ...`) shares buffers/selections with Claude Code and shows its diffs as nvim diffs.
- **Review tools**: `lazygit` (`SUPER+G`) and `lazydocker` (`SUPER+SHIFT+D`).
- **Shared MCP servers** (`config/mcp/servers.json`, applied with `ai-os-mcp claude`): filesystem (scoped to `~/code`), context7 (library docs), playwright, obsidian-agent (read/write on the vault's `Agent/` folder only). Secrets are never stored in the repo.

### AI work layer
- **Obsidian** (personal vault): `SUPER+N` quick-captures a line to `Agent/Inbox.md` (`SUPER+SHIFT+N` saves the clipboard). Agents get the `obsidian-agent` MCP server, which can read/write only `Agent/` (inbox, `Memory/`, README). Your existing notes, including the `AI` folder, are not exposed. The vault syncs via Obsidian Sync, so captures appear on your other devices.
- **Models**: local models are parked. Ollama is set up (user service, Vulkan on the Radeon 780M, about 1.3x faster than CPU) but disabled; the plan is a proxy to models on the user's own servers, to be provided later. See `docs/local-models.md`.
- **Dictation** (`SUPER+D`): `ai-os-dictate` (whisper.cpp `base.en`) exists but voice is **deferred** by the user; pipeline verified on silence only.

### Look
- **Terminal**: Ghostty uses JetBrainsMono Nerd Font Mono, a non-blinking cursor and 95% opacity. Each pane gets a very faint tint that is a small mix of the active theme's base and accent colours (it used to be eight hardcoded hues, including browns, that ignored the theme).
- **Prompt**: custom two-line fish prompt (`config/fish/functions/fish_prompt.fish`): path, git branch with ahead/behind and staged/changed/untracked counts, python venv, slow-command duration, failure status, and a `❯` that turns red after an error. Syntax highlighting and autosuggestion colours also follow the theme.
- **Wallpaper**: a soft "aurora" generated per theme by `ai-os-wallpaper` (ImageMagick, about 12 s once per theme, cached as a ~290 KB JPEG).
- Switching a theme updates all of this live: fish colours are universal variables, so open shells repaint at the next prompt. Shells started before a change keep their old pane tint.

- **Desktop effects**: macOS-style rounding (12), large soft shadows, frosted blur behind the bar/launcher/notifications, spring animations, Inter-first font in the bar (Inter is not installed yet, so Noto Sans is used; install `inter-font`). On battery, blur, shadows and animations are switched off (see Power).

### Power (laptop battery)
- `ai-os-power status` prints battery health, discharge draw, runtime estimate, profile and top CPU users. `ai-os-power watch` (autostarted by Hyprland) switches to the `power-saver` profile with effects off when you unplug, and back to `balanced` with effects on when you plug in. `look.lua` reads the AC state at load, so a Hyprland reload keeps the right mode.
- Measured unplugged (2026-11-22, light use): about 8.7 W, roughly 5.5 h on a battery at 84% of its design capacity (271 cycles). The processor sat in deep sleep 96% of the time. Effects off saved about 0.3 W and dropping brightness from 70% to 20% only 0.2 W, so neither is a big lever; draw also swings by about 1 W with activity.
- Claude's statusline used to run `npx ccstatusline` on every refresh (about 0.55-0.8 CPU-seconds each). It now runs the installed binary (about 0.19). The setting is in `~/.claude/settings.json`, outside this repo.
- AMD panel power saving (`panel_power_savings`, level 0-4, currently 0): `ai-os-panel status | set <0-4> | test | install | uninstall` controls it. `ai-os-panel test` measures battery draw at level 0 vs a chosen level while unplugged, and `ai-os-panel install` adds a udev rule that uses that level on battery and turns it off on AC. The script's logic was verified against a simulated sysfs; the real-hardware measurement has not been run yet (needs the charger unplugged and `sudo`). Chrome was deliberately left alone at the user's request.

### Safety
- **Agent sandbox** (`ai-os-sandbox`, see `docs/sandbox.md`): runs Claude Code with permissions skipped inside a rootless podman container that sees only the project, a private Claude config and the login file. Tested: host secrets hidden, system paths read-only, worktrees and offline mode work, Claude authenticates. Network is not filtered.
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
4. `scripts/05-link-dotfiles.sh`, then `ai-os-theme catppuccin-mocha` and `mise install`.
5. `ai-os-mcp claude` to restore MCP servers; `systemctl --user enable --now podman.socket`; `ai-os-sandbox build` if you use the sandbox.
6. Packages used beyond the base install: `podman`, `mise`, `lazygit`, `lazydocker`, `whisper-cpp` (optional), `ollama` + `ollama-vulkan` (optional), `libxcrypt-compat` (only for `bbl`), `inter-font` (optional).
7. Not in git: the `bbl` binary and Bible packs, browser profiles, Obsidian vaults, git identity, tokens.

## 7. Known gaps and caveats
- **Containers**: rootless podman with `DOCKER_HOST` pointing at its user socket; there is no `docker` command (add `podman-docker` if scripts need one).
- **Voice dictation** is deferred (`ai-os-6yv.3`); the `SUPER+D` bind is still active.
- Only 14 GB RAM, shared with the iGPU, which is why models are planned to run remotely.
- `libxcrypt-compat` was added only because the copied `bbl` binary needs `libcrypt.so.1`.
- `.pacnew` files: the six pending ones were reviewed and cleared on 2026-11-22 (kept the tuned mirrorlists and NetworkManager resolver; enabled `CheckSpace`). New ones appear in the `ai-os-update` health report.
- Outside the repo (not versioned): `~/.claude/settings.json` (statusline), the `Agent/` folder in the Obsidian vault, `~/.ollama`, the Claude login and sandbox config under `~/.local/share/ai-os/`.
- Some tools replace symlinks when they write (e.g. nvim's `lazy-lock.json`); re-run `05-link-dotfiles.sh` to restore.
- Window rules only apply to windows opened after a reload.
- Several pieces were verified by running them, but not every hotkey was pressed on the real keyboard; see commit messages and bead close reasons for what was and was not tested.

## 8. Roadmap (open beads)
| Bead | Item |
|---|---|
| ai-os-atz | Battery life: panel power saving test, tuning (in progress) |
| ai-os-6uj.7 | Evaluate OpenCode / aider as model-agnostic agents |
| ai-os-6yv.3 | Voice dictation (deferred; built, untested on a real voice) |
| ai-os-6yv.2 | Open WebUI on localhost (deferred until the model proxy exists) |
| ai-os-x51 | GitHub MCP server (needs a token) |

Local models are bounded by shared memory on the iGPU; expect small quantised models (3-4B), not 70B.
