# Updating and rolling back

## Routine
`ai-os-update` (also: `SUPER+ESCAPE` -> Update)

1. Lists pending updates (repo / AUR / flatpak) and highlights kernel, mesa, systemd, hyprland.
2. Takes named snapper snapshots of `root` and `home` ("ai-os-update <date>"). snap-pac also adds its own pre/post pair around the pacman run.
3. `paru -Syu`, then `flatpak update`, then re-links dotfiles.
4. Health report: reboot needed (kernel), `.pacnew` files, orphans, failed units. It only reports; it removes nothing.

Options: `--check` (list only, changes nothing), `--nvim` (also update neovim plugins; review the `lazy-lock.json` diff), `-y` (no prompt).
Read the Arch news before big updates: https://archlinux.org/news/ and CachyOS announcements.

## After updating
- `.pacnew` files: `sudo pacdiff` (merge, don't ignore: stale `pacman.conf`/mirrorlists cause slow or broken updates).
- Orphans: review `pacman -Qtdq`, then `sudo pacman -Rns $(pacman -Qtdq)` if they really are unused.
- Reboot if the kernel changed.

## Rolling back (pick the smallest tool that works)

**One bad package** (desktop still boots):
```
sudo pacman -U /var/cache/pacman/pkg/<package>-<old-version>.pkg.tar.zst
```
Add the package to `IgnorePkg` in `/etc/pacman.conf` until fixed upstream.

**Bad flatpak:** `flatpak update --commit=<hash> <app-id>` (list hashes with `flatpak remote-info --log flathub <app-id>`).

**Config/dotfile mistake:** it is all in git: `git -C ~/code/ai-os log -p -- config/<path>` then `git checkout <commit> -- config/<path>`.

**Files changed since a snapshot** (selective, no reboot):
```
snapper -c root list                      # find the "ai-os-update" pair
snapper -c root status <from>..<to>       # what changed
sudo snapper -c root undochange <from>..<to> [paths]
```
Same for `-c home`.

**System won't boot or is badly broken** (full rollback; these steps follow the standard snapper/limine flow and have **not been tried on this machine**):
1. At the Limine boot menu choose a snapshot entry (limine-snapper-sync lists them), pick the one from before the update, boot it.
2. If it works, make it permanent: `sudo snapper -c root rollback <number>` (or use btrfs-assistant -> Restore), then reboot.
3. Fallback: boot the LTS kernel (`linux-cachyos-lts`) from the Limine menu, or a live USB and `arch-chroot`.

`home` snapshots are separate: rolling back `root` does not touch `/home`.

## Snapshot hygiene
Timeline snapshots are on (5 hourly / 7 daily / 2 weekly, cleanup timer enabled by `scripts/04-setup-snapper.sh`). Named `ai-os-update` snapshots use the "number" cleanup algorithm and are pruned automatically. List with `snapper -c root list`; delete with `snapper -c root delete <n>`.

## Ubuntu desktop (ext4 root, timeshift)

There is no snapper here. `ai-os-update` takes a timeshift snapshot in rsync mode before `apt full-upgrade`
(comment "ai-os-update <date>") and keeps the two newest. Setup is done by `scripts/01-install-hyprland.sh`
(`/etc/timeshift/timeshift.json`, scheduled snapshots off).

- **What a snapshot holds**: the OS (packages, `/etc`, `/usr`, `/opt`, `/var/lib`). Left out: `/home`, `/root`,
  `/var/log`, the swap file, docker/podman storage. Snapshots live in `/timeshift` on the root disk, so they
  cover a bad update, not a dead disk.
- **Space**: the first snapshot is a full copy; later ones hardlink unchanged files. `ai-os-update` skips the
  snapshot (with a warning) when `/` has less than 10 GB free, or less than 30 GB when no snapshot exists yet.
- **List / delete**: `sudo timeshift --list`, `sudo timeshift --delete --snapshot <name>`.
- **One bad package**: `apt list -a <package>`, then `sudo apt install <package>=<old-version>` and
  `sudo apt-mark hold <package>`.
- **Roll the system back** (desktop still boots; **not tried on this machine**):
  `sudo timeshift --restore --snapshot <name>`, then reboot. `/home` is not touched.
- **System won't boot** (**not tried on this machine**): boot an Ubuntu live USB, install timeshift there, run
  `sudo timeshift --restore --snapshot-device /dev/nvme0n1p2` and pick the snapshot.
