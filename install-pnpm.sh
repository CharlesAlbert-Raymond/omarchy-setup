#!/bin/sh
# The extra/pnpm package pulls in nodejs as a dependency, so this also covers
# node itself. Preferred over pnpm's standalone installer, which drops a
# self-updating binary into ~/.local/share/pnpm that pacman can't track.

yay -S --noconfirm --needed pnpm
