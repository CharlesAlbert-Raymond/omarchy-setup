#!/bin/sh
# Create the browser-based apps bound in webapps-omarchy.conf. Native apps have
# their own install-<app>.sh scripts. Safe to run repeatedly: an app is skipped
# once its desktop entry exists.

APPS_DIR="$HOME/.local/share/applications"

# name, url, [extra chrome flags] — icon is auto-fetched from the site favicon.
# Re-runs omarchy-webapp-install when the Exec line in the existing entry
# doesn't match, so flag changes here propagate to the launcher entry.
need_webapp() {
  exec_cmd="omarchy-launch-webapp $2${3:+ $3}"
  if grep -qxF "Exec=$exec_cmd" "$APPS_DIR/$1.desktop" 2>/dev/null; then
    echo "webapp: $1 already installed"
  else
    omarchy-webapp-install "$1" "$2" "" "$exec_cmd"
    echo "webapp: $1 installed"
  fi
}

# Pinned to the personal Chrome profile, same as the bindings in
# webapps-omarchy.conf (see the profile-dir note there).
need_webapp "Missive" "https://mail.missiveapp.com/#inbox" --profile-directory=Default
need_webapp "Apple Music" "https://music.apple.com/" --profile-directory=Default

# Bindings live in webapps-omarchy.conf, sourced via overrides-omarchy.conf.
if command -v hyprctl >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
  hyprctl reload >/dev/null
  errors=$(hyprctl configerrors)
  case "$errors" in
    ""|"no errors"*) echo "bindings: reloaded, no config errors" ;;
    *) echo "bindings: config errors after reload:" >&2; echo "$errors" >&2; exit 1 ;;
  esac
fi
