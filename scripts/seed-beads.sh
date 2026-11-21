#!/usr/bin/env bash
# Creates the ai-os epics and tasks in beads. Run once from the repo root after step 0.
set -euo pipefail
cd "$(dirname "$0")/.."
[ -d .beads ] || bd init

mk() { # mk <type> <priority> <title> <desc> [parent]
  local args=(create "$3" -t "$1" -p "$2" -d "$4" --json)
  [ -n "${5:-}" ] && args+=(--parent "$5")
  bd "${args[@]}" | jq -r .id
}

# ---- Epics
E1=$(mk epic 0 "Foundation: safety net, tracking, dotfiles" "Snapshots, beads/dolt, and a dotfiles repo so the whole setup is reproducible and recoverable.")
E2=$(mk epic 1 "Hyprland desktop (Omarchy-style)" "Hyprland session next to Plasma with bar, launcher, notifications, lock, theming and keybindings.")
E3=$(mk epic 1 "AI coding layer" "Terminal/editor/agent workflow: tmux, worktrees, nvim integration, agents, MCP.")
E4=$(mk epic 2 "AI work layer" "Local models, chat UI, voice input, screenshot-to-agent, notes.")
E5=$(mk epic 2 "Hygiene and safety" "Agent sandboxing, permissions, updates, backups.")

# ---- E1 Foundation
mk task 0 "Install dolt and beads (scripts/00)" "Neither was installed. dolt from extra (repo has 2.7.3, upstream 2.7.6), beads-bin from AUR (1.3.4)." $E1 >/dev/null
mk task 0 "Configure snapper snapshots for root (limine-snapper)" "Needed before risky changes. scripts/01 skips the snapshot if no root config exists." $E1 >/dev/null
mk task 1 "Create dotfiles repo with chezmoi or stow" "Track ~/.config/{hypr,waybar,mako,fuzzel,ghostty,nvim,fish}. Goal: rebuild machine from git." $E1 >/dev/null
mk task 2 "Decide dolt version policy (repo 2.7.3 vs upstream 2.7.6)" "Repo lags upstream. Check beads compatibility; only switch to the upstream binary if needed." $E1 >/dev/null

# ---- E2 Hyprland
T_INST=$(mk task 0 "Install Hyprland stack (scripts/01)" "Official repos only: hyprland, uwsm, waybar, fuzzel, mako, hypr* tools, screenshot and audio utils." $E2)
T_SESS=$(mk task 0 "Verify Hyprland session appears in plasma-login-manager and boots" "Display manager is plasmalogin. Check hyprland-uwsm.desktop exists in /usr/share/wayland-sessions; log in, confirm Plasma still works as fallback." $E2)
T_CONF=$(mk task 1 "Write base hyprland.conf (monitors, input, env, autostart via uwsm)" "AMD Phoenix1 iGPU. Include touchpad gestures, key repeat, XDG env, autostart for bar/mako/polkit/hypridle/hyprpaper/cliphist." $E2)
T_KEYS=$(mk task 1 "Keybindings: Omarchy-style workspaces, window mgmt, app launchers" "Super+Return terminal, Super+Space launcher, Super+W close, Super+1..9 workspaces, Super+Alt+Space system menu." $E2)
T_BAR=$(mk task 1 "Waybar config and Catppuccin Mocha styling" "Workspaces, clock, network, bluetooth, audio, battery, tray; mauve accent." $E2)
T_LAUNCH=$(mk task 1 "Launcher and system menu (fuzzel; optional Walker+elephant)" "scripts/02 adds Walker. Build a menu script for theme, update, power, screenshots." $E2)
T_MAKO=$(mk task 2 "mako notifications and swayosd themed" "Volume and brightness OSD." $E2)
T_LOCK=$(mk task 2 "hyprlock and hypridle (lock, dim, suspend)" "Match theme; wire to power-profiles-daemon." $E2)
T_WALL=$(mk task 2 "Wallpaper with hyprpaper and a theme switcher script" "One theme applied to ghostty, waybar, mako, fuzzel, nvim, btop." $E2)
mk task 2 "Screenshot and clipboard workflow (hyprshot, satty, cliphist)" "Region capture to clipboard/annotate; clipboard history picker." $E2 >/dev/null
mk task 2 "GTK/Qt theming for mixed Dolphin/GTK apps (nwg-look, qt6ct)" "Keep Dolphin usable under Hyprland." $E2 >/dev/null
mk task 3 "Handle NVIDIA/AMD, HiDPI scaling, multi-monitor, Chrome/Obsidian/VS Code Wayland flags" "Electron apps need ozone-platform hints." $E2 >/dev/null
bd dep add $T_SESS $T_INST; bd dep add $T_CONF $T_SESS; bd dep add $T_KEYS $T_CONF
bd dep add $T_BAR $T_CONF; bd dep add $T_LAUNCH $T_CONF; bd dep add $T_MAKO $T_CONF
bd dep add $T_LOCK $T_CONF; bd dep add $T_WALL $T_CONF

# ---- E3 AI coding
mk task 1 "tmux config with agent pane layouts" "One pane per agent; catppuccin theme; ghostty integration." $E3 >/dev/null
mk task 1 "Install mise and set default runtimes (node, python)" "Alongside uv." $E3 >/dev/null
mk task 1 "git worktree + agent session fish function" "Command to spawn a worktree, tmux window and Claude Code for a branch." $E3 >/dev/null
mk task 2 "Floating Claude Code scratchpad hotkey (Hyprland special workspace)" "" $E3 >/dev/null
mk task 2 "Neovim agent integration (claudecode.nvim or codecompanion)" "Edit ~/.config/nvim/init.lua (lazy.nvim)." $E3 >/dev/null
mk task 2 "lazygit and lazydocker for reviewing agent output" "" $E3 >/dev/null
mk task 2 "Evaluate OpenCode / aider as model-agnostic agents" "" $E3 >/dev/null
mk task 2 "Shared MCP server config (filesystem, github, playwright, docs)" "Configure once, reuse across agents." $E3 >/dev/null

# ---- E4 AI work
mk task 2 "Ollama + local model selection for AMD Phoenix1 (ROCm/Vulkan)" "iGPU only: check unified memory and model size limits first." $E4 >/dev/null
mk task 3 "Open WebUI on localhost" "" $E4 >/dev/null
mk task 2 "Push-to-talk dictation (whisper.cpp) bound to a hotkey" "" $E4 >/dev/null
mk task 2 "Screenshot-to-agent hotkey (grim+slurp to Claude)" "" $E4 >/dev/null
mk task 3 "Obsidian vault as agent memory/notes integration" "" $E4 >/dev/null

# ---- E5 Hygiene
mk task 2 "Agent sandboxing: scoped permissions / container for untrusted runs" "" $E5 >/dev/null
mk task 3 "Update routine (pacman, paru, flatpak, dotfiles) and rollback doc" "" $E5 >/dev/null

echo; bd list
