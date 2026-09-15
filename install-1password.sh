#!/bin/sh
# 1password and 1password-beta both ship /usr/bin/1password, so installing the
# stable package over an existing beta fails on a file conflict. Skip if either
# is already providing the binary.

if command -v 1password >/dev/null 2>&1; then
  echo "1password already installed ($(pacman -Qoq /usr/bin/1password 2>/dev/null))"
else
  yay -S --noconfirm --needed 1password
fi
