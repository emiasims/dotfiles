#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "anthropic>=1,<2",
# ]
# ///
"""Catalog extracted sources into a canon's pages/ over the Messages API.

Every request carries the same cached prefix (cataloging instructions, the entry
format, the project brief, the tag vocabulary) and differs only in the source
text, so N sources cost one cache write plus N-1 cache reads rather than N full
prefixes.

Usage:
    uv run catalog_batch.py --spec <canon/formats/entry.md> smith2022 jones2019
    uv run catalog_batch.py --spec <...> --pending
    uv run catalog_batch.py --spec <...> --pending --dry-run

Reads docs/index.md, docs/glossary.md, and docs/raw/<key>/{content.md,metadata.json}.
Writes docs/pages/<name>.md. Leaves glossary.md alone: new tags come back in the
report for you to reconcile, since parallel workers cannot see each other's.
"""
from __future__ import annotations

import argparse
import asyncio
import json
import os
import sys
from datetime import datetime
from pathlib import Path

from anthropic import AsyncAnthropic

# input, output $/MTok. Cache writes bill 1.25x input, reads 0.1x.
PRICES = {
    "claude-opus-5": (5.0, 25.0),
    "claude-sonnet-5": (2.0, 10.0),
    "claude-haiku-4-5": (1.0, 5.0),
}

INSTRUCTIONS = """\
You catalog one source into a canonize project: a wiki of markdown pages under
docs/, where each source the project has read gets one entry page summarizing it
and stating what the project can use it for.

You are given the project brief, the project's tag vocabulary, the entry format,
and the extracted text of exactly one source. Return the entry as JSON.

Write for a technical reader who lacks the background you just absorbed. Cover
the substance and stop: no filler, no closing summary. Every figure carries the
qualifier that bounds its meaning: its denominator and population (sex, age band,
year, sampling frame), and the measure it is on. A number stripped of its
qualifier reads as a settled fact when it is not.

Reuse an existing tag before proposing a new one. A new tag is justified when it
extends an existing family (another pathogen beside the ones listed, another
intervention beside its siblings) or when the source opens a dimension the
vocabulary does not cover. Put every tag you assign in `tags`, and additionally
list any that are not already in the vocabulary in `new_tags` with a one-line
description. Do not invent a tag to avoid leaving a source thinly tagged.

Set `skip_reason` and leave the other fields empty when the source fits no tag in
the vocabulary and justifies no new one, when the extracted text is too garbled to
summarize, or when it is not the source its metadata claims. A source that comes
back skipped is cheaper than a page that has to be found and corrected later.

`body` is the markdown body only, with no frontmatter and no title heading. It
opens with unheaded lead prose naming what the source is and where the raw file
sits, then carries `## Relevance to project`, then the sections the entry format
gives for this kind of source. Do not link to other pages: you cannot see them.
"""

SCHEMA = {
    "type": "object",
    "properties": {
        "skip_reason": {
            "type": ["string", "null"],
            "description": "why no page was written, or null",
        },
        "filename": {
            "type": "string",
            "description": "short-name.md, lowercase, hyphenated, no directory",
        },
        "title": {"type": "string"},
        "description": {"type": "string", "description": "one line"},
        "author": {"type": ["string", "null"]},
        "published": {"type": ["string", "null"]},
        "resource": {"type": ["string", "null"], "description": "DOI or stable URL"},
        "local": {"type": ["string", "null"], "description": "raw/<file>"},
        "tags": {"type": "array", "items": {"type": "string"}},
        "new_tags": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "tag": {"type": "string"},
                    "description": {"type": "string"},
                },
                "required": ["tag", "description"],
                "additionalProperties": False,
            },
        },
        "body": {"type": "string"},
    },
    "required": [
        "skip_reason", "filename", "title", "description", "author",
        "published", "resource", "local", "tags", "new_tags", "body",
    ],
    "additionalProperties": False,
}


def build_prefix(docs: Path, spec: Path) -> list[dict]:
    """System blocks, with the cache breakpoint on the last one.

    The per-source text goes in `messages`, after this breakpoint, so the whole
    prefix is byte-identical across the batch.
    """
    brief = (docs / "index.md").read_text(encoding="utf-8")
    glossary = (docs / "glossary.md").read_text(encoding="utf-8")
    shared = (
        f"# Entry format\n\n{spec.read_text(encoding='utf-8')}\n\n"
        f"# Project brief\n\n{brief}\n\n"
        f"# Tag vocabulary\n\n{glossary}"
    )
    return [
        {"type": "text", "text": INSTRUCTIONS},
        {"type": "text", "text": shared, "cache_control": {"type": "ephemeral"}},
    ]


def source_message(docs: Path, key: str, max_chars: int) -> str:
    d = docs / "raw" / key
    content = (d / "content.md").read_text(encoding="utf-8")
    if len(content) > max_chars:
        raise ValueError(
            f"{key}: extracted text is {len(content)} chars, over --max-chars "
            f"{max_chars}. Raise the limit or catalog this one by hand."
        )
    meta = d / "metadata.json"
    header = f"Source key: {key}\nRaw directory: raw/{key}/\n"
    if meta.exists():
        header += f"\nExtraction metadata:\n{meta.read_text(encoding='utf-8')}\n"
    return f"{header}\n---\n\n{content}"


def pending_keys(docs: Path) -> list[str]:
    """Extracted sources with no page naming them in `local`."""
    claimed = set()
    for page in (docs / "pages").glob("*.md"):
        for line in page.read_text(encoding="utf-8").splitlines():
            if line.startswith("local:"):
                claimed.add(line.split(":", 1)[1].strip().strip("\"'").rstrip("/"))
                break
    keys = []
    for d in sorted((docs / "raw").iterdir()):
        # `local` names the raw file, not its directory, so match on the prefix.
        if (d / "content.md").exists() and not any(
            c == f"raw/{d.name}" or c.startswith(f"raw/{d.name}/") for c in claimed
        ):
            keys.append(d.name)
    return keys


def _fm_scalar(value: str) -> str:
    # canon.py's frontmatter parser splits on the first colon, so a title
    # containing one has to be quoted. It strips matching quotes without
    # unescaping, so internal double quotes cannot survive.
    v = value.replace('"', "'").strip()
    return f'"{v}"' if ":" in v or not v else v


def render_page(entry: dict) -> str:
    fm = [
        "---",
        "type: entry",
        f"title: {_fm_scalar(entry['title'])}",
        f"description: {_fm_scalar(entry['description'])}",
    ]
    for key in ("author", "published", "resource", "local"):
        if entry.get(key):
            fm.append(f"{key}: {_fm_scalar(entry[key])}")
    fm.append(f"tags: [{', '.join(entry['tags'])}]")
    # canon's stamp hook only fires on Claude Code writes, and `check` errors on
    # a missing `updated`, so set it here in the same format stamp uses.
    fm.append(f"updated: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    fm.append("---")
    return "\n".join(fm) + "\n\n" + entry["body"].strip() + "\n"


async def catalog_one(
    client: AsyncAnthropic, args, prefix: list[dict], key: str
) -> tuple[str, dict | None, dict]:
    response = await client.messages.create(
        model=args.model,
        max_tokens=16000,
        system=prefix,
        messages=[{"role": "user", "content": source_message(args.docs, key, args.max_chars)}],
        output_config={
            "effort": args.effort,
            "format": {"type": "json_schema", "schema": SCHEMA},
        },
    )
    text = next(b.text for b in response.content if b.type == "text")
    usage = {
        "input": response.usage.input_tokens,
        "cache_write": response.usage.cache_creation_input_tokens or 0,
        "cache_read": response.usage.cache_read_input_tokens or 0,
        "output": response.usage.output_tokens,
    }
    return key, json.loads(text), usage


async def run(client: AsyncAnthropic, args, prefix: list[dict], keys: list[str]) -> list[tuple]:
    async with client:
        # The cache is only readable once the first response has begun, so the
        # first source runs alone. Fanning out cold would write N entries and
        # read none of them. It is also left unguarded, so a malformed request
        # fails once here instead of N times below.
        results = [await catalog_one(client, args, prefix, keys[0])]
        if results[0][2]["cache_write"] == 0:
            print(
                "warning: no cache write on the first request. The shared prefix "
                "is likely under the model's minimum cacheable length.",
                file=sys.stderr,
            )

        sem = asyncio.Semaphore(args.concurrency)

        async def guarded(key: str):
            async with sem:
                try:
                    return await catalog_one(client, args, prefix, key)
                except Exception as exc:
                    return key, None, {"error": f"{type(exc).__name__}: {exc}"}

        rest = await asyncio.gather(*(guarded(k) for k in keys[1:]))
    return results + list(rest)


async def dry_run(client: AsyncAnthropic, args, prefix: list[dict], keys: list[str]) -> None:
    async with client:
        base = await client.messages.count_tokens(
            model=args.model, system=prefix, messages=[{"role": "user", "content": "x"}]
        )
        totals = []
        for key in keys:
            counted = await client.messages.count_tokens(
                model=args.model,
                system=prefix,
                messages=[{"role": "user", "content": source_message(args.docs, key, args.max_chars)}],
            )
            totals.append(counted.input_tokens - base.input_tokens)

    prefix_tokens = base.input_tokens
    suffix_tokens = sum(totals)
    print(f"{len(keys)} sources, shared prefix {prefix_tokens:,} tokens")
    print(f"per-source text: {min(totals):,}-{max(totals):,} tokens, {suffix_tokens:,} total")

    if args.model not in PRICES:
        print(f"no cached price for {args.model}; skipping the estimate")
        return
    inp, out = PRICES[args.model]
    est_out = 1500 * len(keys)
    cached = (prefix_tokens * 1.25 + prefix_tokens * 0.1 * (len(keys) - 1)) * inp / 1e6
    uncached = prefix_tokens * len(keys) * inp / 1e6
    variable = (suffix_tokens * inp + est_out * out) / 1e6
    print(f"\nprefix, cached:   ${cached:,.2f}")
    print(f"prefix, uncached: ${uncached:,.2f}  (what N separate subagents pay)")
    print(f"sources + output: ${variable:,.2f}  (output estimated at 1.5k tokens each)")
    print(f"total:            ${cached + variable:,.2f}")


def report(results: list[tuple], pages: Path, force: bool) -> int:
    written, skipped, failed = [], [], []
    new_tags: dict[str, list[str]] = {}
    descriptions: dict[str, set[str]] = {}

    for key, entry, usage in results:
        if entry is None:
            failed.append((key, usage["error"]))
            continue
        if entry["skip_reason"]:
            skipped.append((key, entry["skip_reason"]))
            continue
        path = pages / Path(entry["filename"]).name
        if path.suffix != ".md":
            path = path.with_suffix(".md")
        if path.exists() and not force:
            failed.append((key, f"{path.name} already exists (use --force)"))
            continue
        path.write_text(render_page(entry), encoding="utf-8")
        written.append((key, path.name))
        for t in entry["new_tags"]:
            new_tags.setdefault(t["tag"], []).append(path.name)
            descriptions.setdefault(t["tag"], set()).add(t["description"])

    spend = {k: sum(u.get(k, 0) for _, _, u in results) for k in ("input", "cache_write", "cache_read", "output")}

    print(f"\nwrote {len(written)} pages to {pages}")
    for key, name in written:
        print(f"  {key} -> {name}")
    if skipped:
        print(f"\nskipped {len(skipped)}:")
        for key, reason in skipped:
            print(f"  {key}: {reason}")
    if failed:
        print(f"\nfailed {len(failed)}:")
        for key, reason in failed:
            print(f"  {key}: {reason}")
    if new_tags:
        print(f"\n{len(new_tags)} new tags, none written to glossary.md:")
        for tag in sorted(new_tags):
            print(f"  {tag}: {' | '.join(sorted(descriptions[tag]))}")
            print(f"    on: {', '.join(sorted(new_tags[tag]))}")
    print(
        f"\ntokens: {spend['cache_write']:,} cache write, {spend['cache_read']:,} cache read, "
        f"{spend['input']:,} uncached in, {spend['output']:,} out"
    )
    print("\nreconcile the new tags into glossary.md, then run canon.py compile and check.")
    return 1 if failed else 0


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("keys", nargs="*", help="source keys under docs/raw/")
    p.add_argument("--docs", type=Path, default=Path("docs"), help="canon root (default: docs)")
    p.add_argument(
        "--spec",
        type=Path,
        default=os.environ.get("CANONIZE_ENTRY_FORMAT"),
        help="path to canon/formats/entry.md, or set CANONIZE_ENTRY_FORMAT",
    )
    p.add_argument("--pending", action="store_true", help="every extracted source with no page")
    p.add_argument("--model", default="claude-opus-5")
    p.add_argument("--effort", default="high", choices=["low", "medium", "high", "xhigh", "max"])
    p.add_argument("--concurrency", type=int, default=4)
    p.add_argument("--max-chars", type=int, default=400_000, help="per-source ceiling on extracted text")
    p.add_argument("--force", action="store_true", help="overwrite existing pages")
    p.add_argument("--dry-run", action="store_true", help="token counts and a cost estimate, no pages")
    args = p.parse_args()

    if not args.spec:
        p.error("--spec is required (or set CANONIZE_ENTRY_FORMAT)")
    args.spec = Path(args.spec)
    for path in (args.docs / "index.md", args.docs / "glossary.md", args.spec):
        if not path.exists():
            p.error(f"missing {path}")

    keys = pending_keys(args.docs) if args.pending else args.keys
    if not keys:
        print("nothing to catalog")
        return 0
    missing = [k for k in keys if not (args.docs / "raw" / k / "content.md").exists()]
    if missing:
        p.error(f"no content.md for: {', '.join(missing)}. Extract them first.")

    # The SDK resolves credentials at request time, so an unset key would
    # otherwise surface as a traceback several calls deep.
    if not (
        os.environ.get("ANTHROPIC_API_KEY")
        or os.environ.get("ANTHROPIC_AUTH_TOKEN")
        or (Path.home() / ".config" / "anthropic").exists()
    ):
        p.error("no Anthropic credentials. Set ANTHROPIC_API_KEY, or run `ant auth login`.")

    prefix = build_prefix(args.docs, args.spec)
    client = AsyncAnthropic(max_retries=5)

    if args.dry_run:
        asyncio.run(dry_run(client, args, prefix, keys))
        return 0

    results = asyncio.run(run(client, args, prefix, keys))
    return report(results, args.docs / "pages", args.force)


if __name__ == "__main__":
    sys.exit(main())
