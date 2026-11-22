# ai-os Hotkeys & Shortcuts

Hyprland desktop on CachyOS. **SUPER** = the Windows/Meta key.
Keys come from `config/hypr/binds.lua`, `config/hypr/input.lua` (gestures), `config/tmux/tmux.conf` and `config/nvim/init.lua`. A styled HTML copy is written by `scripts/gen-hotkeys-html.py` to `~/Desktop/ai-os-hotkeys.html`; update both when a key changes.

## Apps

| Keys | Action |
|---|---|
| `SUPER + RETURN` | Terminal (Ghostty) |
| `SUPER + SPACE` | App launcher (fuzzel) |
| `SUPER + F` | File manager (Dolphin) |
| `SUPER + B` | Browser (Chrome) |
| `SUPER + G` | lazygit (Ghostty) |
| `SUPER + SHIFT + D` | lazydocker (Ghostty, uses podman) |
| `SUPER + C` | Claude Code scratchpad: first press launches, later presses show/hide |
| `SUPER + ESCAPE` | System menu (screenshot, update, lock, power) |
| `SUPER + SHIFT + T` | Theme switcher (Catppuccin Mocha/Latte, Gruvbox, Tokyo Night) |
| `SUPER + D` | Dictation: press to listen, press again to type what you said |
| `SUPER + N` | Quick note to Obsidian (Agent/Inbox.md); `SUPER + SHIFT + N` saves the clipboard |
| `SUPER + SHIFT + A` | Screenshot a region and send it to the Claude scratchpad |
| `SUPER + CTRL + V` | Clipboard history picker |

## Windows

| Keys | Action |
|---|---|
| `SUPER + W` | Close window |
| `SUPER + T` | Toggle floating |
| `SUPER + P` | Pseudo-tile |
| `SUPER + J` | Toggle split direction |
| `SUPER + Arrow keys` | Move focus left/right/up/down |
| `SUPER + Left-drag` | Move window |
| `SUPER + Right-drag` | Resize window |

## Workspaces

| Keys | Action |
|---|---|
| `SUPER + 1..0` | Go to workspace 1-10 |
| `SUPER + SHIFT + 1..0` | Move window to workspace 1-10 |
| `SUPER + Scroll down / up` | Next / previous workspace |
| `SUPER + S` | Show/hide general scratchpad |
| `SUPER + SHIFT + S` | Send window to scratchpad |

## Screenshots

| Keys | Action |
|---|---|
| `Print` | Region to clipboard |
| `SHIFT + Print` | Region, annotate in satty |
| `SUPER + Print` | Whole screen (output) |
| `SUPER + SHIFT + Print` | Active window |

## Session

| Keys | Action |
|---|---|
| `SUPER + L` | Lock screen |
| `SUPER + SHIFT + E` | Log out / exit Hyprland |

## Media keys

Volume up/down/mute, mic mute, brightness up/down and play/pause/next/previous
work from the keyboard's media keys, with an on-screen display (swayosd).

## Trackpad

| Gesture | Action |
|---|---|
| 2-finger scroll | Scroll (natural direction) |
| 2-finger click / 3-finger click | Right click / middle click |
| Tap, tap-and-drag | Click, drag (drag lock on) |
| 3-finger swipe left/right | Switch workspace |
| 3-finger swipe up | Launcher |
| 4-finger swipe up / down | Claude Code scratchpad / system menu |
| `SUPER` + 3-finger swipe | Move window |
| `SUPER` + 4-finger swipe | Resize window |

## tmux (prefix = `CTRL + SPACE`)

| Keys | Action |
|---|---|
| `prefix + \|` | Split side by side (same directory) |
| `prefix + -` | Split top/bottom (same directory) |
| `prefix + c` | New window (same directory) |
| `ALT + h/j/k/l` | Move between panes (no prefix) |
| `ALT + 1..4` | Jump to window 1-4 (no prefix) |
| `prefix + z` | Zoom/unzoom pane |
| `prefix + r` | Reload tmux config |
| `prefix + A` | Main pane + 2 agent panes layout |
| `prefix + L` | Cycle layouts |
| copy mode: `v` / `y` | Begin selection / copy and exit (vi keys) |

## Neovim (leader = `SPACE`)

| Keys | Action |
|---|---|
| `SPACE f f` | Find files (Telescope) |
| `SPACE f g` | Live grep |
| `SPACE f b` | Buffers |
| `SPACE e` | File tree (Neo-tree) |
| `SPACE a c` / `a f` | Toggle / focus Claude Code |
| `SPACE a r` / `a C` | Resume / continue last Claude session |
| `SPACE a b` | Add current buffer to Claude |
| `SPACE a s` (visual) | Send selection to Claude |
| `SPACE a a` / `a d` | Accept / deny Claude diff |

## Terminal commands

| Command | Action |
|---|---|
| `agent <branch> [cmd]` (fish) / `ai-os-agent` | New git worktree + tmux window running a coding agent (default: claude) |
| `ai-os-agent --list` / `--rm <branch>` | List / remove agent worktrees |
| `ai-os-agents here 2` | Agent pane layout in the current tmux window |
| `ai-os-theme [name]` | Switch theme: colours, prompt, wallpaper (no argument: pick from a menu) |
| `ai-os-update [--check]` | Update the system with snapshots first; `--check` only lists what is pending |
| `ai-os-power status` | Battery health, draw in watts, runtime estimate, top CPU users |
| `ai-os-panel status` / `test` / `install` | AMD panel power saving: show level, measure the saving unplugged, install the auto rule |
| `ai-os-sandbox` | Run Claude Code (permissions skipped) in a rootless podman container, project only |
| `ai-os-note "text"` | Append a line to the Obsidian vault's `Agent/Inbox.md` |
| `ai-os-mcp claude` | Apply the shared MCP servers to Claude Code |

## Inside lazygit (handy)

`?` help, `space` stage, `c` commit, `P` push, `p` pull, `1-5` switch panels, `q` quit.
