# Give every Ghostty pane/tab a very subtle background tint so splits are easy to tell apart.
# Tints are small mixes of the active theme's base with its accent colours (follows ai-os-theme),
# chosen from the pane's tty so each pane keeps its colour. Uses OSC 11 (set default background).
status is-interactive; or return
test "$TERM" = xterm-ghostty; or return

function __ai_os_mix --argument-names a b pct
    set -l out
    for i in 1 3 5
        set -l x (math "0x"(string sub -s $i -l 2 $a))
        set -l y (math "0x"(string sub -s $i -l 2 $b))
        set out $out (printf '%02x' (math -s0 "round($x * (100 - $pct) / 100 + $y * $pct / 100)"))
    end
    string join '' $out
end

set -l base (set -q ai_os_base; and echo $ai_os_base; or echo 1e1e2e)
set -l acc (set -q ai_os_accent; and echo $ai_os_accent; or echo cba6f7)
set -l acc2 (set -q ai_os_accent2; and echo $ai_os_accent2; or echo b4befe)
set -l text (set -q ai_os_text; and echo $ai_os_text; or echo cdd6f4)

set -l tints $base \
    (__ai_os_mix $base $acc 7) \
    (__ai_os_mix $base $acc2 7) \
    (__ai_os_mix $base $acc 12) \
    (__ai_os_mix $base $acc2 12) \
    (__ai_os_mix $base $text 5)

set -l key (tty 2>/dev/null; or echo $fish_pid)
set -l idx (math (printf '%s' $key | cksum | string split ' ')[1] % (count $tints) + 1)
printf '\e]11;#%s\a' $tints[$idx]
functions -e __ai_os_mix
