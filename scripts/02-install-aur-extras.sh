#!/usr/bin/env bash
# Step 2 (optional): Walker launcher. Walker 2.x needs the 'elephant' backend, which is AUR-only.
# fuzzel from step 1 is the default launcher; skip this if you are happy with it.
set -euo pipefail
[ "$EUID" -ne 0 ] || { echo "Run as your user, not root."; exit 1; }

echo "AUR packages run external build code. Review the PKGBUILD when paru shows it."
sudo pacman -S --needed walker
paru -S --needed elephant-all-bin  # core + all official providers; Walker is empty without providers
