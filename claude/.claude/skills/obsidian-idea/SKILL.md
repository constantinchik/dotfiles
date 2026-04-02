---
name: obsidian-idea
description: Quickly capture an idea or thought to Obsidian. Use when the user says "I have an idea", "save this idea", "log this thought", or wants to jot something down quickly.
argument-hint: <idea description>
allowed-tools: mcp__obsidian__obsidian_put_content, mcp__obsidian__obsidian_simple_search, AskUserQuestion
---

# Quick Idea Capture

Rapidly save an idea to Obsidian with minimal friction.

## Decision: Quick vs Detailed

- **One-liner or vague thought** → `_QuickNote/` as raw text, no frontmatter
- **Fleshed-out concept** → `3. Resources/Ideas/` with full structure

## Quick capture (_QuickNote/)

Filename: `_QuickNote/<Short Title>.md`
Content: Just the idea text. No frontmatter. Keep it raw.

## Detailed idea (3. Resources/Ideas/)

```yaml
---
type: idea
status: ideation
tags:
  - topic-tags
created: YYYY-MM-DD
source: claude-session
rating: 1-5
---
```

Sections: Core Concept > Problem/Opportunity > Proposed Solution > Next Steps > Related

## Rules

- Default to quick capture unless the idea is clearly well-developed
- Search for existing related ideas before creating
- Use wiki links `[[Note Name]]` to connect related notes
- Tags: lowercase, hyphenated
- Ask the user only if the destination is ambiguous
- Do NOT create `index.md` files — folders use `.base` database views
