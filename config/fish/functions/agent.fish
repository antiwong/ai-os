# agent <branch> [command...]  : worktree + tmux window + coding agent (default: claude)
# agent --rm <branch> [--force] | agent --list      (see scripts/ai-os-agent)
function agent --description "Spawn a git worktree + tmux window running a coding agent"
    ai-os-agent $argv
end
complete -c agent -f -a "(git branch --format='%(refname:short)' 2>/dev/null)"
complete -c agent -l rm -d "remove worktree and window"
complete -c agent -l list -d "list worktrees"
