# Prettifier for bbl output (bbl itself has no color/wrap options).
# Used by the bbl() function in ~/.zshrc. Portable awk (BWK awk on macOS, mawk on Linux).
# -v W=<width> -v N=<number of translations> -v codes=<KJV,NIV,..> -v search=0|1 -v foot=0|1

function rep(s, n,   r) { r = ""; while (n-- > 0) r = r s; return r }
function base(i) { return ESC "[0;38;5;" tc[i % 5] "m" }

# word-wrap t into wl[1..nwl]; first line may use w1 columns, the rest w2
function wrap(t, w1, w2,   n, w, i, line, lim) {
    nwl = 0
    if (t ~ /[^ -~]/ || length(t) <= w1) { wl[++nwl] = t; return }   # skip wrapping for non-ASCII
    n = split(t, w, " "); line = ""
    for (i = 1; i <= n; i++) {
        lim = (nwl == 0 ? w1 : w2)
        if (line != "" && length(line) + 1 + length(w[i]) > lim) { wl[++nwl] = line; line = w[i] }
        else line = (line == "" ? w[i] : line " " w[i])
    }
    if (line != "") wl[++nwl] = line
}

# color one wrapped line: translation color for text, italic warm shade for "quoted speech"
function colorize(s, idx,   out, p, pre) {
    out = ""
    while ((p = index(s, "\"")) > 0) {
        pre = substr(s, 1, p - 1)
        if (inq[idx]) { out = out QC pre "\""; inq[idx] = 0 }
        else          { out = out base(idx) pre QC "\""; inq[idx] = 1 }
        s = substr(s, p + 1)
    }
    return out (inq[idx] ? QC : base(idx)) s RST
}

function emit(pfx, plen, hang, text, idx,   j) {
    wrap(text, W - plen, W - hang)
    for (j = 1; j <= nwl; j++)
        print (j == 1 ? pfx : rep(" ", hang)) colorize(wl[j], idx)
}

BEGIN {
    ESC = "\033"; RST = ESC "[0m"
    QC = ESC "[0;3;38;5;222m"
    HC = ESC "[1;38;5;75m"
    NC = ESC "[38;5;179m"
    DIM = ESC "[2;38;5;245m"
    tc[0] = 80; tc[1] = 150; tc[2] = 183; tc[3] = 216; tc[4] = 111
    if (W < 20) W = 80
    if (N < 1) N = 1
    HDR = "^[1-3]? ?[A-Za-z]+( [A-Za-z]+)* [0-9]+(:[0-9]+(-[0-9]+)?)?$"
    REF = "^[1-3]? ?[A-Za-z]+( [A-Za-z]+)* [0-9]+:[0-9]+ "
}

{ L[++nl] = $0 }

END {
    while (nl > 0 && L[nl] ~ /^[ \t]*$/) nl--
    if (nl == 0) exit

    # verse lines (read mode only), to work out which translation each belongs to
    for (i = 1; i <= nl; i++)
        if (!search && L[i] !~ HDR && L[i] ~ /^[0-9]+ /) vl[++nv] = i
    vmode = 0
    if (nv >= 2 && N > 1) {
        a = L[vl[1]]; sub(/ .*/, "", a); b = L[vl[2]]; sub(/ .*/, "", b)
        vmode = (a == b)
    }

    print ""
    k = 0
    for (i = 1; i <= nl; i++) {
        line = L[i]
        if (line ~ /^[ \t]*$/) { print ""; continue }
        if (line ~ HDR) {
            for (x in inq) inq[x] = 0
            print HC line RST
            print DIM rep("─", length(line)) RST
        } else if (search && match(line, REF)) {
            ref = substr(line, 1, RLENGTH - 1)
            emit(HC ref RST " ", length(ref) + 1, 2, substr(line, RLENGTH + 1), 0)
        } else if (!search && line ~ /^[0-9]+ /) {
            num = line; sub(/ .*/, "", num)
            txt = substr(line, length(num) + 2)
            k++
            idx = 0
            if (N > 1) {
                if (vmode) idx = (k - 1) % N
                else if (nv % N == 0) idx = int((k - 1) / (nv / N))
            }
            emit(NC num RST " ", length(num) + 1, length(num) + 1, txt, idx)
        } else {
            emit("", 0, 0, line, 0)
        }
    }

    if (foot) {
        n = split(codes, cs, ",")
        s = ""
        for (j = 1; j <= n; j++)
            s = s (j > 1 ? DIM " · " RST : "") ESC "[1;38;5;" tc[(j - 1) % 5] "m" toupper(cs[j]) RST
        print ""
        print s
    }
}
