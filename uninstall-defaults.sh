#!/bin/sh
# Remove the stock Omarchy apps that aren't used on this box. Everything listed
# here ships with a fresh Omarchy install (see omarchy-base.packages and
# install/packaging/webapps.sh under ~/.local/share/omarchy/install/), so it
# comes back on reinstall and this has to be replayable. Safe to run
# repeatedly: packages and web apps already gone are skipped.
#
# Apps installed by hand (Zen, Superset, T3Chat) were removed once by hand and
# have no script: nothing reinstalls them.

APPS_DIR="$HOME/.local/share/applications"

# Alacritty is Omarchy's default terminal. Point xdg-terminal-exec at Ghostty
# before the package goes so SUPER+RETURN keeps working.
if ! pacman -Qq ghostty >/dev/null 2>&1; then
  echo "uninstall: ghostty missing, run install-ghostty.sh first" >&2
  exit 1
fi
if [ "$(omarchy-default-terminal)" = "ghostty" ]; then
  echo "terminal: ghostty already the default"
else
  omarchy-default-terminal ghostty
  echo "terminal: default switched to ghostty"
fi

# Omarchy copies its own Alacritty.desktop into the user dir (see
# omarchy-upgrade-to-quattro), which pacman doesn't know about, so it would
# stay behind as a dead launcher entry.
if [ -f "$APPS_DIR/Alacritty.desktop" ]; then
  rm "$APPS_DIR/Alacritty.desktop"
  echo "launcher: Alacritty.desktop removed"
fi

# Packages from omarchy-base.packages. -Rns also drops the dependencies
# nothing else needs (kdenlive pulls in a pile of KDE frameworks).
drop=""
for pkg in aether alacritty cliamp kdenlive obsidian signal-desktop spotify; do
  if pacman -Qq "$pkg" >/dev/null 2>&1; then
    drop="$drop $pkg"
  else
    echo "pkg: $pkg already removed"
  fi
done
if [ -n "$drop" ]; then
  sudo pacman -Rns --noconfirm $drop
  echo "pkg: removed$drop"
fi

# Web apps from install/packaging/webapps.sh. One call: the remover restarts
# walker every time it runs.
webapps=""
for app in ChatGPT GitHub YouTube Zoom; do
  if [ -f "$APPS_DIR/$app.desktop" ]; then
    webapps="$webapps $app"
  else
    echo "webapp: $app already removed"
  fi
done
if [ -n "$webapps" ]; then
  omarchy-webapp-remove $webapps
fi

# Their stock SUPER+SHIFT bindings are unbound in overrides-omarchy.conf.
