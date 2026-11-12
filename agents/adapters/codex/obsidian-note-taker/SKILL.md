---
name: obsidian-note-taker
description: Compatibility entrypoint for the shared vault skills.
---
# Legacy vault entrypoint
Load the native shared `obsidian` and `personal-obsidian-vault` skills from ~/.agents/skills. Those packages own current CLI access, note conventions and approval/readback rules. Do not use the deprecated REST MCP, hardcoded vault paths or a separate materialized copy. This alias grants no additional permissions.
