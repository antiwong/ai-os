#!/usr/bin/env bash
# The checks that need a person at the machine. Each step explains itself and asks before it acts.
# Usage: scripts/06-manual-checks.sh [all|lock|suspend|pr|config]
#   lock     lock the screen; you unlock with your password                 (desktop or laptop, inside Hyprland)
#   suspend  suspend the machine; you wake it; screens, network, audio are checked afterwards
#   pr       open the pull request for the current branch (needs `gh auth login`)
#   config   reload the Hyprland config and run scripts/03-verify.sh         (the CachyOS laptop check)
#   all      every step above, in the order config, lock, suspend, pr (default)
# Results are printed and appended to ~/.local/state/ai-os/manual-checks.log.
set -u
ROOT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
LOG="$HOME/.local/state/ai-os/manual-checks.log"; mkdir -p "$(dirname "$LOG")"
b=$'\e[1m'; d=$'\e[0m'
RESULTS=()

hdr()    { printf '\n%s==> %s%s\n' "$b" "$1" "$d"; }
result() { # result <step> <PASS|FAIL|SKIP> <detail>
  local line; line="$(date '+%F %H:%M') $(hostname) $1: $2 - $3"
  RESULTS+=("$1: $2 - $3"); echo "$line" >> "$LOG"; printf '  %s: %s - %s\n' "$1" "$2" "$3"
}
ask()    { local r; read -rp "  $1 [y/N] " r; [ "$r" = y ] || [ "$r" = Y ]; }
in_hypr() { [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && hyprctl monitors >/dev/null 2>&1; }
monitors() { hyprctl monitors -j | jq -r '[.[] | select(.dpmsStatus) | .name] | sort | join(" ")'; }

step_config() {
  hdr "Config: reload Hyprland and verify the install"
  in_hypr || { result config SKIP "not inside a Hyprland session"; return; }
  "$ROOT/scripts/05-link-dotfiles.sh" | tail -1
  hyprctl reload >/dev/null; sleep 2
  local errs missing
  errs="$(hyprctl configerrors | grep .)"
  missing="$(bash "$ROOT/scripts/03-verify.sh" | grep '^MISSING')"
  [ -n "$errs" ] && printf '%s\n' "$errs" | sed 's/^/    /'
  [ -n "$missing" ] && printf '%s\n' "$missing" | sed 's/^/    /'
  if [ -z "$errs" ] && [ -z "$missing" ]; then
    result config PASS "$(Hyprland --version 2>/dev/null | head -1 | cut -d' ' -f1-2): no config errors, nothing missing"
  else
    result config FAIL "config errors: $(printf '%s' "$errs" | grep -c .), missing: $(printf '%s' "$missing" | grep -c .) (listed above)"
  fi
}

step_lock() {
  hdr "Lock screen: password unlock"
  in_hypr || { result lock SKIP "not inside a Hyprland session"; return; }
  echo "  The screen locks now. Look at every monitor, then type your password and press Enter."
  echo "  If the screen is black or takes no input: Ctrl+Alt+F3, log in, run: pkill -USR1 hyprlock"
  ask "Lock the screen now?" || { result lock SKIP "not run"; return; }
  if pidof hyprlock >/dev/null; then result lock SKIP "hyprlock is already running"; return; fi
  if hyprlock >/dev/null 2>&1; then
    if ask "Did every monitor show the lock screen (clock and password field)?"; then
      result lock PASS "locked and unlocked on: $(monitors)"
    else
      result lock FAIL "unlock worked, but the lock screen did not show on every monitor"
    fi
  else
    result lock FAIL "hyprlock exited with an error"
  fi
}

step_suspend() {
  hdr "Suspend and resume"
  local before after net sink
  before="$(in_hypr && monitors)"
  echo "  Save your work first. The machine suspends; wait 10 seconds, then press a key or the power button."
  echo "  If the screen stays black after waking: Ctrl+Alt+F3, log in, run: hyprctl --instance 0 dispatch dpms on"
  [ -d /sys/module/nouveau ] && echo "  WARNING: nouveau is loaded. Older NVIDIA cards on nouveau can resume to a black screen."
  ask "Suspend now?" || { result suspend SKIP "not run"; return; }
  systemctl suspend || { result suspend FAIL "systemctl suspend failed"; return; }
  sleep 15   # the script is frozen during suspend; this runs out after the machine wakes
  echo "  Awake again. Checking..."
  after="$(in_hypr && monitors)"
  net="$(nmcli -t -f STATE general 2>/dev/null || echo unknown)"
  sink="$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | sed -n 's/.*node.description = "\(.*\)"/\1/p' | head -1)"
  echo "  monitors before: ${before:-?}   after: ${after:-?}   network: $net   audio output: ${sink:-none}"
  if [ "$before" != "$after" ]; then
    result suspend FAIL "monitors changed: before [$before] after [$after]"
  elif ask "Do all screens show a normal picture?"; then
    result suspend PASS "monitors [$after], network $net, audio ${sink:-none}"
  else
    result suspend FAIL "picture is wrong after resume (monitors [$after])"
  fi
}

step_pr() {
  hdr "Pull request"
  local branch url
  branch="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)"
  command -v gh >/dev/null || { result pr SKIP "gh is not installed; open https://github.com/antiwong/ai-os/compare/main...$branch?expand=1"; return; }
  if ! gh auth status >/dev/null 2>&1; then
    echo "  gh is not logged in. Log in with a one-time code (works from any device)."
    ask "Run 'gh auth login' now?" || { result pr SKIP "not logged in; open https://github.com/antiwong/ai-os/compare/main...$branch?expand=1"; return; }
    gh auth login || { result pr FAIL "gh auth login failed"; return; }
  fi
  url="$(cd "$ROOT" && gh pr view "$branch" --json url -q .url 2>/dev/null)"
  [ -n "$url" ] && { result pr PASS "already open: $url"; return; }
  ask "Open a pull request $branch -> main?" || { result pr SKIP "not run"; return; }
  url="$(cd "$ROOT" && gh pr create --base main --head "$branch" --title "Port ai-os to Ubuntu 26.04 desktop" --body-file - <<'EOF'
Runs the same repo on an Ubuntu 26.04 desktop (Ryzen 5800X, GTX 1080 on nvidia-driver-580, two 4K screens, ext4, GNOME fallback) next to the CachyOS laptop.

- Hyprland config is hyprlang (.conf) so it loads on Hyprland 0.53 from the Ubuntu archive.
- Install, verify and update scripts pick apt or pacman.
- Plain Hyprland login session works: env.conf adds ~/.local/bin to PATH.
- ai-os-update takes a timeshift snapshot before apt full-upgrade on a non-btrfs root.
- Fixes: display hotplug watcher, idle power profile, sandbox (podman), Bluetooth, missing-program messages.
- Docs: docs/ubuntu.md, docs/updates.md, docs/hotkeys.md.

Do not merge before the CachyOS laptop check (Hyprland 0.57): `scripts/06-manual-checks.sh config` on this branch.
Results of the hands-on checks (lock screen, suspend/resume) are in `~/.local/state/ai-os/manual-checks.log` on each machine.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)" && result pr PASS "$url" || result pr FAIL "gh pr create failed"
}

case "${1:-all}" in
  config)  step_config ;;
  lock)    step_lock ;;
  suspend) step_suspend ;;
  pr)      step_pr ;;
  all)     step_config; step_lock; step_suspend; step_pr ;;
  *)       sed -n '2,9p' "$0"; exit 2 ;;
esac

hdr "Summary (also in $LOG)"
printf '  %s\n' "${RESULTS[@]}"
