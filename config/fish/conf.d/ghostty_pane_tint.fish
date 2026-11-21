# Give every Ghostty pane/tab its own subtle dark background tint (Catppuccin Mocha-based hues),
# so splits are easy to tell apart. Uses OSC 11 (set default background).
# Colour is chosen from the pane's tty, so it is stable for that pane's lifetime.
status is-interactive; or return
test "$TERM" = xterm-ghostty; or return

set -l tints \
    2a2440 \
    1d2b45 \
    1d3a3a \
    3a2a22 \
    3a2236 \
    1f3a2c \
    3a3622 \
    2b2f4a

set -l key (tty 2>/dev/null; or echo $fish_pid)
set -l idx (math (printf '%s' $key | cksum | string split ' ')[1] % (count $tints) + 1)
printf '\e]11;#%s\a' $tints[$idx]
