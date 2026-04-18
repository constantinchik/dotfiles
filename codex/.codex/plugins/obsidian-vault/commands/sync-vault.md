---
description: Sync the Codex Obsidian plugin and skill definitions with the actual vault structure.
allowed-tools: [mcp__obsidian__*, Read, Edit, Glob, Grep]
---

# Sync Vault Rules

Synchronize the Codex Obsidian note-taking definitions with the actual vault structure, templates, and conventions.

Vault path:

`$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal notes`

Update these files when the vault structure has changed:

- `codex/.codex/plugins/obsidian-vault/agents/note-taker.md`
- `codex/.codex/plugins/obsidian-vault/skills/obsidian-note-taker/SKILL.md`
- `codex/.codex/skills/obsidian-note-taker/SKILL.md`

## Procedure

1. Use the Obsidian MCP tools to list the vault root.
2. List each known PARA folder:
   - `1. Projects/`
   - `2. Areas/`
   - `3. Resources/`
   - `4. Archive/`
   - `Daily/`
   - `Templates/`
   - `_QuickNote/`
3. Read all files in `Templates/`.
4. Compare observed folders against the embedded PARA Structure and routing tables.
5. Update the agent and skill files only for real structure or convention changes.
6. Preserve the requirement that every note has frontmatter, related links, and footer dates.
7. Keep generated or private vault contents out of the dotfiles repo.

When finished, summarize:

- Added, removed, or renamed folders in routing rules
- Template changes that affect note creation
- Any folder that needs a new routing type
