#!/usr/bin/env python3
# Writes ~/Desktop/ai-os-hotkeys.html (Catppuccin-styled; follows light/dark). Edit the tables below when a key changes.
import html, re
S = [
("Apps", [
 ("SUPER+RETURN","Terminal (Ghostty)"),("SUPER+SPACE","App launcher (fuzzel)"),
 ("SUPER+F","File manager (Dolphin)"),("SUPER+B","Browser (Chrome)"),
 ("SUPER+G","lazygit"),("SUPER+SHIFT+D","lazydocker (podman)"),
 ("SUPER+C","Claude Code scratchpad: first press launches, later presses show/hide"),
 ("SUPER+ESCAPE","System menu: screenshot, update, lock, power"),
 ("SUPER+SHIFT+T","Theme switcher (Catppuccin Mocha/Latte, Gruvbox, Tokyo Night)"),
 ("SUPER+SHIFT+M","Displays menu: layout, scale, resolution for external monitors"),
 ("SUPER+D","Dictation: press to listen, press again to type what you said"),
 ("SUPER+N","Quick note to Obsidian (Agent/Inbox.md); SUPER+SHIFT+N saves the clipboard"),
 ("SUPER+SHIFT+A","Screenshot a region and send it to the Claude scratchpad"),
 ("SUPER+CTRL+V","Clipboard history picker")]),
("Windows", [
 ("SUPER+W","Close window"),("SUPER+T","Toggle floating"),("SUPER+P","Pseudo-tile"),
 ("SUPER+J","Toggle split direction"),("SUPER+←/→/↑/↓","Move focus"),
 ("SUPER+Left-drag","Move window"),("SUPER+Right-drag","Resize window")]),
("Workspaces", [
 ("SUPER+1…0","Go to workspace 1–10"),("SUPER+SHIFT+1…0","Move window to workspace 1–10"),
 ("SUPER+Scroll","Next / previous workspace"),("SUPER+S","Show/hide general scratchpad"),
 ("SUPER+SHIFT+S","Send window to scratchpad")]),
("Screenshots", [
 ("Print","Region to clipboard"),("SHIFT+Print","Region, annotate in satty"),
 ("SUPER+Print","Whole screen"),("SUPER+SHIFT+Print","Active window")]),
("Session", [("SUPER+L","Lock screen"),("SUPER+SHIFT+E","Log out / exit Hyprland"),
 ("Media keys","Volume, mic mute, brightness, play/pause/next/previous, with on-screen display")]),
("Trackpad", [
 ("2-finger scroll","Scroll (natural direction)"),("2-finger click","Right click"),("3-finger click","Middle click"),
 ("Tap / tap-drag","Click / drag (drag lock on)"),("3-finger swipe ←/→","Switch workspace"),
 ("3-finger swipe ↑","Launcher"),("4-finger swipe ↑","Claude Code scratchpad"),("4-finger swipe ↓","System menu"),
 ("SUPER + 3-finger swipe","Move window"),("SUPER + 4-finger swipe","Resize window")]),
("tmux  ·  prefix = CTRL+SPACE", [
 ("prefix |","Split side by side (same directory)"),("prefix -","Split top/bottom (same directory)"),
 ("prefix c","New window (same directory)"),("ALT+h/j/k/l","Move between panes (no prefix)"),
 ("ALT+1…4","Jump to window 1–4 (no prefix)"),("prefix z","Zoom / unzoom pane"),
 ("prefix r","Reload tmux config"),("prefix A","Main pane + 2 agent panes"),
 ("prefix L","Cycle layouts"),("v  /  y","Copy mode: begin selection / copy and exit")]),
("Neovim  ·  leader = SPACE", [
 ("SPACE f f","Find files (Telescope)"),("SPACE f g","Live grep"),
 ("SPACE f b","Buffers"),("SPACE e","File tree (Neo-tree)"),
 ("SPACE a c","Toggle Claude Code (claudecode.nvim)"),("SPACE a f","Focus Claude"),("SPACE a r / a C","Resume / continue last Claude session"),
 ("SPACE a b","Add current buffer to Claude"),("SPACE a s","Send visual selection to Claude"),("SPACE a a / a d","Accept / deny Claude diff")]),
]
CMDS=[("agent <branch> [cmd]","New git worktree + tmux window running a coding agent (default: claude)"),
("ai-os-agent --list / --rm <branch>","List / remove agent worktrees"),
("ai-os-agents here 2","Agent pane layout in the current tmux window"),
("ai-os-theme [name]","Switch theme: colours, prompt, wallpaper (no argument: pick from a menu)"),
("ai-os-update [--check]","Update system with snapshots first; --check only lists what is pending"),
("ai-os-power status","Battery health, draw in watts, runtime estimate, top CPU users"),
("ai-os-display status","Multi-monitor setup: layout, scale, mode (or use the SUPER+SHIFT+M menu)"),
("ai-os-panel test","Measure AMD panel power saving unplugged; install/uninstall the auto rule"),
("ai-os-sandbox","Run Claude Code (permissions skipped) in a rootless podman container, project only"),
("ai-os-note \"text\"","Append a line to the Obsidian vault's Agent/Inbox.md"),
("ai-os-mcp claude","Apply the shared MCP servers to Claude Code")]
def keys(k):
    if any(w in k for w in ("finger","Tap")): return f'<kbd>{html.escape(k)}</kbd>'
    if k=="Media keys": return '<kbd>Media keys</kbd>'
    if k.startswith("v  /"): return '<kbd>v</kbd> / <kbd>y</kbd>'
    parts=k.split('+') if '+' in k else k.split(' ')
    return ' '.join(f'<kbd>{html.escape(p)}</kbd>' for p in parts if p)
cards=''
for t,rows in S:
    cards+=f'<section><h2>{html.escape(t)}</h2>'+''.join(f'<div class="row"><span class="k">{keys(k)}</span><span class="d">{html.escape(d)}</span></div>' for k,d in rows)+'</section>\n'
cmds=''.join(f'<div class="row"><span class="k"><code>{html.escape(k)}</code></span><span class="d">{html.escape(d)}</span></div>' for k,d in CMDS)
page=f'''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>ai-os Hotkeys</title>
<style>
:root{{--base:#1e1e2e;--mantle:#181825;--s0:#313244;--s1:#45475a;--text:#cdd6f4;--sub:#a6adc8;--accent:#cba6f7;--accent2:#b4befe}}
@media(prefers-color-scheme:light){{:root{{--base:#eff1f5;--mantle:#e6e9ef;--s0:#ccd0da;--s1:#bcc0cc;--text:#4c4f69;--sub:#6c6f85;--accent:#8839ef;--accent2:#7287fd}}}}
*{{box-sizing:border-box}}
body{{margin:0;background:var(--base);color:var(--text);font:16px/1.5 "Noto Sans",system-ui,sans-serif}}
header{{padding:48px 24px 8px;max-width:1200px;margin:0 auto}}
h1{{margin:0;font-size:2rem;color:var(--accent)}}
header p{{margin:6px 0 0;color:var(--sub)}}
main{{max-width:1200px;margin:0 auto;padding:24px;display:grid;grid-template-columns:repeat(auto-fill,minmax(420px,1fr));gap:20px}}
section{{background:var(--mantle);border:1px solid var(--s0);border-radius:14px;padding:16px 18px}}
h2{{margin:0 0 10px;font-size:1rem;letter-spacing:.04em;text-transform:uppercase;color:var(--accent2)}}
.row{{display:grid;grid-template-columns:minmax(150px,auto) 1fr;gap:14px;padding:7px 0;border-top:1px solid var(--s0);align-items:start}}
.row:first-of-type{{border-top:0}}
.k{{display:flex;flex-wrap:wrap;gap:4px}}
kbd,code{{font:600 .8rem "JetBrainsMono Nerd Font","JetBrains Mono",monospace}}
kbd{{background:var(--s0);border:1px solid var(--s1);border-bottom-width:2px;border-radius:6px;padding:1px 7px;color:var(--text)}}
code{{color:var(--accent);background:var(--s0);border-radius:6px;padding:2px 7px}}
.d{{color:var(--sub)}}
footer{{max-width:1200px;margin:0 auto;padding:8px 24px 40px;color:var(--sub);font-size:.85rem}}
@media(max-width:520px){{main{{grid-template-columns:1fr;padding:16px}}.row{{grid-template-columns:1fr;gap:4px}}}}
@media print{{body{{background:#fff;color:#000}}}}
</style></head><body>
<header><h1>ai-os Hotkeys</h1><p>Hyprland on CachyOS &middot; <kbd>SUPER</kbd> is the Windows/Meta key</p></header>
<main>
{cards}<section><h2>Terminal commands</h2>{cmds}</section>
</main>
<footer>Source: ~/code/ai-os/config/hypr/binds.lua, config/tmux/tmux.conf, ~/.config/nvim/init.lua</footer>
</body></html>'''
open('/home/moovita/Desktop/ai-os-hotkeys.html','w').write(page)
