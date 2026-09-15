#!/bin/sh
# Link the Omarchy overrides into ~/.config/hypr and make hyprland.conf source
# them. Safe to run repeatedly: every step is a no-op once already applied.

SUPPLEMENTS_DIR="${SUPPLEMENTS_DIR:-$HOME/supplements}"
OVERRIDES_SRC="$SUPPLEMENTS_DIR/overrides-omarchy.conf"
OVERRIDES_LINK="$HOME/.config/hypr/overrides.conf"
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
SOURCE_LINE="source = ~/.config/hypr/overrides.conf"

[ -f "$OVERRIDES_SRC" ] || { echo "missing $OVERRIDES_SRC" >&2; exit 1; }
[ -f "$HYPRLAND_CONF" ] || { echo "missing $HYPRLAND_CONF" >&2; exit 1; }

# 1. Symlink, backing up anything real that sits in the way.
if [ "$(readlink "$OVERRIDES_LINK" 2>/dev/null)" = "$OVERRIDES_SRC" ]; then
  echo "overrides: link already in place"
else
  if [ -e "$OVERRIDES_LINK" ] || [ -L "$OVERRIDES_LINK" ]; then
    mv "$OVERRIDES_LINK" "$OVERRIDES_LINK.bak.$(date +%s)"
    echo "overrides: backed up existing $OVERRIDES_LINK"
  fi
  ln -s "$OVERRIDES_SRC" "$OVERRIDES_LINK"
  echo "overrides: linked $OVERRIDES_LINK -> $OVERRIDES_SRC"
fi

# 2. Source it from hyprland.conf, ahead of Omarchy's toggle flags.
if grep -qF "$SOURCE_LINE" "$HYPRLAND_CONF"; then
  echo "overrides: hyprland.conf already sources them"
else
  cp "$HYPRLAND_CONF" "$HYPRLAND_CONF.bak.$(date +%s)"
  if grep -qF "# Toggle config flags dynamically" "$HYPRLAND_CONF"; then
    awk -v line="$SOURCE_LINE" '
      /^# Toggle config flags dynamically/ && !ins {
        print "# Personal overrides, sourced last so they win over everything above"
        print line
        print ""
        ins = 1
      }
      { print }
    ' "$HYPRLAND_CONF" > "$HYPRLAND_CONF.tmp" && mv "$HYPRLAND_CONF.tmp" "$HYPRLAND_CONF"
  else
    printf '\n# Personal overrides, sourced last so they win over everything above\n%s\n' \
      "$SOURCE_LINE" >> "$HYPRLAND_CONF"
  fi
  echo "overrides: added source line to hyprland.conf"
fi

# 3. Reload and report any config errors.
if command -v hyprctl >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
  hyprctl reload >/dev/null
  errors=$(hyprctl configerrors)
  case "$errors" in
    ""|"no errors"*) echo "overrides: reloaded, no config errors" ;;
    *) echo "overrides: config errors after reload:" >&2; echo "$errors" >&2; exit 1 ;;
  esac
fi
