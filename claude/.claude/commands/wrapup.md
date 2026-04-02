---
allowed-tools: mcp__obsidian__obsidian_simple_search, mcp__obsidian__obsidian_complex_search, mcp__obsidian__obsidian_get_file_contents, mcp__obsidian__obsidian_put_content, mcp__obsidian__obsidian_append_content, mcp__obsidian__obsidian_patch_content, mcp__obsidian__obsidian_get_periodic_note, mcp__obsidian__obsidian_list_files_in_dir, mcp__obsidian__obsidian_batch_get_file_contents, AskUserQuestion
description: Log conversation results to Obsidian - decisions, learnings, and daily summary with intelligent linking
---

# Wrapup: Log Conversation to Obsidian

You are wrapping up this Claude Code session. Your task is to intelligently capture valuable outcomes and log them to Obsidian with proper organization and linking.

## Step 1: Mine the Conversation

Review our entire conversation and extract **every** item that could be valuable in the vault:

### Standard Extractions
- **Decisions made** and why
- **Problems solved** and how
- **New learnings** or techniques

### Vault-Worthy Content (check for ALL of these)
- **Guides/tutorials** discussed, created, or explained
- **Hardware/device** configurations, specs, or troubleshooting
- **Software/tool** setups, configs, or discoveries
- **Ideas** mentioned in passing (even if not the main topic)
- **Recipes, resources, research** shared or discovered
- **Project documentation** created or significantly changed
- **Inventory items** — new hardware, gear, or software mentioned

### Topics & Keywords
- Technologies discussed
- Domains covered
- Project names if applicable

## Step 2: Search for Related Notes

Using the extracted topics, search Obsidian for related existing notes.

Search priority based on topic:
- **Code/Config work** → `3. Resources/Software/` or `3. Resources/Guides/`
- **Learning/Research** → `3. Resources/Learning/` or `3. Resources/Research/`
- **Device/Setup** → `3. Resources/Hardware/`
- **Ideas/Concepts** → `3. Resources/Ideas/`
- **Project work** → `1. Projects/`
- **Workflow/Process** → `2. Areas/` or `3. Resources/`

## Step 3: Present Items One by One

Use `AskUserQuestion` to present **each vault-worthy item individually**:

For each item show:
1. **What**: Brief description of the content
2. **Action**: Create new note OR update existing note (name which one)
3. **Path**: Proposed vault location
4. **Title**: Proposed note title
5. **Tags**: Proposed tags

Options per item: **Save** / **Skip** / **Modify** (let user change path/title)

After all items are presented, also offer a **Daily Note summary** entry.

## Step 4: Create/Update Notes

After user confirms each item:

### Vault Rules (always follow)

- **Frontmatter required** on every note:
  ```yaml
  ---
  tags:
    - relevant-tags
  type: resource | idea | project
  status: active | planning | ideation | completed | archived
  related: "[[Note 1]], [[Note 2]]"
  created: YYYY-MM-DD
  source: claude-session
  ---
  ```
- **Wiki links**: `[[Note Name]]` for all cross-references
- **Tags**: lowercase, hyphenated
- **Cross-reference**: always include `## Related` section with wiki links
- **Folder indexes**: Resources subfolders use `.base` database views — do NOT create `index.md`
- **Footer**: end with `---` then `*Created*` and `*Last Updated*` dates

### For New Notes

Use `mcp__obsidian__obsidian_put_content` to create the note with proper structure.

### For Existing Note Updates

Use `mcp__obsidian__obsidian_patch_content` to append new information under the appropriate heading. Also update the `*Last Updated*` date.

### For Daily Note

1. Get today's daily note: `mcp__obsidian__obsidian_get_periodic_note(period: "daily")`
2. If exists, patch to add/append a `## Claude Sessions` section:
   ```markdown
   ### Session: HH:MM - [Brief Topic]
   **Context:** What we were working on
   **Outcomes:**
   - Key outcome 1
   - Key outcome 2
   **Notes Created/Updated:** [[Note 1]], [[Note 2]]
   ```
3. If no daily note exists, read `Templates/Daily Note Template.md` from the vault, fill in the template variables (dates, aliases), and create the note at `Daily/YYYY-MM-DD.md`. Then append the Claude Sessions section.

## Step 5: Confirm Completion

Summarize all operations performed:
- Notes created (with vault paths)
- Notes updated (with what changed)
- Daily note entry added
- Wiki links established

## Important Guidelines

- **Ask per item** — present each vault-worthy item individually for confirmation
- **Preserve existing content** — when updating notes, append rather than replace
- **Use wiki links** — connect related notes with `[[Note Name]]` syntax
- **Match existing style** — follow formatting patterns already in the vault
- **Be concise in daily notes** — brief summary, not full documentation
- **Date everything** — include timestamps for traceability
- **Handle edge cases**:
  - If conversation was trivial, offer just a daily note entry
  - If multiple topics, present each as a separate item
  - If proposed title exists, suggest updating or alternative title
  - Warn about any sensitive content before logging

## Vault Structure Reference

```
1. Projects/     - Active projects with deadlines
2. Areas/        - Ongoing responsibilities
3. Resources/    - Reference materials
   ├── Cooking/
   ├── Guides/       - How-tos, tutorials, strategies
   ├── Hardware/     - Physical devices, gear, specs
   ├── Ideas/
   ├── Learning/
   ├── Note-Taking/
   ├── Quotes/
   ├── Research/
   └── Software/     - Apps, tools, configurations
4. Archive/      - Completed/inactive items
Daily/           - Daily notes (YYYY-MM-DD.md)
Templates/       - Note templates
_QuickNote/      - Inbox for rapid capture
```
