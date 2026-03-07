#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[0;33m'
CYN='\033[0;36m'
RST='\033[0m'

log_info()  { echo -e "${GRN}==>${RST} $*"; }
log_step()  { echo -e "${YLW} ->${RST} $*"; }
log_warn()  { echo -e "${YLW}[warn]${RST} $*"; }
log_error() { echo -e "${RED}[error]${RST} $*" >&2; }
log_dry()   { echo -e "${CYN}[dry-run]${RST} would run: $*"; }

# ── Globals ───────────────────────────────────────────────────────────────────
DRY_RUN=false

# ── OS detection ──────────────────────────────────────────────────────────────
get_pretty_os_name() {
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    echo "${PRETTY_NAME:-$NAME}"
  elif command -v lsb_release &>/dev/null; then
    lsb_release -d | cut -f2-
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    sw_vers -productName && sw_vers -productVersion | tr '\n' ' ' | xargs
  else
    uname -s
  fi
}

# ── System packages ───────────────────────────────────────────────────────────
# $@: optional package list override (replaces conf PACKAGES)
install_system_packages() {
  local override=("$@")
  local conf_dir="$DOTFILES/system"
  [[ -d "$conf_dir" ]] || { log_error "system/ directory not found"; exit 1; }

  local conf
  for conf in "$conf_dir"/*.conf; do
    [[ -f "$conf" ]] || continue
    unset DETECT COMMAND PACKAGES
    # shellcheck source=/dev/null
    source "$conf"
    if eval "${DETECT:-false}" &>/dev/null; then
      local pkgs=("${override[@]:-${PACKAGES[@]}}")
      log_info "Installing system packages via: $COMMAND"
      if [[ "$DRY_RUN" == true ]]; then
        log_dry "$COMMAND ${pkgs[*]}"
      else
        eval "$COMMAND ${pkgs[*]@Q}"
      fi
      log_info "System packages installed."
      return 0
    fi
  done

  log_warn "No supported package manager found"
}

# ── Stow ──────────────────────────────────────────────────────────────────────

# Remove conflicting regular files at $target/$rel for top-level files only.
# Used for packages with FORCE=true (e.g. shell, zsh).
remove_home_conflicts() {
  local pkg="$1" target="$2"
  while IFS= read -r -d '' src; do
    local rel="${src#"$DOTFILES/$pkg/"}"
    local dest="$target/$rel"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
      if [[ "$DRY_RUN" == true ]]; then
        log_dry "rm -f $dest  (conflicting file)"
      else
        log_warn "Removing conflicting file: $dest"
        rm -f "$dest"
      fi
    fi
  done < <(find "$DOTFILES/$pkg" -maxdepth 1 -type f -print0)
}

stow_package() {
  local pkg="$1"
  local target="${2:-$HOME}"
  local extra_ignore="${3:-}"
  [[ -d "$DOTFILES/$pkg" ]] || { log_warn "Package '$pkg' not found, skipping."; return; }
  log_step "Stowing $pkg -> $target..."
  local stow_args=(-R --ignore='package\.conf')
  [[ -n "$extra_ignore" ]] && stow_args+=(--ignore="$extra_ignore")
  [[ "$DRY_RUN" == true ]] && stow_args+=(--simulate)
  stow "${stow_args[@]}" -d "$DOTFILES" -t "$target" "$pkg"
}

run_setup() {
  local pkg="$1" setup="$2"
  [[ -z "$setup" ]] && return
  if [[ -f "$DOTFILES/$pkg/$setup" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "bash $DOTFILES/$pkg/$setup"
    else
      log_step "Running setup for $pkg..."
      bash "$DOTFILES/$pkg/$setup"
    fi
  else
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "eval: $setup  (setup for $pkg)"
    else
      log_step "Running setup for $pkg: $setup"
      eval "$setup"
    fi
  fi
}

# Stow one package by name, sourcing its package.conf for settings.
stow_one() {
  local pkg="$1"
  local pkg_conf="$DOTFILES/$pkg/package.conf"
  if [[ ! -f "$pkg_conf" ]]; then
    log_warn "No package.conf for '$pkg', skipping."
    return
  fi

  local TARGET=~/.config FORCE=false STOW_OPTS= SETUP=
  # shellcheck source=/dev/null
  source "$pkg_conf"

  local target="${TARGET/#\~/$HOME}"
  [[ "$FORCE" == true ]] && remove_home_conflicts "$pkg" "$target"

  local setup_ignore=
  [[ -n "$SETUP" && -f "$DOTFILES/$pkg/$SETUP" ]] && setup_ignore="$SETUP"

  stow_package "$pkg" "$target" "$setup_ignore"
  run_setup "$pkg" "$SETUP"
}

# $@: optional list of packages to stow (empty = all)
stow_all_packages() {
  local filter=("$@")
  log_info "Stowing packages..."

  if [[ ${#filter[@]} -gt 0 ]]; then
    local pkg
    for pkg in "${filter[@]}"; do
      stow_one "$pkg"
    done
  else
    local pkg_conf
    for pkg_conf in "$DOTFILES"/*/package.conf; do
      [[ -f "$pkg_conf" ]] || continue
      local pkg
      pkg="$(basename "$(dirname "$pkg_conf")")"
      stow_one "$pkg"
    done
  fi

  log_info "Stow complete."
}

# ── mise ──────────────────────────────────────────────────────────────────────
MISE_BIN="$HOME/.local/bin/mise"

install_mise() {
  if [[ -x "$MISE_BIN" ]]; then
    log_info "mise already installed: $("$MISE_BIN" --version)"
    return
  fi
  if [[ "$DRY_RUN" == true ]]; then
    log_dry "curl -fsSL https://mise.run | sh"
    return
  fi
  log_info "Installing mise..."
  curl -fsSL https://mise.run | sh
  log_info "mise installed: $("$MISE_BIN" --version)"
}

install_tools() {
  local config="$HOME/.config/mise/config.toml"
  if [[ ! -f "$config" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "$MISE_BIN install  (skipping: mise config not yet stowed)"
      return
    fi
    log_error "mise config not found at $config. Was the 'mise' package stowed?"
    exit 1
  fi
  if [[ "$DRY_RUN" == true ]]; then
    log_dry "$MISE_BIN install"
    return
  fi
  log_info "Installing tools via mise..."
  "$MISE_BIN" install
  log_info "Tools installed."
}

# ── Configure ─────────────────────────────────────────────────────────────────
# $@: optional list of packages to run setup for (empty = all)
configure() {
  local filter=("$@")
  log_info "Running setup hooks..."

  local run_for=()
  if [[ ${#filter[@]} -gt 0 ]]; then
    run_for=("${filter[@]}")
  else
    local pkg_conf
    for pkg_conf in "$DOTFILES"/*/package.conf; do
      [[ -f "$pkg_conf" ]] || continue
      run_for+=("$(basename "$(dirname "$pkg_conf")")")
    done
  fi

  local pkg
  for pkg in "${run_for[@]}"; do
    local pkg_conf="$DOTFILES/$pkg/package.conf"
    [[ -f "$pkg_conf" ]] || { log_warn "No package.conf for '$pkg', skipping setup."; continue; }
    local TARGET=~/.config FORCE=false STOW_OPTS= SETUP=
    # shellcheck source=/dev/null
    source "$pkg_conf"
    run_setup "$pkg" "$SETUP"
  done

  log_info "Configuration complete."
}

# ── Neovim ────────────────────────────────────────────────────────────────────
install_nvim() {
  if command -v sw_vers &>/dev/null; then
    log_warn "Neovim install via update-nvim is Linux-only. Skipping."
    return
  fi
  local update_nvim="$HOME/.local/bin/update-nvim"
  if [[ ! -x "$update_nvim" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "$update_nvim  (skipping: not yet installed)"
      return
    fi
    log_error "update-nvim not found at $update_nvim. Was the scripts package stowed?"
    exit 1
  fi
  if [[ "$DRY_RUN" == true ]]; then
    log_dry "$update_nvim"
    return
  fi
  log_info "Installing neovim..."
  "$update_nvim"
  log_info "Neovim installed."
}

# ── Usage ─────────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

With no options, runs all install steps for all packages.

Options:
  -y [pkg...], --system [pkg...]   Install system packages via detected manager.
                                   Optionally override the package list.
  -p [pkg...], --package [pkg...]  Stow dotfile packages (symlink into place).
                                   Optionally limit to specific packages.
  -m,          --mise              Install mise and all tools via \`mise install\`.
  -n,          --nvim              Install Neovim (Linux only).
  -s [pkg...], --setup [pkg...]    Run per-package setup hooks (SETUP= in package.conf).
                                   Optionally limit to specific packages.
  -d,          --dry-run           Simulate: show what would happen without doing it.
  -h,          --help              Show this help.

Examples:
  $(basename "$0")                        # full install
  $(basename "$0") -d                     # dry-run of full install
  $(basename "$0") -p fish git -s shell   # stow fish + git, run shell's setup hook
  $(basename "$0") -y                     # install system packages from conf
  $(basename "$0") -y stow curl wget      # install only stow, curl, wget
  $(basename "$0") -m -n                  # install mise + tools + neovim
EOF
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  local os_name
  os_name="$(get_pretty_os_name)"

  local do_system=false  system_pkgs=()
  local do_stow=false    stow_pkgs=()
  local do_mise=false
  local do_nvim=false
  local do_setup=false   setup_pkgs=()
  local any=false

  # Parse flags, collecting optional trailing package args for each flag.
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -y|--system)
        do_system=true; any=true; shift
        while [[ $# -gt 0 && "$1" != -* ]]; do system_pkgs+=("$1"); shift; done
        ;;
      -p|--package)
        do_stow=true; any=true; shift
        while [[ $# -gt 0 && "$1" != -* ]]; do stow_pkgs+=("$1"); shift; done
        ;;
      -m|--mise)
        do_mise=true; any=true; shift
        ;;
      -n|--nvim)
        do_nvim=true; any=true; shift
        ;;
      -s|--setup)
        do_setup=true; any=true; shift
        while [[ $# -gt 0 && "$1" != -* ]]; do setup_pkgs+=("$1"); shift; done
        ;;
      -d|--dry-run)
        DRY_RUN=true; shift
        ;;
      -h|--help)
        usage; exit 0
        ;;
      *)
        log_error "Unknown option: $1"; usage; exit 1
        ;;
    esac
  done

  if [[ "$any" == false ]]; then
    do_system=true; do_stow=true; do_mise=true; do_nvim=true; do_setup=true
  fi

  [[ "$DRY_RUN" == true ]] && log_info "Dry-run mode — no changes will be made."
  log_info "Detected OS: $os_name"

  [[ "$do_system" == true ]] && install_system_packages "${system_pkgs[@]}"
  [[ "$do_stow"   == true ]] && stow_all_packages       "${stow_pkgs[@]}"
  [[ "$do_mise"   == true ]] && { install_mise; install_tools; }
  [[ "$do_nvim"   == true ]] && install_nvim
  [[ "$do_setup"  == true ]] && configure                "${setup_pkgs[@]}"
}

main "$@"
