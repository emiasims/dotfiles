#!/usr/bin/env bash
set -euo pipefail

nvim_bin="$HOME/.local/bin/nvim"
if [[ ! -x "$nvim_bin" ]]; then
  echo "[warn] nvim not found at $nvim_bin, skipping plugin sync."
  exit 0
fi
echo "Syncing Neovim plugins..."
"$nvim_bin" --headless "+Lazy! sync" +qa
echo "Neovim plugins synced."
