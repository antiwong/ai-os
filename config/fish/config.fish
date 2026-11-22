source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# Claude Code native install
set -gx PATH "$HOME/.local/bin" $PATH

# mise: per-project node/python versions (global defaults in ~/.config/mise/config.toml)
if type -q mise
    mise activate fish | source
end
