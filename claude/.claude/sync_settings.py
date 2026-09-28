#!/usr/bin/env python3
"""Rebuild ~/.claude/settings.json from base_settings.json (shared) and local_settings.json (this machine).

settings.json = base + local, local winning on conflicts, lists combined. Edits made to
settings.json since the last sync (by Claude or by hand) are first written back to the file
that owns them: local if local has the key, else base if base has it, else local.
"""
import fcntl
import json
import shutil
from contextlib import contextmanager
from pathlib import Path

CLAUDE = Path.home() / ".claude"
MISSING = object()


class JsonFile:
    def __init__(self, name: str):
        # base_settings.json is a symlink into dotfiles; write the real file and leave the link alone.
        self.path = (CLAUDE / name).resolve()
        self.name = name

    def exists(self) -> bool:
        return self.path.exists()

    def load(self) -> dict:
        try:
            return json.loads(self.path.read_text()) if self.exists() else {}
        except json.JSONDecodeError as err:
            raise ValueError(f"invalid JSON in {self.name}: {err}") from err

    def save(self, data: dict):
        text = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
        if self.exists() and self.path.read_text() == text:
            return  # an unchanged settings.json must not retrigger ConfigChange
        tmp = self.path.with_name(self.path.name + ".tmp")
        tmp.write_text(text)
        if self.exists():
            shutil.copymode(self.path, tmp)
        tmp.replace(self.path)


class Tree:
    """Path access into nested settings dicts."""

    @staticmethod
    def get(tree, path: tuple):
        for key in path:
            if not isinstance(tree, dict) or key not in tree:
                return MISSING
            tree = tree[key]
        return tree

    @staticmethod
    def put(tree: dict, path: tuple, value):
        for key in path[:-1]:
            tree = tree.setdefault(key, {})
        tree[path[-1]] = value

    @staticmethod
    def drop(tree: dict, path: tuple):
        parent = Tree.get(tree, path[:-1])
        if isinstance(parent, dict):
            parent.pop(path[-1], None)

    @staticmethod
    def merge(base, local):
        if isinstance(base, dict) and isinstance(local, dict):
            out = dict(base)
            for key, value in local.items():
                out[key] = Tree.merge(base[key], value) if key in base else value
            return out
        if isinstance(base, list) and isinstance(local, list):
            return base + [item for item in local if item not in base]
        return local

    @staticmethod
    def minus(tree, base):
        """The parts of tree that base does not already supply."""
        if isinstance(tree, dict) and isinstance(base, dict):
            return {
                key: Tree.minus(value, base[key]) if key in base else value
                for key, value in tree.items()
                if base.get(key, MISSING) != value
            }
        if isinstance(tree, list) and isinstance(base, list):
            return [item for item in tree if item not in base]
        return tree

    @staticmethod
    def expand_paths(tree):
        # Claude Code doesn't document ~ expansion in marketplace paths, and base has to
        # work under any home directory.
        if isinstance(tree, dict):
            return {
                key: str(Path(value).expanduser())
                if key == "path" and isinstance(value, str)
                else Tree.expand_paths(value)
                for key, value in tree.items()
            }
        if isinstance(tree, list):
            return [Tree.expand_paths(item) for item in tree]
        return tree


class Owners:
    """base and local settings, taking back the edits made to settings.json since the snapshot."""

    def __init__(self, base: dict, local: dict):
        self.base = base
        self.local = local
        self.conflicts = []

    def owner(self, path: tuple) -> dict:
        if Tree.get(self.local, path) is not MISSING or Tree.get(self.base, path) is MISSING:
            return self.local
        return self.base

    def take(self, now, before, path: tuple = ()):
        if now == before:
            return
        if isinstance(now, dict) and isinstance(before, dict):
            for key in now.keys() | before.keys():
                self.take(now.get(key, MISSING), before.get(key, MISSING), path + (key,))
        elif isinstance(now, list) and isinstance(before, list):
            self.take_list(now, before, path)
        elif now is MISSING:
            Tree.drop(self.base, path)
            Tree.drop(self.local, path)
        else:
            self.take_value(now, before, path)

    def take_value(self, now, before, path: tuple):
        owner = self.owner(path)
        current = Tree.get(owner, path)
        if current not in (before, now):
            name = "base" if owner is self.base else "local"
            self.conflicts.append(
                f"{'.'.join(path)}: kept {name} value {current!r}, dropped settings.json value {now!r}"
            )
            return
        Tree.put(owner, path, now)

    def take_list(self, now: list, before: list, path: tuple):
        for item in before:
            if item not in now:
                for tree in (self.base, self.local):
                    items = Tree.get(tree, path)
                    if isinstance(items, list) and item in items:
                        items.remove(item)
        base_items = Tree.get(self.base, path)
        added = [item for item in now if item not in before and item not in (base_items or [])]
        if not added:
            return
        items = Tree.get(self.local, path)
        if not isinstance(items, list):
            items = []
            Tree.put(self.local, path, items)
        items.extend(item for item in added if item not in items)


@contextmanager
def locked():
    with open(CLAUDE / ".settings-sync.lock", "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        yield


def sync() -> str:
    settings = JsonFile("settings.json")
    base = JsonFile("base_settings.json")
    local = JsonFile("local_settings.json")
    snapshot = JsonFile(".settings-snapshot.json")
    notes = []

    if not base.exists():
        return f"Settings sync: {base.path} not found, settings.json left alone."
    try:
        owners = Owners(base.load(), local.load())
        now = settings.load()
        before = snapshot.load() if snapshot.exists() else None
    except ValueError as err:
        return f"Settings sync: {err}, settings.json left alone."

    if before is None:
        if settings.exists():
            shutil.copy2(settings.path, settings.path.with_suffix(".json.bak"))
            owners.local = Tree.merge(owners.local, Tree.minus(now, owners.base))
            notes.append(
                "first sync: whatever settings.json set beyond base moved to local_settings.json, "
                "original saved as settings.json.bak"
            )
    else:
        owners.take(now, before)

    merged = Tree.expand_paths(Tree.merge(owners.base, owners.local))
    base.save(owners.base)
    local.save(owners.local)
    settings.save(merged)
    snapshot.save(merged)

    notes += owners.conflicts
    if not notes:
        return ""
    return "Settings sync (tell the user):\n" + "\n".join(f"- {note}" for note in notes)


if __name__ == "__main__":
    with locked():
        report = sync()
    if report:
        print(report)
