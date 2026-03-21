My configuration lives at ~/dotfiles/, managed by stow. Expect any configuration (fish, neovim, opencode, tmux, etc) to live there.
e.g. `~/.config/opencode` is symlinked to `~/dotfiles/opencode/opencode`

Write minimal comments.
- do NOT comment to explain _WHAT_ unless the what is unclear
- DO comment to explain _WHY_ if it is unclear.
- In long functions, comments to break up logical sections MAY be acceptable,
  in particular if the code isn't clear. If one section in a function needs a
  comment, that function can have more even for the simpler parts,
  but **BE CONSERVATIVE** with comments.
- comments should NEVER enumerate steps/section
- comments should default to starting with lowercase
- DO: `# get response, if it worked`
- do NOT: `# Finally, Step 3, Get response, if it worked.`
- NEVER:
```
# --- Constants ---
...
# --- Config ---
...
```


YOU MUST FOLLOW THE WORKFLOW THE USER STARTS WITH (e.g. brainstorming) AND MAKE ADJUSTMENTS ACCORDING TO THE USER'S WISHES.
