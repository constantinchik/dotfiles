---
allowed-tools: mcp__obsidian__obsidian_put_content, mcp__obsidian__obsidian_append_content, mcp__obsidian__obsidian_patch_content, mcp__obsidian__obsidian_get_file_contents, mcp__obsidian__obsidian_simple_search, mcp__obsidian__obsidian_list_files_in_dir, AskUserQuestion
description: Create or update an Obsidian note - guide, hardware, software, idea, project, or resource
argument-hint: [type] <topic>
---

# Create Obsidian Note

Create a note in the vault based on conversation context. Infer the note type from `$ARGUMENTS` or ask.

## Note Types & Destinations

| Type | Path | When to use |
|------|------|-------------|
| `guide` | `3. Resources/Guides/` | How-to guides, tutorials, strategies |
| `hardware` | `3. Resources/Hardware/` | Physical devices, gear, specs |
| `software` | `3. Resources/Software/` | Apps, tools, configurations |
| `idea` | `3. Resources/Ideas/` | Fleshed-out concepts |
| `project` | `1. Projects/` | Project plans, specs, docs |
| `resource` | `3. Resources/<subfolder>/` | Anything else: cooking, quotes, learning, research |

## Process

1. **Determine type** from arguments or conversation context
2. **Search vault** (`obsidian_simple_search`) for existing notes on this topic
3. **Present plan** via `AskUserQuestion`: title, path, tags, related notes found. Ask whether to create new or update existing
4. **Create note** after confirmation

## Vault Rules (always follow)

- **Frontmatter required** on every note:
  ```yaml
  ---
  tags:
    - relevant-tags
  type: resource | idea | project
  status: active | planning | ideation | completed | archived
  created: YYYY-MM-DD
  source: claude-session
  ---
  ```
- **Wiki links**: `[[Note Name]]` for all cross-references
- **Tags**: lowercase, hyphenated (e.g. `#audio-setup`, `#window-management`)
- **Cross-reference**: always include a `## Related` section with wiki links at the bottom
- **Folder indexes**: each Resources subfolder has a `.base` database view — do NOT create `index.md` files
- **Footer**: end with `---` then `*Created: YYYY-MM-DD*` and `*Last updated: YYYY-MM-DD*`

## Structure by Type

**guide**: Overview > step-by-step sections > Tips/Troubleshooting > Related
**hardware**: Specs table > In My Setup > Connection/Usage details > Related
**software**: Overview > Features > Installation/Config > Related
**idea**: Core Concept > Problem/Opportunity > Proposed Solution > Next Steps checklist > Related
**project**: Outcome/Status/Deadline > Context > Tasks checklist > Resources > Related

## Guidelines

- Match tone and depth of existing notes in the target directory
- Keep notes scannable: headers, tables, bullets over prose
- Bilingual content OK (English + Ukrainian)
