#!/bin/sh
# Link the ~/dotfiles stow packages that apply to this Omarchy box. Left out on
# purpose: sway and rofi (wrong desktop), mac_zsh (wrong OS), waybar/background/
# desktop-portal (Omarchy owns those), and github-copilot (its package has no
# .config/ prefix, so stowing it would drop apps.json in the home directory).
# Safe to run repeatedly: --restow just refreshes the links.

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PACKAGES="herdr ghostty alacritty nvim starship git tmux linux_zsh"

command -v stow >/dev/null 2>&1 || { echo "stow missing, run install-stow.sh first" >&2; exit 1; }
[ -d "$DOTFILES_DIR" ] || { echo "missing $DOTFILES_DIR" >&2; exit 1; }

# Omarchy ships its own configs at some of these paths and stow aborts a package
# rather than overwrite a real file. Ask stow which targets block it -- walking
# the package tree ourselves would follow an already-stowed directory symlink
# and "back up" the repo's own files.
blockers() {
  stow -n -v --dir="$DOTFILES_DIR" --target="$HOME" --restow "$1" 2>&1 |
    sed -n 's/^ *\* cannot stow .* over existing target \(.*\) since neither a link nor a directory.*/\1/p'
}

for pkg in $PACKAGES; do
  if [ ! -d "$DOTFILES_DIR/$pkg" ]; then
    echo "dotfiles: no $pkg package, skipping"
    continue
  fi

  for rel in $(blockers "$pkg"); do
    target="$HOME/$rel"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      mv "$target" "$target.bak.$(date +%s)"
      echo "dotfiles: backed up $target"
    fi
  done

  if stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg"; then
    echo "dotfiles: $pkg linked"
  else
    echo "dotfiles: $pkg failed" >&2
  fi
done
