---
allowed-tools: mcp__obsidian__obsidian_simple_search, mcp__obsidian__obsidian_complex_search, mcp__obsidian__obsidian_get_file_contents, mcp__obsidian__obsidian_put_content, mcp__obsidian__obsidian_append_content, mcp__obsidian__obsidian_patch_content, mcp__obsidian__obsidian_get_periodic_note, mcp__obsidian__obsidian_list_files_in_dir, mcp__obsidian__obsidian_batch_get_file_contents, AskUserQuestion
description: Log conversation results to Obsidian - decisions, learnings, and daily summary with intelligent linking
---

# Wrapup: Log Conversation to Obsidian

You are wrapping up this Claude Code session. Your task is to intelligently capture valuable outcomes and log them to Obsidian with proper organization and linking.

## Step 1: Analyze This Conversation

Review our entire conversation and extract:

### Key Decisions Made
- What choices were made and why
- Trade-offs considered
- Final approach selected

### Problems Solved / Solutions Implemented
- What issues were addressed
- How they were resolved
- Code changes or configurations made (files, functions, etc.)

### New Learnings or Techniques
- Concepts discovered or clarified
- Tools or methods learned
- Best practices identified

### Topics & Keywords (for categorization)
- Technologies discussed (e.g., typescript, neovim, macos, docker)
- Domains covered (e.g., dotfiles, audio-setup, productivity)
- Project names if applicable

**Present this analysis to me in a structured format before proceeding.**

## Step 2: Search for Related Notes

Using the extracted topics and keywords, search Obsidian for potentially related existing notes.

Use `mcp__obsidian__obsidian_simple_search` with key topic terms to find related notes.

Search priority based on conversation topic:
- **Code/Config work** -> `3. Resources/Tools/` or `1. Projects/`
- **Learning/Research** -> `3. Resources/Learning/` or `3. Resources/Research/`
- **Device/Setup** -> `3. Resources/Devices/`
- **Workflow/Process** -> `2. Areas/` or `3. Resources/`
- **Ideas/Concepts** -> `3. Resources/Ideas/`

## Step 3: Present Options to User

Use `AskUserQuestion` to present options and get confirmation:

### Show the user:

1. **Existing Notes That May Need Updates**
   List any related notes found with reasons for potential updates.

2. **Suggested New Note** (if applicable)
   - Proposed Title
   - Proposed Location (following PARA structure):
     - `1. Projects/` - active work with deadlines
     - `2. Areas/` - ongoing responsibilities
     - `3. Resources/Tools/` - software/config documentation
     - `3. Resources/Learning/` - concepts and techniques
     - `3. Resources/Research/` - investigation findings
     - `3. Resources/Devices/` - hardware-related
     - `3. Resources/Ideas/` - future possibilities
   - Proposed Tags
   - Related Notes to link

3. **Daily Note Summary Preview**
   What will be appended to today's daily note.

**Wait for user confirmation before proceeding.**

## Step 4: Create/Update Notes

After user confirms:

### For New Notes

Use this frontmatter format:
```yaml
---
tags:
  - [relevant-tag-1]
  - [relevant-tag-2]
type: resource
status: active
related: [[Related Note 1]], [[Related Note 2]]
created: YYYY-MM-DD
source: claude-session
---
```

Structure the note with:
```markdown
## Overview
Brief summary of what this note covers.

## Key Points
- Main point 1
- Main point 2

## Details
Detailed content organized by topic...

## Related
- [[Related Note 1]] - connection reason
- [[Related Note 2]] - connection reason

---
**Last Updated**: YYYY-MM-DD
```

Use `mcp__obsidian__obsidian_put_content` to create the note.

### For Existing Note Updates

Use `mcp__obsidian__obsidian_patch_content` to append new information under the appropriate heading:
- operation: "append"
- target_type: "heading"
- target: "## Related" or appropriate section

Also update the `**Last Updated**` date.

### For Daily Note

1. Get today's daily note:
   ```
   mcp__obsidian__obsidian_get_periodic_note(period: "daily")
   ```

2. If exists, patch it to add/append a `## Claude Sessions` section:
   ```markdown
   ### Session: HH:MM - [Brief Topic]
   **Context:** What we were working on
   **Outcomes:**
   - Key outcome 1
   - Key outcome 2
   **Notes Created/Updated:** [[Note 1]], [[Note 2]]
   ```

3. If no daily note exists, create one at `Daily/YYYY-MM-DD.md` with proper frontmatter:
   ```yaml
   ---
   date: YYYY-MM-DD
   tags:
     - daily-note
   ---
   ```
   Then add the Claude Sessions section.

## Step 5: Confirm Completion

Summarize all operations performed:
- Notes created (with vault paths)
- Notes updated (with what changed)
- Daily note entry added
- Wiki links established between notes

## Important Guidelines

- **Ask before acting** - Always present your plan and get confirmation
- **Preserve existing content** - When updating notes, append rather than replace
- **Use wiki links** - Connect related notes with `[[Note Name]]` syntax
- **Match existing style** - Follow formatting patterns already in the vault
- **Be concise in daily notes** - Brief summary, not full documentation
- **Date everything** - Include timestamps for traceability
- **Handle edge cases**:
  - If conversation was trivial, offer just a daily note entry
  - If multiple topics, offer separate notes or combined
  - If proposed title exists, suggest updating or alternative title
  - Warn about any sensitive content before logging

## Obsidian Vault Structure Reference

```
1. Projects/     - Active projects with deadlines
2. Areas/        - Ongoing responsibilities
3. Resources/    - Reference materials
   ├── Cooking/
   ├── Devices/
   ├── Ideas/
   ├── Learning/
   ├── Note-Taking/
   ├── Quotes/
   ├── Research/
   └── Tools/
4. Archive/      - Completed/inactive items
Daily/           - Daily notes (YYYY-MM-DD.md format)
Templates/       - Note templates
```
