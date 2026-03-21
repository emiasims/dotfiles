---
description: Extract non-obvious learnings from session into AGENTS.md
---

Analyze this session and extract non-obvious learnings to add to the local AGENTS.md.

## Hard constraints

1. **≤3 lines per learning.** Treat tokens like money.
2. **Never duplicate discoverable information.** The agent can read source, configs, and READMEs. Do not restate them.
3. **Pointers over copies.** For detailed context, give a one-line description and a file path.
4. **Show, don't tell.** One code example beats three sentences of prose.
5. **Every prohibition needs an alternative.** Never say "don't do X" without "do Y instead."
6. **When uncertain, ask the user.** Do not guess scope or conventions.

## What counts as a learning

Non-obvious discoveries only:

- Hidden relationships between files or modules; files that must change together
- Execution paths that differ from how code appears
- Non-obvious configuration, env vars, or flags
- Debugging breakthroughs when error messages were misleading
- API/tool quirks and workarounds
- Architectural decisions and constraints

Test: "Can the agent figure this out from the code?" If yes, don't add it.

## Procedure

1. Review session for discoveries, errors that took multiple attempts, unexpected connections.
2. Read existing AGENTS.md (create if absent).
3. Ask user about anything uncertain before writing.
4. Update AGENTS.md.

## After writing

1. If AGENTS.md exceeds ≤80 lines, cut. Apply the test above.
2. Summarize what was added, how many learnings, and what was excluded.

## Quality checklist

- [ ] No restated docs, README content, or standard framework behavior
- [ ] No session-specific details
- [ ] Each learning ≤3 lines
- [ ] Every "never" has an alternative
- [ ] No guesses — uncertainties were asked about
- [ ] ≤80 lines total
- [ ] Style rules shown in code, not described in prose

$ARGUMENTS
