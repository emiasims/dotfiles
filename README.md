# dotfiles

Personal dotfiles managed with [GNU stow](https://www.gnu.org/software/stow/).

```
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## How it works

The installer is self-discovering — it finds packages and package managers by
globbing for config files rather than reading a central registry.

### System packages — `system/*.conf`

Each file in `system/` describes one package manager. The installer sources
every file and runs the first one whose `DETECT` command succeeds.

```bash
# system/apt.conf
DETECT="command -v apt-get"
COMMAND="sudo apt-get update -qq && sudo apt-get install -y"
PACKAGES=(stow git curl wget fish universal-ctags)
```

| Key        | Description |
|------------|-------------|
| `DETECT`   | Bash expression that exits 0 if this manager is available |
| `COMMAND`  | Install command (packages appended as arguments) |
| `PACKAGES` | Default package list; overridden by `-y pkg...` on the CLI |

### Dotfile packages — `<pkg>/package.conf`

A directory is a stow package if and only if it contains a `package.conf`
file. The file is sourced as bash; all keys are optional.

```bash
# Example: shell/package.conf
TARGET=~
FORCE=true
SETUP=setup.sh
```

| Key        | Default       | Description |
|------------|---------------|-------------|
| `TARGET`   | `~/.config`   | Directory stow symlinks into |
| `FORCE`    | `false`       | If `true`, remove conflicting regular files before stowing |
| `SETUP`    | _(none)_      | Script or shell command to run after stowing. If the value is a filename that exists in the package dir, it is executed with `bash`; otherwise it is `eval`'d as a shell command. The file is excluded from stow's symlinks automatically. |

## CLI reference

```
./install.sh [options]
```

With no options, all steps run for all packages.

| Option | Short | Args | Action |
|--------|-------|------|--------|
| `--system`  | `-y` | `[pkg...]` | Install system packages. Optional args override the conf's `PACKAGES` list. |
| `--package` | `-p` | `[pkg...]` | Stow dotfile packages. Optional args limit to those packages only. |
| `--mise`    | `-m` | | Install mise and run `mise install`. |
| `--nvim`    | `-n` | | Install Neovim via `update-nvim` (Linux only). |
| `--setup`   | `-s` | `[pkg...]` | Run `SETUP` hooks. Optional args limit to those packages only. |
| `--dry-run` | `-d` | | Simulate all steps without making changes. |
| `--help`    | `-h` | | Show usage. |

### Examples

```bash
# Full install
./install.sh

# Preview what a full install would do
./install.sh --dry-run

# Stow specific packages and run their setup hooks
./install.sh -p fish git nvim -s nvim

# Re-run setup hooks only (e.g. after updating a setup.sh)
./install.sh -s

# Install system packages, overriding the default list
./install.sh -y stow curl wget

# Install mise + tools + neovim only
./install.sh -m -n
```
