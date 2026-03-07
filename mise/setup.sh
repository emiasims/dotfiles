#!/usr/bin/env bash
set -euo pipefail

MISE_BIN="$HOME/.local/bin/mise"

setup_uv_venv() {
  local venv="$1"; shift
  if [[ -d "$venv" ]]; then
    echo "venv already exists: $venv"
    return
  fi
  echo "Creating venv: $venv"
  "$MISE_BIN" exec -- uv venv "$venv" --seed --color never
  "$venv/bin/pip" install --quiet "$@"
  echo "venv ready: $venv"
}

setup_fonts() {
  local fonts_dir="$HOME/.local/share/fonts"
  local sentinel="$fonts_dir/SymbolsNerdFontMono-Regular.ttf"
  if [[ -f "$sentinel" ]]; then
    echo "Nerd Fonts Symbols already installed."
    return
  fi
  echo "Installing Nerd Fonts Symbols..."
  mkdir -p "$fonts_dir"
  local tmp
  tmp="$(mktemp --suffix=.tar.xz)"
  wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz" -O "$tmp"
  tar -C "$fonts_dir" -xJf "$tmp" --wildcards '*.ttf'
  rm -f "$tmp"
  echo "Nerd Fonts Symbols installed."
}

setup_uv_venv "$HOME/.local/share/venv/base"   ipython pipx
setup_uv_venv "$HOME/.local/share/nvim/venv"   pynvim
setup_fonts
