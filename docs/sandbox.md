# Agent sandbox

`ai-os-sandbox` runs Claude Code (permissions skipped by default) inside a rootless podman container,
so a runaway or prompt-injected agent can only touch the project it was given.

```
ai-os-sandbox build                 # once, and to refresh Claude Code in the image
cd ~/code/myproject && ai-os-sandbox        # claude --dangerously-skip-permissions, sandboxed
ai-os-sandbox --safe                # same, but Claude still asks before acting
ai-os-sandbox --net=none -- sh -c 'make test'     # any command, no network
ai-os-agent feature-x ai-os-sandbox # sandboxed agent in its own git worktree + tmux window
```
Env: `AI_OS_SANDBOX_MEM` (default 8g).

## What the agent can see
| Yes | No |
|---|---|
| the project directory (read/write, same path) | `~/.ssh`, `~/.gnupg`, `~/.config`, browser profiles |
| the repo's `.git` dir when working in a worktree | `~/Documents`, other repos, your host Claude history/projects |
| a private Claude config dir (`~/.local/share/ai-os/sandbox/claude`) | host MCP servers, plugins, hooks, CLAUDE.md |
| your Claude login file (`~/.claude/.credentials.json`) | your shell environment and tokens (only git author name/email are passed) |

Container limits: read-only root filesystem, tmpfs `/tmp` and home, all Linux capabilities dropped, `no-new-privileges`, 512 pids, memory cap, runs as your uid (no root).

## What it does NOT protect against
- **The network is open.** The agent can reach the internet, so it could send out anything it can read, including the project files and the Claude login file. Use `--net=none` when Claude is not needed.
- **The login file is mounted read-write** so token refresh works. A hostile agent could read it.
- **The project is writable.** It can delete or corrupt it. Work in a git worktree (`ai-os-agent`) and commit often; the main checkout stays untouched.
- **A container is not a VM.** Kernel bugs are out of scope; do not run known-malicious code here.
- Host MCP servers, hooks and plugins are not available inside. The sandbox has its own Claude config (`~/.local/share/ai-os/sandbox/claude/.claude.json`); add an MCP server there only if you accept the agent using it.

## Notes
- Sandboxed sessions keep their own history under `~/.local/share/ai-os/sandbox/claude`; delete it to reset.
- The script refuses to sandbox `$HOME`, `/`, or sensitive dirs.
- The image installs `@anthropic-ai/claude-code` from npm at build time; rebuild to update.
