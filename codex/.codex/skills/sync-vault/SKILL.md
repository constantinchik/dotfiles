---
name: sync-vault
description: Use when the user asks to sync, audit, or update the Obsidian vault routing rules used by Codex.
metadata:
  short-description: Sync Obsidian vault routing rules
---

# Sync Vault

Use this skill when the user asks to sync vault routing, update note-taking rules, or align Codex's Obsidian guidance with the current vault structure.

## Workflow

1. Use the `obsidian-note-taker` skill for current vault conventions.
2. Inspect the vault structure through the Obsidian MCP tools.
3. Compare the observed folders, templates, tags, and daily-note conventions with the rules in `obsidian-note-taker`.
4. Propose concrete updates before changing skill files.
5. If the user confirms, update the stowed Codex skill source in the dotfiles repo.
6. Re-run `scripts/codex/enable-obsidian-plugin.sh` to materialize updated runtime skill files.
