#!/bin/sh

# Tooling
. ./install-stow.sh
. ./install-firacode-font.sh
. ./install-github-cli.sh
. ./install-pnpm.sh
. ./install-claude-code.sh
. ./install-docker-desktop.sh
. ./install-herdr.sh
. ./install-cameractrls.sh
. ./install-tether.sh

# Apps bound to ALT+<key> in webapps-omarchy.conf
. ./install-ghostty.sh
. ./install-google-chrome.sh
. ./install-slack.sh
. ./install-discord.sh
. ./install-claude-desktop.sh
. ./install-1password.sh
. ./install-webapps.sh

# Stock Omarchy apps not used here (needs ghostty installed first: it takes
# over as the default terminal from alacritty)
. ./uninstall-defaults.sh

# Config from ~/dotfiles, linked after the apps that read it are installed
. ./install-dotfiles.sh

# Hyprland config overrides (scaling, bindings)
. ./install-overrides.sh
