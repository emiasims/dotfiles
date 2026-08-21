#!/usr/bin/env bash
set -euo pipefail

# Seed CLAUDE.md on first install only. Unlike the skills (symlinked), the live
# CLAUDE.md is a real file so it can be edited per-machine without touching the repo.
src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/CLAUDE.md"
dest="$HOME/.claude/CLAUDE.md"

if [[ -e "$dest" || -L "$dest" ]]; then
  echo "CLAUDE.md already present, leaving it."
else
  mkdir -p "$HOME/.claude"
  cp "$src" "$dest"
  echo "Seeded CLAUDE.md -> $dest"
fi
