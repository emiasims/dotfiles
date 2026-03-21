---
name: managing-dotfiles
description: You MUST use this skill when working in ~/dotfiles. NEVER invoke this skill in subdirectories (e.g. ~/dotfiles/nvim or ~/dotfiles/*)
---

# Managing Dotfiles

Personal dotfiles managed with [GNU stow](https://www.gnu.org/software/stow/).
Stow creates symlinks from target directories back into `~/dotfiles/<pkg>/`.

## Commands

No build system, linter, or test suite. The main entry point is `install.sh`.

```bash
./install.sh              # full install (system pkgs + stow + mise + nvim + setup hooks)
./install.sh -d           # dry-run — shows what would happen
./install.sh -p fish git  # stow only specific packages
./install.sh -s shell     # run only setup hooks for specific packages
```

## How Stow Packages Work

A directory is a stow package if it contains `package.conf`. The conf is
sourced as bash and may declare:

| Variable | Default     | Purpose                                       |
|----------|-------------|-----------------------------------------------|
| `TARGET` | `~/.config` | Where stow symlinks into                      |
| `FORCE`  | `false`     | If true, removes conflicting non-symlink files |
| `SETUP`  | (empty)     | Script or command to run after stowing         |

An empty `package.conf` means "stow into `~/.config` with no setup hook".

Notable non-default targets:
- `TARGET=~` with `FORCE=true` — places dotfiles directly in `$HOME`
- `TARGET=~/.local` — places files in `~/.local/bin/`

## System Packages

`system/*.conf` files declare a package manager. Each conf is sourced as bash
and sets `DETECT` (binary to check for), `COMMAND` (install command), and
`PACKAGES` (array). The installer uses the first conf whose `DETECT` binary
exists on `$PATH`.

## Key Relationships

- `scripts/` must be stowed before `install_nvim` works (`update-nvim` lives there)
- `mise/` must be stowed before `install_tools` works (mise reads `~/.config/mise/config.toml`)
- `shell/setup.sh` sets fish as default shell — needs fish installed first

## Conventions

### Idempotency
- All scripts and setup hooks must be safe to run repeatedly
- Check before acting: skip if already installed, already configured, already the default, etc.
- When a required tool isn't installed yet, `setup.sh` should warn and `exit 0` rather than fail

### Bash
- All scripts use `set -euo pipefail` (some omit `-u`) and `IFS=$'\n\t'`
- Shebangs: `#!/usr/bin/env bash`
- `setup.sh` scripts exit gracefully (exit 0 with a warning) when their tool isn't installed yet

### Repository
- Do not add files to `.gitignore` without reason
- `.gitattributes` uses a custom `ignore_lines` filter
- No build, lint, or test commands — this is a config/symlink repository
- Don't explore package config files (fish, nvim, kitty, etc.) deeply unless the task specifically involves that package's configuration

### When Adding a New Package
1. Create `<pkg>/package.conf` (empty if defaults are fine)
2. Place config files mirroring their target directory structure
3. If post-stow setup is needed, add a `setup.sh` and set `SETUP=setup.sh`
4. The installer discovers packages automatically — no registration needed
