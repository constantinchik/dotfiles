# Shared local skills

Source: `agents/.agents/skills/`. `manifest.json` lists managed packages, discovery locations, compatibility links and provenance. All local clients read the same package files; no copy-sync service runs.

```sh
python3 scripts/agents/test_skill_library.py
python3 scripts/agents/skill_library.py check --repo-only
python3 scripts/agents/skill_library.py install           # dry run
python3 scripts/agents/skill_library.py install --apply
python3 scripts/agents/skill_library.py check
```

The helper is also installed at `~/.agents/skill-library/skill_library.py`. It needs Python 3.9+ and no extra packages. Tests use the agent scratch directory, not system temp.

## Discovery

- Codex: `~/.agents/skills`; legacy `~/.codex/skills` links and the old obsidian-note-taker entrypoint remain compatible.
- Claude: individual `~/.claude/skills` links plus a thin global guide; account `synced` skills are untouched.
- OpenCode: individual `~/.config/opencode/skills` links, preserving existing HA client/server variants.
- Default Hermes: add `~/.agents/skills` to `skills.external_dirs` through `hermes config set`, preserving every existing entry. New skills still land profile-local until deliberately promoted. Local same-name skills shadow shared ones: archive the exact approved duplicates outside the active skill tree before acceptance. Do not edit another profile.

The macOS/Linux install scripts run the bounded linker after Stow. For an existing dirty checkout, run only this helper—not the whole dotfiles installer, `stow --adopt`, or a reset.

## Conflicts and rollback

A dry run checks all destinations before any changes. Unexpected existing targets are refused. For a reviewed legacy target, pass its exact home-relative name, e.g. `--replace .claude/skills/obsidian`; repeat for each approved conflict. With `--apply`, replaced targets are moved to a unique directory under `~/.local/state/agent-skills/backups/`, with a receipt. `--backup-root` must be outside the repository. Unmanaged files/skills are not traversed or removed. On a failed install the completed link changes are rolled back.

For manual rollback, use the receipt's target/backup pairs: verify the target is still the managed link, remove only that link, and move the backup back. Newly created links are listed in `changed`; remove only those still pointing to this library. Restore any separately backed-up Hermes config through the supported CLI and return archived default-profile packages if required. Never restore an entire dirty checkout.

## Adding or changing a skill

Keep only knowledge an agent would not already know: local gotchas, conventions and useful navigation. Humans review these files. Do not pad the body or hide boilerplate in references.

1. Extend a canonical package where possible; preserve genuinely useful support files. New packages use flat scalar frontmatter: name, description, version, license. Descriptions should be ≤60 characters.
2. Keep private facts, credentials, raw conversations and runtime state out of this public repository. Private procedures stay local unless explicitly approved for disclosure.
3. Add a new name/provenance to the manifest, then validate, dry-run and apply the links. The check reports managed link drift, missing/escaping support paths, forbidden runtime files, duplicate names, personal absolute paths and Hermes local shadows. Use simple package-local paths in Markdown links or backticks; unsupported local destinations with parentheses/backslash escapes are refused rather than partially parsed. Unmanaged broken skill links are warnings and stay untouched. `hashes` covers whole packages. These deterministic checks do not prove prose is useful or catch every secret; human review remains required.
4. For discovery acceptance, start fresh Hermes/Claude/Codex sessions and ask them to use shared-skill-maintenance and read its referenced probe. Change the benign marker once and verify every client sees the change without copying. Existing sessions may retain cached indexes.

No background publishing or automatic commits. The six starter packages are Obsidian access/conventions, local knowledge discovery, shared-skill maintenance, wrapup and routing audit—not a claim that every historical Hermes skill was ported. Existing specialized skills remain with their original owners. MCP repair and a remote read-only knowledge API are separate work.
