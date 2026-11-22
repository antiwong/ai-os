function fish_prompt --description "ai-os two-line prompt (colours follow ai-os-theme)"
    set -l last_status $status
    set -l acc (set -q ai_os_accent; and echo $ai_os_accent; or echo cba6f7)
    set -l acc2 (set -q ai_os_accent2; and echo $ai_os_accent2; or echo b4befe)
    set -l red (set -q ai_os_red; and echo $ai_os_red; or echo f38ba8)
    set -l peach (set -q ai_os_peach; and echo $ai_os_peach; or echo fab387)
    set -l dim (set -q ai_os_dim; and echo $ai_os_dim; or echo 7f849c)

    echo
    # --- directory
    set_color -o $acc
    printf '  %s' (prompt_pwd --full-length-dirs 3 --dir-length 1)

    # --- git (one call: branch, ahead/behind, dirty counts)
    set -l g (command git status --porcelain -b 2>/dev/null)
    if test (count $g) -gt 0
        set -l head (string replace -r '^## ' '' -- $g[1])
        set -l branch (string replace -r '\.\.\..*$| \[.*$' '' -- $head)
        set branch (string replace 'No commits yet on ' '' -- $branch)
        set -l ahead (string match -rg 'ahead (\d+)' -- $head)
        set -l behind (string match -rg 'behind (\d+)' -- $head)
        set -l files $g[2..-1]
        set -l staged (count (string match -r '^[MADRC]' -- $files))
        set -l changed (count (string match -r '^.[MD]' -- $files))
        set -l untracked (count (string match -r '^\?\?' -- $files))
        set_color normal; set_color $dim; printf '  on '
        set_color -o $acc2; printf ' %s' $branch
        set_color normal
        test -n "$ahead"; and begin; set_color $acc2; printf ' ⇡%s' $ahead; end
        test -n "$behind"; and begin; set_color $peach; printf ' ⇣%s' $behind; end
        test $staged -gt 0; and begin; set_color $acc2; printf ' +%s' $staged; end
        test $changed -gt 0; and begin; set_color $peach; printf ' ~%s' $changed; end
        test $untracked -gt 0; and begin; set_color $dim; printf ' ?%s' $untracked; end
    end

    # --- python venv, last command duration, failure status
    set -q VIRTUAL_ENV; and begin; set_color normal; set_color $dim; printf '  󰌠 %s' (path basename $VIRTUAL_ENV); end
    if test "$CMD_DURATION" -gt 2000 2>/dev/null
        set -l s (math -s0 "$CMD_DURATION / 1000")
        set_color normal; set_color $dim
        if test $s -ge 60; printf '   %sm%ss' (math -s0 "$s / 60") (math -s0 "$s % 60"); else; printf '   %ss' $s; end
    end
    if test $last_status -ne 0
        set_color normal; set_color -o $red; printf '   %s' $last_status
    end
    set_color normal
    echo

    # --- prompt character: accent when ok, red after a failure
    if test $last_status -eq 0; set_color -o $acc; else; set_color -o $red; end
    printf '❯ '
    set_color normal
end
