# ~/dotfiles

Personal dotfiles managed with GNU stow. Each top-level directory is a stow package (e.g. `fish/`, `git/`, `tmux/`).

No build system, linter, or test suite at the repo level.

## Commands

```bash
./install.sh              # full install (system pkgs + stow + mise + nvim + setup hooks)
./install.sh -d           # dry-run — shows what would happen
./install.sh -p fish git  # stow only specific packages
./install.sh -s shell     # run only setup hooks for specific packages
```

For full CLI reference, see `README.md`.

## Architecture pointers

- For stow package config keys (`TARGET`, `FORCE`, `SETUP`), see `README.md` > "Dotfile packages".
- For system package manager detection, see `system/*.conf`.
- For utility scripts available on `$PATH`, see `scripts/bin/`.

## Code conventions

- **Commit prefixes:** `add:`, `fix:`, `rm:`, `update:`, `WIP` (no scope, lowercase after prefix).
- **Shell:** `bash` with `set -euo pipefail`. No linter enforced — check quoting and `shellcheck` mentally.
- **Stow layout:** a package `foo` targeting `~/.config` lives at `foo/foo/` so stow creates `~/.config/foo`.

## Boundaries

- **Scope isolation.** Treat each stow package as independent. Read other packages' configs only when the task explicitly requires cross-package work.
- **Ask first:** adding new stow packages, changing `package.conf` keys, modifying `install.sh` control flow.
- **Never** edit files under `system/` without confirming the user's OS and package manager. Check `system/*.conf` to see what exists instead.

## Gotchas

- `.gitattributes` applies a `filter=ignore_lines` smudge/clean filter repo-wide — lines may silently vanish from diffs if the filter is active.
- Packages targeting `~` (e.g. `shell`, `zsh`, `tmux`) use `TARGET=~` and `FORCE=true` — stow will **delete** conflicting regular files at the target before symlinking.
