---
name: shared-skill-maintenance
description: "Use when curating or sharing learned procedures."
version: 1.0.0
license: MIT
---
# Shared procedures
Canonical packages: `~/.agents/skills/`. Installer/checker: `~/.agents/skill-library/skill_library.py` (`check`, `hashes`, `install`; installation is dry-run unless `--apply`). Manifest/provenance and usage are alongside the helper.

Keep only non-obvious local knowledge, gotchas or pointers that simplify finding it. Humans review these files: omit generic advice, boilerplate and redundant references. Extend an existing package before adding another.

Update canonical packages in place. New Hermes skills stay local until deliberately promoted; classify private facts into approved notes, not this public dotfiles library. Preserve useful support files, update the manifest, run checks, then verify native discovery. No copied client variants or automatic publication.

For installation tests only, read `references/probe.md` and report its revision marker and resolved source.
