#!/bin/sh
# Native client instead of the Chrome web app: Chrome's PipeWire camera path
# opens the wrong device when more than one webcam is attached (picks the
# integrated camera even with the C920 selected). The native client opens
# /dev/video* directly and doesn't have that problem.

yay -S --noconfirm --needed discord

# Retire the web app entry from before the switch, if it's still around.
if [ -f "$HOME/.local/share/applications/Discord.desktop" ]; then
  omarchy-webapp-remove Discord
  echo "webapp: Discord removed (replaced by native client)"
fi
