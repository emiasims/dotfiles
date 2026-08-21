---
name: reviewing-code
description: Use when reviewing code for quality, correctness, bugs, or spec compliance
---

# Reviewing Code

## Overview

Critical review of code. The goal is finding real problems -- bugs, design issues, spec violations -- not style preferences.

## Scoping

Determine what to review before reviewing it:

- **Diff-based review** (most common): use `git diff` to identify changed files. Focus on those. Read enough surrounding context to evaluate correctness, but don't review unchanged code.
- **Targeted review**: user points at specific files or functions. Read the target plus its interfaces and callers.
- **Broad review**: user asks to review a module or project. Focus on public interfaces, entry points, and complex logic. Skip boilerplate and obvious code.

If scope is genuinely unclear, ask.

## What to Read

Before forming opinions:

- Use `git diff` (or `git diff branch...HEAD`) to identify what changed
- Use `glob` to find test files and specs related to the changed code
- Read the interfaces and types the code depends on
- Read the spec, plan, or requirements if they exist

## Priority Order

Review in this order. If you find blocking issues, report them first -- then continue with lower-priority findings.

1. **Correctness** -- does the code do what it claims? Logic errors, off-by-ones, missing cases, wrong assumptions
2. **Spec compliance** -- if a spec or plan exists, does the code match it? Note deviations
3. **Error handling** -- are errors caught, propagated, or surfaced correctly? What happens at boundaries?
4. **Security** -- injection, unvalidated input, exposed secrets, unsafe operations
5. **Performance** -- obvious bottlenecks, N+1 queries, blocking where async is needed
6. **Maintainability** -- complexity, naming, duplication, missing abstractions

## Output Format

For each finding:
```
**[Priority]** `file:line` Brief description.
Fix: specific suggestion or code snippet.
```

Priority levels: `Blocking`, `Major`, `Minor`, `Nit`.

Use `file:line` when reviewing code. Use `file` alone when line numbers aren't meaningful (diffs, generated code). For non-file artifacts, use a descriptive location.

End with: overall assessment (ship / ship with fixes / needs rework) and the single highest-priority fix.

## Verification Limits

The review agent cannot run tests, type-checkers, or build tools. When a finding depends on runtime behavior or type-checking to confirm, mark it: `[needs verification]`. Be explicit about what command would confirm it.

## Common Mistakes

- **Nit-picking style when there are blocking bugs.** Prioritize correctly.
- **Reporting without suggesting.** Every finding needs a fix direction.
- **Reviewing tests as if they were production code.** Different standards apply. Tests should be readable and explicit, even if repetitive.
- **Missing the forest.** After finding individual issues, step back: is the overall design right?
- **Reviewing everything equally.** Changed code and complex logic deserve close attention. Boilerplate and unchanged code don't.
