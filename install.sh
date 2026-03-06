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
STOW_PACKAGES=(fish git kitty lazygit mise nvim scripts shell tmux zsh)

stow_package() {
  local pkg="$1"
  [[ -d "$DOTFILES/$pkg" ]] || { log_warn "Package '$pkg' not found, skipping."; return; }

  log_step "Stowing $pkg..."

  # Remove conflicting regular files (not symlinks) before stowing.
  while IFS= read -r -d '' src; do
    local rel="${src#"$DOTFILES/$pkg/"}"
    local target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      log_warn "Removing conflicting file: $target"
      rm -f "$target"
    fi
  done < <(find "$DOTFILES/$pkg" -type f -print0)

  stow -R -d "$DOTFILES" -t "$HOME" "$pkg"
}

stow_all_packages() {
  log_info "Stowing packages..."
  for pkg in "${STOW_PACKAGES[@]}"; do
    stow_package "$pkg"
  done
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

main() {
  local os
  os="$(detect_os)"
  log_info "Detected OS: $os"
  install_system_packages "$os"
  stow_all_packages
  install_mise
  install_tools
  install_nvim "$os"
}

main "$@"
