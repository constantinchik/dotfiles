# Local CLI details
Arguments are `key=value`; exact paths use `path=`, name resolution uses `file=`. Check `obsidian help <command>` for live syntax.

```sh
obsidian search query="topic" limit=10 format=json
obsidian search:context query="topic" limit=10 format=json
obsidian read path="Folder/Note.md"
obsidian files folder="Folder" ext=md
obsidian folders
obsidian links path="Folder/Note.md"
obsidian backlinks path="Folder/Note.md"
```

- Search results can be path-ordered, not relevance-ranked. Retry distinctive nouns when natural phrases miss.
- Optional `vault-ask "specific question" "search terms"` searches, reranks and reads two candidates through a paid API. Read both; confidence is not verification. Exit 2 means no candidates. Plain CLI search needs no paid lookup.
- The CLI lacks a section-patch primitive: read/preserve the full note, then use `obsidian create path="..." overwrite content="..."` for authorized replacements; read back.
- `move` needs an existing destination folder and explicit final filename. Otherwise it can create an extensionless note and rewrite backlinks to it. Obtain approval for a folder-creation filesystem step if needed.
- Daily notes: use `daily:path`/`daily:read` and the current template, not a guessed daily path. Add authorized summaries before the footer in the current agent's subsection.
