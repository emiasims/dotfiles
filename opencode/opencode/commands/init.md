---
description: Create or update AGENTS.md
---

Analyze this repository and produce a high-quality AGENTS.md
AGENTS.md gives AI coding agents project context.
If it does not exist then create it, otherwise update it.
( @AGENTS.md , at !`pwd` )

## Hard constraints

1. **≤80 lines, ≤150 instructions per file.** Treat tokens like money.
2. **Never duplicate discoverable information.** The agent can read your README, manifests, configs, and source. Do not restate them. No codebase overviews. No directory trees.
3. **No code style prose.** If a linter/formatter enforces it, give the command to run it. Only document unenforced rules.
4. **Commands must be copy-pasteable.** Backticks, exact flags, no paraphrasing.
5. **Every prohibition needs an alternative.** Never say "don't do X" without "do Y instead."
6. **Pointers over copies.** For detailed docs, give a one-line description and a file path.
7. **Show, don't tell.** One code example beats three sentences of prose.
8. **When uncertain, ask the user.** Do not guess commands, conventions, or architecture. Ask.

## What to analyze

Before writing, read (at minimum):
- [ ] Package manifest (package.json, pyproject.toml, Cargo.toml, go.mod, etc.)
- [ ] Lock file presence → determines package manager
- [ ] CI/CD configs (.github/workflows/, .gitlab-ci.yml, Makefile, etc.)
- [ ] Linter/formatter configs (.eslintrc, .prettierrc, ruff.toml, etc.)
- [ ] Test configuration (jest.config, vitest.config, pytest.ini, conftest.py, etc.)
- [ ] README.md, CONTRIBUTING.md, docs/
- [ ] Existing AGENTS.md or CLAUDE.md (preserve intentional rules)
- [ ] Source structure (`find` or `ls -R` of top-level dirs)
- [ ] `git log --oneline -20` for commit convention signals

## Monorepo strategy

If distinct modules exist: root `AGENTS.md` holds only global config and pointers to nested files. Each module (e.g., `api/AGENTS.md`) gets its own file with module-specific content. The ≤80 line target applies per file. Generate the root first, then ask the user which modules need their own files.

## Output structure

Use only these sections, in order. Omit any section with nothing non-obvious to say.

```markdown
One sentence about what the project is. Language, framework, non-obvious dependencies only.

## Commands
Bullet list: install, build, dev, test, lint/format, type-check. Exact flags.

## Testing
Single-test syntax, framework/assertion style (if non-standard), file locations (if unconventional), required setup.

## Code conventions
Only unenforced rules the agent gets wrong without instruction. Code examples over prose.

## Architecture pointers
2–5 lines: "For [topic], see [path]"

## Git workflow
Only if non-standard. Conventional commits = say so, don't re-explain.

## Boundaries
- **Always**: invariants (e.g., "run `pnpm check` before committing")
- **Ask first**: requires human confirmation (e.g., "new runtime dependencies")
- **Never + alternative**: (e.g., "Never modify /vendor → edit /src/vendor-patches")

## Gotchas
Non-obvious traps the agent cannot discover by reading code.
```

## Procedure

This can be flexible depending on the needs of the user, but generally follow this flow:
1. If updating, read existing `AGENTS.md`; note what to preserve.
2. Brief directory structure overview.
3. Use `todowrite` based on "What to analyze" above.
4. Deploy explore subagents in parallel to cover the TODO.
5. Synthesize findings; ask user about anything uncertain.
6. Write AGENTS.md, run quality checklist, cut to ≤80 lines.
7. Tell user what was included/excluded, suggest module files, and ask for review.

## After writing

1. If >80 lines, cut. Test: "Can the agent figure this out from the code?" If yes, delete.
2. Tell the user what you included, what you left out and why, and which modules could benefit from nested files.

## Quality checklist

- [ ] No codebase overview or directory tree
- [ ] No restated linter/formatter rules
- [ ] Every command is copy-pasteable
- [ ] Every "never" has an alternative
- [ ] No section >15 lines
- [ ] ≤80 lines per file
- [ ] Docs referenced by pointer, not inlined
- [ ] Style rules shown in code, not described in prose
- [ ] No guesses — uncertainties were asked about

## User notes:
$ARGUMENTS
