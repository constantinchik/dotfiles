#!/usr/bin/env python3
"""Curate shared skills without copying runtime state or changing permissions."""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import sys
import uuid
from urllib.parse import unquote, urlsplit

REPO = Path(__file__).resolve().parents[2]
SUPPORT = re.compile(r"(?:references|scripts|templates|assets)/[A-Za-z0-9_./-]+")
# Validate destinations, not human labels: nested/escaped brackets in labels
# must not hide a destination. Unsupported spellings are checked conservatively.
MARKDOWN_LINK = re.compile(r'\]\(\s*(?:<([^>]+)>|([^\s)]+))[^)]*\)')
MARKDOWN_REFERENCE = re.compile(r'(?m)^\s{0,3}\[.*\]:\s*(?:<([^>]+)>|(\S+))')
PERSONAL_PATH = re.compile(r"/(?:Users|home)/[A-Za-z0-9_.-]+/")
FORBIDDEN = {".env", "auth.json", ".credentials.json", "credentials.json", "state.db", "node_modules", ".git", ".DS_Store"}
CACHE = {"__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache"}


def within(path, root):
    try:
        path.relative_to(root)
        return True
    except ValueError:
        return False


def relative(value):
    p = PurePosixPath(value)
    if not value or p.is_absolute() or ".." in p.parts or "\\" in value or str(p) != value:
        raise ValueError("expected a normalized relative path: " + value)
    return Path(value)


def manifest(repo):
    data = json.loads((repo / "scripts/agents/manifest.json").read_text())
    if data.get("schema") != 1:
        raise ValueError("unsupported manifest schema")
    return data


def packages(repo):
    data = manifest(repo)
    return [(name, repo / "agents/.agents/skills" / relative(name)) for name in data["skills"]]


def canonical_path(repo, path):
    """Reject source ancestor aliases before enumerating or reading content."""
    cursor = repo
    for part in path.relative_to(repo).parts:
        cursor = cursor / part
        if cursor.is_symlink():
            raise ValueError("symlink in canonical source ancestry: " + str(cursor.relative_to(repo)))
    if not within(path.resolve(), repo.resolve()):
        raise ValueError("source outside repository: " + str(path))


def markdown_reference_errors(content, document, package):
    errors = []
    for pattern in [MARKDOWN_LINK, MARKDOWN_REFERENCE]:
        for match in pattern.finditer(content):
            ref = match[1] or match[2]
            if within(document, package / "templates") and re.fullmatch(r"\{\{[A-Za-z0-9_]+\}\}", ref):
                continue  # A template field, not a reference until rendered.
            uri = urlsplit(ref)
            if uri.scheme in {"http", "https", "mailto", "data"} or ref.startswith("#"):
                continue
            path = unquote(uri.path)
            if any(char in path for char in "()\\"):
                errors.append("unsupported local reference syntax (use simple paths): " + ref)
                continue
            target = (document.parent / path).resolve()
            if uri.scheme or uri.netloc or path.startswith("~") or not within(target, package.resolve()):
                errors.append("reference escape: " + ref)
            elif not target.exists():
                errors.append("missing reference: " + ref)
    return errors


def package_files(root):
    """Never follow a symlink or open secret/runtime files."""
    if root.is_symlink():
        raise ValueError("canonical package is a symlink")
    for directory, dirs, files in os.walk(root, followlinks=False):
        for name in list(dirs):
            p = Path(directory) / name
            if name in CACHE:
                dirs.remove(name)
            elif p.is_symlink():
                raise ValueError("symlink in canonical package: " + str(p.relative_to(root)))
            elif name in FORBIDDEN or name.startswith("."):
                raise ValueError("forbidden directory: " + name)
        for name in sorted(files):
            p = Path(directory) / name
            if name.endswith(".pyc"):
                continue
            if p.is_symlink():
                raise ValueError("symlink in canonical package: " + str(p.relative_to(root)))
            if name in FORBIDDEN or name.startswith(".") or name.endswith((".secret", ".pem", ".key", ".db")):
                raise ValueError("forbidden file: " + name)
            yield p


def package_hash(root):
    digest = hashlib.sha256()
    for p in sorted(package_files(root)):
        digest.update(p.relative_to(root).as_posix().encode() + b"\0")
        digest.update(p.read_bytes() + b"\0")
    return digest.hexdigest()


def validate(repo):
    errors = []
    data = manifest(repo)
    names = data["skills"]
    if len(names) != len(set(names)):
        errors.append("duplicate skill name in manifest")
    root = repo / "agents/.agents/skills"
    try:
        canonical_path(repo, root)
    except (ValueError, RuntimeError, OSError) as exc:
        return [str(exc)]
    actual = {p.name for p in root.iterdir()} if root.exists() else set()
    if actual != set(names):
        errors.append("manifest/package mismatch: " + str(sorted(actual.symmetric_difference(names))))
    for name, package in packages(repo):
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name):
            errors.append("invalid skill name: " + name)
            continue
        entry = package / "SKILL.md"
        try:
            canonical_path(repo, package)
            files = list(package_files(package))
            if entry not in files:
                errors.append(name + ": missing SKILL.md")
                continue
            text = entry.read_text()
            fm = re.match(r"\A---\n(.*?)\n---(?:\n|$)", text, re.S)
            if not fm:
                errors.append(name + ": missing frontmatter")
                continue
            fields = {}
            for line in fm.group(1).splitlines():
                match = re.fullmatch(r"([a-z][a-z0-9_-]*):\s*(.+)", line)
                if not match:
                    errors.append(name + ": use flat scalar frontmatter")
                    continue
                fields[match[1]] = match[2].strip("\"'")
            if fields.get("name") != name:
                errors.append(name + ": frontmatter name mismatch")
            if not fields.get("description"):
                errors.append(name + ": missing description")
            for p in files:
                if p.suffix not in {".md", ".py", ".sh", ".json", ".txt", ".yaml", ".yml"}:
                    continue
                content = p.read_text()
                if PERSONAL_PATH.search(content):
                    errors.append(name + ": personal path in " + p.relative_to(package).as_posix())
                if re.search(r"(?:sk-[A-Za-z0-9]{24,}|gh[pousr]_[A-Za-z0-9]{30,}|AKIA[A-Z0-9]{16})", content):
                    errors.append(name + ": possible credential in " + p.name)
                if p.suffix == ".md":
                    errors.extend(name + ": " + e for e in markdown_reference_errors(content, p, package))
                    for ref in SUPPORT.findall(content):
                        target = (package / ref).resolve()
                        if not within(target, package.resolve()):
                            errors.append(name + ": reference escape: " + ref)
                        elif not target.exists():
                            errors.append(name + ": missing reference: " + ref)
        except (OSError, ValueError, UnicodeError, RuntimeError) as exc:
            errors.append(name + ": " + str(exc))
    # Validate destination/source containment even for repository-only checks.
    try:
        link_map(repo, data)
    except (ValueError, OSError) as exc:
        errors.append(str(exc))
    return errors


def link_map(repo, data=None):
    data = data or manifest(repo)
    links = {}
    for prefix in data["clients"].values():
        base = relative(prefix)
        for name, source in packages(repo):
            links[(base / name).as_posix()] = source
    for dest, source in data.get("extra_links", {}).items():
        dest = relative(dest).as_posix()
        if dest in links:
            raise ValueError("duplicate destination: " + dest)
        links[dest] = repo / relative(source)
    for dest, source in links.items():
        canonical_path(repo, source)
        if source.is_symlink() or not within(source.resolve(), repo.resolve()):
            raise ValueError("source outside repository or symlink: " + dest)
        if not source.exists():
            raise ValueError("missing source: " + dest)
    return links


def check_install(repo, home):
    errors = []
    for rel, source in link_map(repo).items():
        target = home / rel
        if not target.is_symlink() or target.resolve() != source.resolve():
            errors.append("missing or divergent managed link: " + rel)
    # Hermes local skills have precedence over external_dirs. Any managed-name
    # local copy must be intentionally retired; same bytes still hide updates.
    names = set(manifest(repo)["skills"])
    local = home / ".hermes/skills"
    pending, seen = ([local] if local.exists() else []), set()
    while pending:
        directory = pending.pop()
        label = str(directory.relative_to(home))
        try:
            resolved = directory.resolve()
            if not within(resolved, local.absolute()) and not within(resolved, repo.resolve()):
                errors.append("uninspected Hermes local symlink; possible shadow: " + label)
                continue
            if resolved in seen:
                continue
            seen.add(resolved)
            entry = directory / "SKILL.md"
            if entry.is_symlink():
                errors.append("uninspected Hermes SKILL.md symlink; possible shadow: " + label)
            elif entry.is_file():
                text = entry.read_text()
                fm = re.match(r"\A---\n(.*?)\n---(?:\n|$)", text, re.S)
                declared = re.search(r'''(?m)^name:\s*["']?([a-zA-Z0-9_-]+)''', fm[1]) if fm else None
                if directory.name in names or (declared and declared[1] in names):
                    errors.append("Hermes local shadow: " + label)
            support = {"references", "scripts", "templates", "assets"} if entry.is_file() else set()
            pending.extend(p for p in directory.iterdir() if not p.name.startswith(".") and p.name not in CACHE | support and (p.is_symlink() or p.is_dir()))
        except (OSError, ValueError, RuntimeError) as exc:
            errors.append("unable to inspect Hermes local shadow/cycle: " + label + ": " + str(exc))
    return errors


def installation_warnings(repo, home):
    """Inspect only unmanaged direct skill-link metadata, never their contents."""
    data = manifest(repo)
    managed = set(link_map(repo, data))
    warnings = []
    for prefix in data["clients"].values():
        directory = home / relative(prefix)
        if not directory.is_dir():
            continue
        for entry in directory.iterdir():
            rel = entry.relative_to(home).as_posix()
            if rel not in managed and entry.is_symlink() and not entry.exists():
                warnings.append("unmanaged broken skill link (preserved): " + rel)
    return sorted(warnings)


def install(repo, home, apply=False, replace=(), backup_root=None):
    repo, home = repo.resolve(), home.expanduser().absolute()
    errors = validate(repo)
    if errors:
        raise ValueError("; ".join(errors))
    links = link_map(repo)
    replace = set(replace)
    if replace.difference(links):
        raise ValueError("unknown replacement path(s): " + ", ".join(sorted(replace.difference(links))))
    backup_root = (backup_root or home / ".local/state/agent-skills/backups").expanduser().absolute()
    if within(backup_root.resolve(), repo):
        raise ValueError("backups must be outside the repository")
    planned = []
    sources = [p.resolve() for p in links.values()]
    for rel, source in links.items():
        target = home / rel
        parent = target.parent.resolve()
        if not within(parent, home.resolve()) and not within(parent, repo):
            raise ValueError("destination parent escapes home/repository: " + rel)
        if target.is_symlink() and target.resolve() == source.resolve():
            continue
        physical_target = parent / target.name
        if any(within(physical_target, p) or within(p, physical_target) for p in sources):
            raise ValueError("destination overlaps canonical source: " + rel)
        conflict = os.path.lexists(target)
        if conflict and rel not in replace:
            raise ValueError("unapproved conflict: " + rel)
        planned.append((rel, source, conflict))
    result = {"planned": [p[0] for p in planned], "changed": [], "backups": [], "receipt": None}
    if not apply or not planned:
        return result
    receipt_dir = backup_root / uuid.uuid4().hex
    receipt_dir.mkdir(parents=True, mode=0o700)
    completed = []
    try:
        for rel, source, conflict in planned:
            target = home / rel
            backup = receipt_dir / rel
            if conflict:
                backup.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(target), str(backup))
                result["backups"].append({"target": rel, "backup": str(backup)})
            completed.append((target, backup if conflict else None))
            target.parent.mkdir(parents=True, exist_ok=True)
            target.symlink_to(os.path.relpath(source, target.parent.resolve()), target_is_directory=source.is_dir())
            result["changed"].append(rel)
        result["receipt"] = str(receipt_dir / "receipt.json")
        (receipt_dir / "receipt.json").write_text(json.dumps(result, indent=2) + "\n")
    except BaseException:
        for target, backup in reversed(completed):
            if target.is_symlink():
                target.unlink()
            if backup is not None and os.path.lexists(backup):
                shutil.move(str(backup), str(target))
        raise
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["check", "install", "hashes"])
    parser.add_argument("--home", type=Path, default=Path.home())
    parser.add_argument("--repo-only", action="store_true", help="validate canonical packages without installed-link checks")
    parser.add_argument("--apply", action="store_true", help="install links; without this flag installation is a dry run")
    parser.add_argument("--replace", action="append", default=[], metavar="RELATIVE_TARGET", help="explicitly back up and replace one managed conflict")
    parser.add_argument("--backup-root", type=Path)
    args = parser.parse_args(argv)
    try:
        errors = validate(REPO)
        if errors:
            print(json.dumps({"ok": False, "errors": errors}, indent=2))
            return 1
        if args.command == "install":
            print(json.dumps(install(REPO, args.home, args.apply, args.replace, args.backup_root), indent=2))
        else:
            if args.command == "check" and not args.repo_only:
                errors += check_install(REPO, args.home)
            warnings = installation_warnings(REPO, args.home) if args.command == "check" and not args.repo_only else []
            print(json.dumps({"ok": not errors, "errors": errors, "warnings": warnings, "packages": {name: package_hash(p) for name, p in packages(REPO)}}, indent=2))
            return int(bool(errors))
    except (ValueError, OSError, KeyError, TypeError, RuntimeError) as exc:
        print(json.dumps({"ok": False, "errors": [str(exc)]}, indent=2))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
