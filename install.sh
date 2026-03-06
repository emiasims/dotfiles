#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[0;33m'
RST='\033[0m'

log_info()  { echo -e "${GRN}==>${RST} $*"; }
log_step()  { echo -e "${YLW} ->${RST} $*"; }
log_warn()  { echo -e "${YLW}[warn]${RST} $*"; }
log_error() { echo -e "${RED}[error]${RST} $*" >&2; }

# ── OS detection ──────────────────────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "macos" ;;
    *)       log_error "Unsupported OS: $(uname -s)"; exit 1 ;;
  esac
}

# ── System packages ───────────────────────────────────────────────────────────
SYSTEM_PACKAGES=(stow git curl wget fish universal-ctags)

install_system_packages() {
  local os="$1"
  log_info "Installing system packages: ${SYSTEM_PACKAGES[*]}"

  if [[ "$os" == "linux" ]]; then
    sudo apt-get update -qq
    sudo apt-get install -y "${SYSTEM_PACKAGES[@]}"

  elif [[ "$os" == "macos" ]]; then
    if ! command -v brew &>/dev/null; then
      log_error "Homebrew not found. Install it first: https://brew.sh"
      exit 1
    fi
    brew install "${SYSTEM_PACKAGES[@]}"
  fi

  log_info "System packages installed."
}

# ── Stow ──────────────────────────────────────────────────────────────────────

# Remove conflicting regular files at $HOME/$rel for top-level files only.
# Used for packages that place dotfiles directly in $HOME (shell, zsh).
remove_home_conflicts() {
  local pkg="$1"
  while IFS= read -r -d '' src; do
    local rel="${src#"$DOTFILES/$pkg/"}"
    local dest="$HOME/$rel"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
      log_warn "Removing conflicting file: $dest"
      rm -f "$dest"
    fi
  done < <(find "$DOTFILES/$pkg" -maxdepth 1 -type f -print0)
}

stow_package() {
  local pkg="$1"
  local target="${2:-$HOME}"
  [[ -d "$DOTFILES/$pkg" ]] || { log_warn "Package '$pkg' not found, skipping."; return; }
  log_step "Stowing $pkg..."
  stow -R -d "$DOTFILES" -t "$target" "$pkg"
}

stow_all_packages() {
  log_info "Stowing packages..."
  remove_home_conflicts shell;   stow_package shell
  remove_home_conflicts zsh;     stow_package zsh
  stow_package fish    "$HOME/.config"
  stow_package git     "$HOME/.config"
  stow_package kitty   "$HOME/.config"
  stow_package lazygit "$HOME/.config"
  stow_package mise    "$HOME/.config"
  stow_package nvim    "$HOME/.config"
  stow_package scripts "$HOME/.local"
  stow_package tmux
  log_info "Stow complete."
}

# ── mise ──────────────────────────────────────────────────────────────────────
MISE_BIN="$HOME/.local/bin/mise"

install_mise() {
  if [[ -x "$MISE_BIN" ]]; then
    log_info "mise already installed: $("$MISE_BIN" --version)"
    return
  fi
  log_info "Installing mise..."
  curl -fsSL https://mise.run | sh
  log_info "mise installed: $("$MISE_BIN" --version)"
}

install_tools() {
  local config="$HOME/.config/mise/config.toml"
  if [[ ! -f "$config" ]]; then
    log_error "mise config not found at $config. Was the 'mise' package stowed?"
    exit 1
  fi
  log_info "Installing tools via mise..."
  "$MISE_BIN" install
  log_info "Tools installed."
}

# ── Configure ─────────────────────────────────────────────────────────────────

setup_fish_shell() {
  local fish_path
  fish_path="$(command -v fish 2>/dev/null)" || { log_warn "fish not found, skipping shell setup."; return; }
  if [[ "$SHELL" == "$fish_path" ]]; then
    log_info "fish is already the default shell."
    return
  fi
  log_info "Setting fish as default shell..."
  if ! grep -qF "$fish_path" /etc/shells; then
    log_step "Adding $fish_path to /etc/shells..."
    echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
  fi
  chsh -s "$fish_path"
  log_info "Default shell set to fish."
}

setup_nvim_plugins() {
  local nvim_bin="$HOME/.local/bin/nvim"
  if [[ ! -x "$nvim_bin" ]]; then
    log_warn "nvim not found at $nvim_bin, skipping plugin sync."
    return
  fi
  log_info "Syncing Neovim plugins..."
  "$nvim_bin" --headless "+Lazy! sync" +qa
  log_info "Neovim plugins synced."
}

setup_uv_venv() {
  local venv="$1"
  shift
  if [[ -d "$venv" ]]; then
    log_info "venv already exists: $venv"
    return
  fi
  log_info "Creating venv: $venv"
  "$MISE_BIN" exec -- uv venv "$venv" --seed --color never
  "$venv/bin/pip" install --quiet "$@"
  log_info "venv ready: $venv"
}

setup_fonts() {
  local fonts_dir="$HOME/.local/share/fonts"
  local sentinel="$fonts_dir/SymbolsNerdFontMono-Regular.ttf"
  if [[ -f "$sentinel" ]]; then
    log_info "Nerd Fonts Symbols already installed."
    return
  fi
  log_info "Installing Nerd Fonts Symbols..."
  mkdir -p "$fonts_dir"
  local tmp
  tmp="$(mktemp --suffix=.tar.xz)"
  wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz" -O "$tmp"
  tar -C "$fonts_dir" -xJf "$tmp" --wildcards '*.ttf'
  rm -f "$tmp"
  log_info "Nerd Fonts Symbols installed."
}

configure() {
  log_info "Configuring..."
  setup_fish_shell
  setup_nvim_plugins
  setup_uv_venv "$HOME/.local/share/venv/base"        ipython pipx
  setup_uv_venv "$HOME/.local/share/nvim/venv"        pynvim
  setup_fonts
  log_info "Configuration complete."
}

# ── Neovim ────────────────────────────────────────────────────────────────────
install_nvim() {
  local os="$1"
  if [[ "$os" != "linux" ]]; then
    log_warn "Neovim install via update-nvim is Linux-only. Skipping."
    return
  fi
  local update_nvim="$HOME/.local/bin/update-nvim"
  if [[ ! -x "$update_nvim" ]]; then
    log_error "update-nvim not found at $update_nvim. Was the scripts package stowed?"
    exit 1
  fi
  log_info "Installing neovim..."
  "$update_nvim"
  log_info "Neovim installed."
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [flags]

With no flags, runs all install steps.

Flags:
  -p, --packages   Install system packages (apt / brew)
  -s, --stow       Stow dotfiles into \$HOME
  -m, --mise       Install mise and all tools
  -n, --nvim       Install neovim (Linux only)
  -c, --configure  Post-install configuration (plugins, shell, venvs, fonts)
  -h, --help       Show this help
EOF
}

main() {
  local os
  os="$(detect_os)"

  local do_packages=false do_stow=false do_mise=false do_nvim=false do_configure=false
  local any=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--packages)  do_packages=true;  any=true ;;
      -s|--stow)      do_stow=true;      any=true ;;
      -m|--mise)      do_mise=true;      any=true ;;
      -n|--nvim)      do_nvim=true;      any=true ;;
      -c|--configure) do_configure=true; any=true ;;
      -h|--help)      usage; exit 0 ;;
      *) log_error "Unknown flag: $1"; usage; exit 1 ;;
    esac
    shift
  done

  if [[ "$any" == false ]]; then
    do_packages=true; do_stow=true; do_mise=true; do_nvim=true; do_configure=true
  fi

  log_info "Detected OS: $os"
  [[ "$do_packages"  == true ]] && install_system_packages "$os"
  [[ "$do_stow"      == true ]] && stow_all_packages
  [[ "$do_mise"      == true ]] && { install_mise; install_tools; }
  [[ "$do_nvim"      == true ]] && install_nvim "$os"
  [[ "$do_configure" == true ]] && configure
}

main "$@"
