---
allowed-tools: mcp__obsidian__obsidian_list_files_in_dir, mcp__obsidian__obsidian_list_files_in_vault, mcp__obsidian__obsidian_batch_get_file_contents, Read, Edit, Glob, AskUserQuestion
description: Sync the note-taker agent definition with the actual Obsidian vault structure
---

# Sync Vault

Synchronize the `note-taker` agent definition with the actual Obsidian vault structure, templates, and conventions.

## Vault Path

`/Users/cost/Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal notes`

## Steps

### 1. Read the current agent file

- Use Glob to find `~/.claude/agents/note-taker.md`
- Read its full contents and identify each section by `##` headers

### 2. Scan the vault folder structure

- Call `mcp__obsidian__obsidian_list_files_in_dir` for each top-level PARA folder:
  - `1. Projects/`
  - `2. Areas/`
  - `3. Resources/`
  - `4. Archive/`
  - `Daily/`
  - `Templates/`
  - `_QuickNote/`
- For each subfolder of `3. Resources/`, scan one level deeper to capture sub-subfolders (e.g. `Guides/Audio Setup/`)
- **Only record directories** (entries ending in `/`), not individual note files

### 3. Read all templates

- List the `Templates/` directory
- Use `mcp__obsidian__obsidian_batch_get_file_contents` to read all template files
- Extract from them:
  - **Frontmatter schema**: required and optional fields, allowed values for `type` and `status`
  - **Daily Note Template**: sections, template variables (`{{date:...}}` patterns)
  - **Note type structures**: what sections each template defines (guide, project, resource, etc.)

### 4. Compute changes

Compare the scanned vault state against each section of the agent file:

| Agent section | What to compare |
|---|---|
| `## PARA Structure` (ASCII tree) | Folders added or removed |
| `## Note Types & Routing` (table) | New routes, removed routes, path changes |
| `## Frontmatter` (YAML block + optional list) | Field additions/removals, enum value changes |
| `## Structure by Note Type` | New note type structures derived from templates |
| `## Daily Notes` | Template variable or section changes |

**Routing rules:**
- Each direct subfolder of `3. Resources/` maps to a note type (lowercase name → path)
- Sub-subfolders (e.g. `Guides/Audio Setup/`) appear in the PARA tree but are NOT separate routing table rows — they are sub-paths within the parent type
- `1. Projects/` maps to type `project`
- `2. Areas/` maps to type `area` — add this if missing
- If a routing entry points to a folder that no longer exists, mark it for removal

### 5. Present changes for approval

Use `AskUserQuestion` to show a clear summary of all detected changes:

- Group by section
- Mark additions with `+` and removals with `-`
- Offer options: **Apply All** / **Apply Selectively** / **Cancel**
- If "Apply Selectively", present each section individually for approval

If no changes are detected, report that the agent definition is already in sync and stop.

### 6. Apply approved changes

Use `Edit` to update **only the affected sections** of the agent file. Key rules:

- **Do NOT rewrite the entire file** — target specific sections between `##` headers
- **Preserve all content** outside changed sections, especially:
  - `## Ideas — Always Elaborate`
  - `## Before Writing`
  - `## After Creating New Folders`
  - `## Conventions` (unless template-derived changes warrant an update)
- Keep the ASCII tree format consistent: use `├──`, `└──`, and proper indentation
- Keep the routing table in the existing markdown table format

### 7. Report

Summarize what was changed in a short list.

## Important

- The agent file is likely a symlink from the dotfiles repo via stow — editing in place propagates changes to the repo. This is expected.
- When the vault gains a new top-level PARA folder (rare), add it to both the tree and consider whether it needs a routing entry.
- Templates are the source of truth for frontmatter schema and note type structures — prefer what templates define over what the agent file currently says.
