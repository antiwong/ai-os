function bbl --description "Bible reader (bbl) with colour + wrapping via pretty.awk"
    switch "$argv[1]"
        case "" "-*" list ls install get pull uninstall rm remove del delete config conf c history h help generate-completion
            command bbl $argv; return
    end
    if not isatty stdout
        command bbl $argv; return
    end
    set -l search 0
    set -l foot 1
    if contains -- "$argv[1]" s search
        set search 1; set foot 0
    end
    set -l codes
    set -l seen 0
    for a in $argv
        if test $seen -eq 1
            set -a codes $a
        else if test "$a" = in
            set seen 1
        end
    end
    if test (count $codes) -eq 0
        set codes (sed -n 's/.*"translation"[^"]*"\([^"]*\)".*/\1/p' ~/.bbl/config.json 2>/dev/null)
        test (count $codes) -eq 0; and set codes webus
    end
    set -l cols $COLUMNS
    test -z "$cols"; and set cols 80
    test $cols -gt 100; and set cols 100
    command bbl $argv | awk -v W=$cols -v N=(count $codes) -v codes=(string join , $codes) \
        -v search=$search -v foot=$foot -f ~/.config/bbl/pretty.awk
    return $pipestatus[1]
end

function bblc --description "Compare a passage in NIV, ESV and KJV"
    bbl $argv in niv esv kjv
end
