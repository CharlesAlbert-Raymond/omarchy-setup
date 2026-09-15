#!/bin/sh
# Native installer: drops into ~/.local/share/claude and self-updates, so this
# is a no-op once `claude` is on PATH. The omarchy repo also carries a
# `claude-code` package, but it would fight the native install over the binary.

if command -v claude >/dev/null 2>&1; then
  echo "claude code already installed ($(claude --version 2>/dev/null))"
else
  curl -fsSL https://claude.ai/install.sh | bash
fi
