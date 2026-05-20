---
name: wrapup
description: Use when the user types "wrapup", asks to wrap up the current Codex session, or wants conversation results saved to Obsidian.
metadata:
  short-description: Wrap up the session into Obsidian
---

# Wrapup

Use this skill when the user asks for a wrapup, including the bare prompt `wrapup`.

This is the Codex-native replacement for the Claude-style `/wrapup` command. Codex CLI 0.121 does not load user-defined slash commands from `~/.codex/commands`, so the reliable trigger is a normal prompt such as `wrapup` or `wrap up this session`.

## Workflow

1. Use the `obsidian-note-taker` skill for vault rules and note formatting.
2. Review the current conversation and extract durable items:
   - Decisions made and why
   - Problems solved and how
   - Guides, recipes, or procedures discussed or created
   - Hardware or software configuration details
   - Ideas, research, references, and learning
   - Project documentation created or changed
3. Present candidate items before writing:
   - What: brief description
   - Action: create a new note or update an existing note
   - Path: proposed vault location
   - Title: proposed note title
4. Ask the user to confirm which items to save. Use clear options in prose: Save, Skip, or Modify.
5. Save only confirmed items through the Obsidian MCP tools.
6. For the daily note, read `Templates/Daily Note Template.md` and create or append a session summary under `## Codex Sessions`.
