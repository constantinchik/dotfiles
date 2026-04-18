---
name: obsidian-note-taker
description: Use when saving, reading, updating, or organizing notes in the user's Obsidian vault; when the user asks to wrap up a conversation into Obsidian; or when vault context should inform work.
metadata:
  short-description: Work with the personal Obsidian vault
---

# Obsidian Note Taker

Use this skill for direct Obsidian vault work and for conversation wrapups that should become durable notes.

For full routing and formatting rules, read `../../agents/note-taker.md` when the task involves writing or updating notes.

Prefer the configured `obsidian` MCP server. If MCP tools are unavailable, state that the Obsidian MCP server is not active in the current session. Do not invent vault contents.

## Quick Workflow

Before writing:

1. Search for a similar existing note.
2. Search for related notes to link.
3. If updating an existing note, read it first and preserve useful content.
4. Link new notes from related existing notes when appropriate.

For ideas, never save only a one-liner. Flesh out the concept, problem, analysis, proposed solution, and concrete next steps.

For daily notes, read `Templates/Daily Note Template.md`, fill the target date variables, and append conversation summaries under `## Codex Sessions`.
