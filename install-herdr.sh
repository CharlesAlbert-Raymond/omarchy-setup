#!/bin/sh
# Herdr ships in Omarchy's own pacman repo. Take the plain `herdr` package, not
# omarchy-herdr: 0.8.2 replaces that older fork, so the Omarchy pane border
# support is already folded in. Its config comes from ~/dotfiles via
# install-dotfiles.sh.

yay -S --noconfirm --needed herdr
