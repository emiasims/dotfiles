# ~/dotfiles

Personal dotfiles managed with GNU stow. Each top-level directory is a stow package (e.g. `nvim/`, `fish/`, `tmux/`).

- If your CWD is the repo root (`~/dotfiles/`), you **must** load the `managing-dotfiles` skill before doing anything. It contains the full workflow for stow packages, install scripts, and conventions.
- If your CWD is inside a subdirectory (e.g. `nvim/nvim/`), you are editing that package's config. **Ignore** the dotfiles repo structure and focus on that package. Defer entirely to the local `AGENTS.md` found in that package.
- No build system, linter, or test suite exists at the repo level.
- `~/.config/<pkg>` is typically symlinked to `~/dotfiles/<pkg>/<pkg>/` via stow.
- Treat subdirectories as isolated projects when invoked from within them.
- Do not explore other packages' configs or this repository level unless the task specifically requires it.
