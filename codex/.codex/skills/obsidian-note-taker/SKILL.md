---
name: obsidian-note-taker
description: Use when saving, reading, updating, or organizing notes in the user's Obsidian vault; when the user asks to wrap up a conversation into Obsidian; or when vault context should inform work.
metadata:
  short-description: Work with the personal Obsidian vault
---

# Obsidian Note Taker

Use this skill for direct Obsidian vault work and for conversation wrapups that should become durable notes.

## Vault

Vault path:

`$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal notes`

All note paths below are relative to this root.

Prefer the configured `obsidian` MCP server when available. It is backed by the Obsidian Local REST API plugin and normally exposes tools for listing files, reading files, searching, patching, appending, and deleting.

If MCP tools are unavailable, state that the Obsidian MCP server is not active in the current session. Do not invent vault contents.

## Structure

```text
1. Projects/          Active work with deadlines
   Home/
     Keyboard/
     Table/
2. Areas/             Ongoing responsibilities
   Health & Wellness/
   Relationships/
   Travel/
3. Resources/         Reference material
   Cooking/
   Guides/
     Audio Setup/
   Hardware/
   Ideas/
   Learning/
     Note-Taking/
   Quotes/
   Research/
   Software/
     OBS Studio/
     TTS/
4. Archive/           Completed or inactive items
Daily/                Daily notes, named YYYY-MM-DD.md
Excalidraw/           Drawings and diagrams
Templates/            Note templates
_QuickNote/           Inbox for rapid capture
```

## Routing

| Type | Path |
| --- | --- |
| area | `2. Areas/` |
| guide | `3. Resources/Guides/` |
| hardware | `3. Resources/Hardware/` |
| idea | `3. Resources/Ideas/` |
| learning | `3. Resources/Learning/` |
| project | `1. Projects/` |
| quote | `3. Resources/Quotes/` |
| recipe | `3. Resources/Cooking/` |
| research | `3. Resources/Research/` |
| software | `3. Resources/Software/` |

## Required Note Format

Every note needs frontmatter:

```yaml
---
tags:
  - relevant-tags
type: resource | idea | project
status: active | planning | ideation | completed | archived
created: YYYY-MM-DD
source: codex-session
---
```

Optional fields: `related`, `category`, `aliases`, `url`, `price`, `platform`.

Conventions:

- Use wiki links like `[[Note Name]]` for cross-references.
- Use lowercase hyphenated tags, such as `audio-setup`.
- End each note with `## Related`, then related wiki links.
- End with `---`, then `*Created: YYYY-MM-DD*` and `*Last updated: YYYY-MM-DD*`.
- Do not create `index.md`; Resources subfolders use `.base` database views.
- Prefer headers, tables, and bullets over long prose.
- English and Ukrainian content are both acceptable.

## Workflow

Before writing:

1. Search for a similar existing note.
2. Search for related notes to link.
3. If updating an existing note, read it first and preserve useful content.
4. Link new notes from related existing notes when appropriate.

For ideas, never save only a one-liner. Flesh out the concept, problem, analysis, proposed solution, and concrete next steps.

For daily notes:

1. Read `Templates/Daily Note Template.md`.
2. Fill template variables for the target date.
3. Create or update `Daily/YYYY-MM-DD.md`.
4. For conversation summaries, append under `## Codex Sessions`.

For wrapups:

1. Extract decisions, solved problems, guides, configuration details, ideas, project docs, research, recipes, and learning.
2. Present the candidate items to the user with proposed action, path, and title.
3. Save only confirmed items.
4. Offer a daily-note session summary.

After creating a new folder that is not in the structure above, tell the user the skill should be updated to include it.
