#!/usr/bin/env bash
set -euo pipefail

fish_path="$(command -v fish 2>/dev/null)" || { echo "[warn] fish not found, skipping shell setup."; exit 0; }
if [[ "$SHELL" == "$fish_path" ]]; then
  echo "fish is already the default shell."
  exit 0
fi
echo "Setting fish as default shell..."
if ! grep -qF "$fish_path" /etc/shells; then
  echo "Adding $fish_path to /etc/shells..."
  echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
fi
chsh -s "$fish_path"
echo "Default shell set to fish."
