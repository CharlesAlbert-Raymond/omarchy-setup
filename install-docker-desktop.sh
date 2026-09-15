#!/bin/sh
# Omarchy installs the Docker engine, CLI, compose and buildx, but not Docker
# Desktop. The AUR package bundles its own compose/buildx/debug/mcp/scout CLI
# plugins, so it conflicts with the standalone packages Omarchy pulled in --
# and with --noconfirm pacman answers "no" to the conflict prompt and aborts.
# Remove them first; docker-desktop provides equivalents for all of them.

if pacman -Qq docker-desktop >/dev/null 2>&1; then
  echo "docker-desktop already installed"
else
  conflicts=""
  for pkg in docker-compose docker-buildx docker-debug docker-mcp docker-scout; do
    pacman -Qq "$pkg" >/dev/null 2>&1 && conflicts="$conflicts $pkg"
  done
  # -Rdd because nothing else on an Omarchy box requires these, and the
  # replacements arrive in the very next transaction.
  [ -n "$conflicts" ] && sudo pacman -Rdd --noconfirm $conflicts

  yay -S --noconfirm --needed docker-desktop

  # The package's post_install adds the subuid/subgid ranges and enables the
  # docker-desktop user service. It runs its own VM, reachable through the
  # "desktop-linux" docker context; "docker context use default" goes back to
  # the native daemon Omarchy set up.
  echo "docker-desktop installed -- launch it once, then: docker context ls"
fi
