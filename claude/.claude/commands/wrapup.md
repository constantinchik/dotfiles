---
allowed-tools: Agent, AskUserQuestion
description: Log conversation results to Obsidian - decisions, learnings, and daily summary
---

# Wrapup

Review the entire conversation and extract vault-worthy items:

- **Decisions** made and why
- **Problems solved** and how
- **Guides/tutorials** discussed or created
- **Hardware/software** configurations or discoveries
- **Ideas** mentioned (even in passing)
- **Project documentation** created or changed
- **Research, recipes, learning** shared

For each item, use `AskUserQuestion` to present it individually:
1. **What**: Brief description
2. **Action**: Create new note or update existing
3. **Path**: Proposed vault location
4. **Title**: Proposed title

Options per item: **Save** / **Skip** / **Modify**

After all items, also offer a **Daily Note** session summary.

For each confirmed item, spawn the `note-taker` agent with clear instructions: what to write, the note type, proposed title, and the content. The agent knows all vault rules — do not repeat them here.

For the daily note, tell the agent to read the Daily Note Template from the vault and create/append the session summary.

If the note-taker created any new folders during this session, suggest running `/sync-vault` to update the agent definition.
