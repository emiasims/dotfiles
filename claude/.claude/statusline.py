#!/usr/bin/env python3
"""Claude Code status line: reads the JSON payload on stdin, prints one line."""
import json
import os
import re
import subprocess
import sys
from datetime import datetime
from enum import StrEnum


class Hl(StrEnum):
    """Catppuccin Mocha."""

    TEXT = "\033[38;2;205;214;244m"
    MAUVE = "\033[38;2;203;166;247m"
    BLUE = "\033[38;2;137;180;250m"
    GREEN = "\033[38;2;166;227;161m"
    YELLOW = "\033[38;2;249;226;175m"
    PEACH = "\033[38;2;250;179;135m"
    RED = "\033[38;2;243;139;168m"
    TEAL = "\033[38;2;148;226;213m"
    GREY = "\033[38;2;108;112;134m"
    BOLD = "\033[1m"
    RESET = "\033[0m"

    def __call__(self, text: object) -> str:
        return f"{self}{text}{Hl.RESET}"

    @staticmethod
    def heat(pct: float, med: float, high: float) -> "Hl":
        return Hl.RED if pct >= high else Hl.YELLOW if pct >= med else Hl.GREEN


SEP = Hl.GREY(" │ ")


def human(n: int) -> str:
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M".replace(".0M", "M")
    if n >= 1_000:
        return f"{n / 1_000:.0f}k"
    return str(n)


def is_num(x) -> bool:
    return isinstance(x, (int, float))


class Claude:
    """The status-line JSON payload Claude Code sends on stdin."""

    def __init__(self, payload: dict):
        self.payload = payload
        self.cwd = payload.get("cwd") or self.get("workspace", "current_dir") or os.getcwd()

    @classmethod
    def from_stdin(cls) -> "Claude":
        try:
            return cls(json.load(sys.stdin))
        except ValueError:
            return cls({})

    def get(self, *keys: str):
        """Nested lookup that tolerates missing or null levels."""
        d = self.payload
        for key in keys:
            d = d.get(key) if isinstance(d, dict) else None
        return d

    def model(self) -> str:
        name = self.get("model", "display_name") or "Claude"
        # normalize context-window suffixes ("(1M context)", "[1m]", "1M", ...) to a grey [1M]
        name, big = re.subn(r"\s*[\(\[]?\s*\b1M(\s+context)?\s*[\)\]]?", "", name, flags=re.I)
        name = name.removeprefix("Claude ").strip() or "Claude"
        # the payload omits `effort` for models that don't take an effort level
        level = self.get("effort", "level")
        return (
            Hl.PEACH(name)
            + (" " + Hl.GREY("[1M]") if big else "")
            + (" " + Hl.GREY(f"({level})") if level else "")
        )

    def context(self) -> str | None:
        used = self.get("context_window", "total_input_tokens")
        size = self.get("context_window", "context_window_size")
        if not used or not size:
            return None
        pct = self.get("context_window", "used_percentage")
        pct = round(pct if is_num(pct) else 100 * used / size)
        return (
            f"{Hl.heat(pct, med=20, high=40)(human(used))}{Hl.GREY('/')}{Hl.BLUE(human(size))} "
            f"{Hl.GREY(f'{pct}%')}"
        )

    def cost(self) -> str | None:
        usd = self.get("cost", "total_cost_usd")
        if not is_num(usd):
            return None
        return Hl.GREEN(f"${usd:.2f}" if usd >= 0.01 else f"${usd:.3f}")

    def usage(self) -> str | None:
        parts = []
        for key, label, fmt in (("five_hour", "5h", "%H:%M"), ("seven_day", "7d", "%a %H:%M")):
            pct = self.get("rate_limits", key, "used_percentage")
            if not is_num(pct):
                continue
            part = f"{Hl.GREY(label)} {Hl.heat(pct, med=70, high=90)(f'{pct:.0f}%')}"
            if is_num(reset := self.get("rate_limits", key, "resets_at")):
                part += " " + Hl.GREY(f"↻{datetime.fromtimestamp(reset):{fmt}}")
            parts.append(part)
        return " ".join(parts) or None


class Git:
    """Git state of a directory. Outside a repo, `in_repo` is False and `status()` is None."""

    def __init__(self, cwd: str):
        self.cwd = cwd
        self.branch = self.oid = ""
        self.ahead = self.behind = self.staged = self.dirty = self.untracked = 0

        porcelain = self.run("status", "--porcelain=v2", "--branch")
        self.in_repo = porcelain is not None
        # in a worktree this is the worktree's own directory, not the main checkout
        self.root = (self.in_repo and self.run("rev-parse", "--show-toplevel") or "").strip() or cwd
        for line in (porcelain or "").splitlines():
            self.parse(line)

        if self.branch == "(detached)":
            self.branch = f"@{self.oid[:7]}"

    def run(self, *args: str) -> str | None:
        try:
            out = subprocess.run(
                # optional locks would make a concurrent commit fail on index.lock
                ["git", "--no-optional-locks", "-C", self.cwd, *args], capture_output=True, text=True, timeout=1.5
            )
        except (OSError, subprocess.TimeoutExpired):
            return None
        return out.stdout if out.returncode == 0 else None

    def parse(self, line: str) -> None:
        match line.split(" "):
            case ["#", "branch.head", *name]:
                self.branch = " ".join(name)
            case ["#", "branch.oid", oid]:
                self.oid = oid
            case ["#", "branch.ab", a, b]:
                self.ahead, self.behind = int(a), -int(b)
            case ["?", *_]:
                self.untracked += 1
            case ["1" | "2" | "u", xy, *_]:
                self.staged += xy[0] != "."
                self.dirty += xy[1] != "."

    def worktree(self) -> dict:
        name = os.path.basename(self.root.rstrip(os.sep)) or os.sep
        text = Hl.BOLD(Hl.BLUE(name.upper()))
        if self.branch:
            text += Hl.MAUVE(f" ({self.branch})")
        return {"text": text, "sep": Hl.TEXT("❯") + " "}

    def status(self) -> str | None:
        if not self.in_repo:
            return None
        counts = [
            (self.staged, Hl.GREEN, "●"),
            (self.dirty, Hl.YELLOW, "✚"),
            (self.untracked, Hl.RED, "?"),
            (self.ahead, Hl.TEAL, "↑"),
            (self.behind, Hl.TEAL, "↓"),
        ]
        marks = [hl(f"{sym}{n}") for n, hl, sym in counts if n] or [Hl.GREEN("✓")]
        return Hl.TEAL("⎇ ") + " ".join(marks)


def join(*segments: str | dict | None) -> str:
    """Join the non-empty segments. A dict segment {"text", "sep"} sets the separator after it."""
    parts = []
    for seg in filter(None, segments):
        if isinstance(seg, dict):
            parts += [seg["text"], seg.get("sep", SEP)]
        else:
            parts += [seg, SEP]
    return "".join(parts[:-1])


def statusline() -> str:
    claude = Claude.from_stdin()
    git = Git(claude.cwd)
    return join(
        git.worktree(),
        claude.model(),
        claude.context(),
        claude.cost(),
        claude.usage(),
        git.status(),
    )


if __name__ == "__main__":
    print(statusline())
