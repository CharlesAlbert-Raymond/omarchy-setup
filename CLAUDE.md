# supplements

Idempotent post-install setup for this Omarchy box. Running `master-install.sh`
on a fresh install must produce the same machine every time, and running it
again on an already-configured machine must change nothing.

## Layout

- `master-install.sh` — the only entry point. Sources every script in order.
- `install-<name>.sh` — one script per thing installed, `#!/bin/sh`, POSIX sh.
- `uninstall-defaults.sh` — removes stock Omarchy apps not used here.
- `*-omarchy.conf` — Hyprland config linked into `~/.config/hypr` by the
  matching `install-*.sh`.

## Adding something

1. Create `install-<name>.sh` with `#!/bin/sh`, `chmod +x`.
2. Make it a no-op when already applied: `yay -S --noconfirm --needed` for
   packages; an explicit `command -v` / `pacman -Qq` / file check otherwise,
   printing `<name>: already installed` on the skip path.
3. Add `. ./install-<name>.sh` to `master-install.sh` under the right section,
   after anything it depends on (comment the dependency).
4. Have the user run the script twice; the second run must print only
   "already" messages.

## Running scripts

Most scripts call `yay`/`pacman`, which prompt for sudo. Don't run them
yourself: hand the exact command to the user (`! ./install-<name>.sh`) and
read the output they paste back. Only scripts that touch nothing outside
`$HOME` (`install-overrides.sh`, `install-webapps.sh`, `install-dotfiles.sh`)
are safe to run directly.

Explain non-obvious choices (conflicts, why one package over another) in a
header comment of the script, not here.
