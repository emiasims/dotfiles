#!/usr/bin/env bash
set -euo pipefail

# post-merge rebuilds ~/.claude/settings.json after a pull.
git -C "$(dirname "${BASH_SOURCE[0]}")/.." config core.hooksPath .githooks
"$HOME/.claude/sync_settings.py"
