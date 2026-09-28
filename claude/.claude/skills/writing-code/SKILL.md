---
name: writing-code
description: Use when writing, modifying, or fixing production code -- new features, bug fixes, refactoring, any code changes
---

# Writing Code

Covers all production code work: new code, restructuring, and fixing. The mode determines the discipline.

## Before Writing

- Read the relevant existing code first. Understand patterns, naming, conventions.
- Use `explore` subagents for context from multiple areas in parallel.
- If a plan exists, read it. Follow it. If the task deviates, scope before writing.

## New Code

- Match existing code style: naming, error handling, module structure.
- Write the minimal code that satisfies the requirement. No speculative abstraction.
- Prefer editing existing files over creating new ones.
- If the task decomposes into independent units, dispatch `general` subagents in parallel.

## Refactoring

Restructuring without changing behavior.

- **One transformation at a time.** Rename, then extract, then move — not all at once.
- **No behavior changes.** If you find a bug while refactoring, note it and fix it separately.
- **Prefer mechanical over creative.** Use `replaceAll` for renames, grep to find all call sites.
- If tests exist, run them before starting to establish a baseline.
- If no tests exist, record outputs of key entry points before starting.

## Debugging

Systematic root cause analysis. Understand **why** before fixing.

1. **Reproduce** — confirm the failure. Understand exact conditions.
2. **Isolate** — narrow the failure surface to the smallest trigger.
3. **Hypothesize** — one specific hypothesis at a time. Use `explore` subagents to investigate multiple hypotheses in parallel.
4. **Verify** — test the hypothesis. Prefer reading code and tracing data flow over adding instrumentation. Do not fix until root cause is confirmed.
5. **Fix** — change the minimum necessary.
6. **Confirm** — verify the fix without introducing regressions.

Exit conditions:
- **Can't reproduce:** ask for more context. Don't guess.
- **Hypotheses exhausted:** after three falsified hypotheses, re-examine assumptions. Ask the user.
- **Fix is disproportionate:** if the fix requires large structural changes, suggest re-scoping.

## Verification

After any code change, confirm it works:
- Run existing tests if present
- For new code without tests: validate manually or load the skill for writing tests
- Check for regressions in adjacent code if the change is non-trivial

## Comments

- **Explain why, not what.** Comment on intent or non-obvious reasoning; skip restating what the code does.
- **Section breaks** in long functions are acceptable if the code isn't self-explanatory — but be conservative. Never at the top level of a file.
- **No enumeration.** Never number steps or label sections with banners.
- **Lowercase by default.** Start comment text in lowercase.

```python
# do
# retry because the API intermittently 504s on first attempt
response = fetch(url)

# don't
# Step 1: Get the response
# Finally, Step 3, Get response, if it worked.
response = fetch(url)
```

```python
# never -- top-level section banners
# --- Constants ---
...
# --- Config ---
...
```

## Common Mistakes

- **Writing before reading.** Mismatched patterns create tech debt.
- **Over-abstracting.** Generalize only when the second use case appears.
- **Fixing before understanding.** A fix without root cause will recur.
- **Changing too much at once.** Each change should be independently verifiable.
- **Mixing refactoring and behavior changes.** Separate concerns — if you improve logic during a refactor, it's no longer a refactor.
- **Skipping verification.** Code that isn't confirmed to work isn't done.
