---
description: "Log conversation results to Obsidian: decisions, learnings, artifacts, and daily summary."
argument-hint: [optional-focus]
allowed-tools: [mcp__obsidian__*, Read, Glob, Grep]
---

# Wrap Up To Obsidian

The user invoked this command with: $ARGUMENTS

Review the current conversation and extract vault-worthy items:

- Decisions made and why
- Problems solved and how
- Guides, tutorials, or recipes discussed or created
- Hardware or software configurations
- Ideas mentioned, even briefly
- Project documentation created or changed
- Research, learning, or useful references

For each candidate item, present it to the user before writing:

1. What: brief description
2. Action: create new note or update existing note
3. Path: proposed vault location
4. Title: proposed note title

Ask the user to confirm which items to save. Use clear options in prose: Save, Skip, or Modify.

For each confirmed item, use the `obsidian-note-taker` skill and the `obsidian` MCP tools. Follow the vault rules from `~/.codex/plugins/obsidian-vault/agents/note-taker.md` when available; do not duplicate large note-routing explanations in the user-facing response.

For the daily note, read `Templates/Daily Note Template.md` and create or append a session summary under `## Codex Sessions`.

If new folders are created, mention that the plugin and skill routing rules should be synced.
