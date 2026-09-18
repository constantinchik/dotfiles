---
name: obsidian
description: Read, search, and navigate the personal Obsidian vault via the `obsidian` CLI. Use whenever a task needs context from the vault — home server/network setup, hardware specs, guides, project notes, daily notes — or when the user says "check my obsidian/vault/notes". For CREATING or UPDATING notes, delegate to the note-taker agent instead.
allowed-tools: Bash(obsidian:*), Bash(vault-ask:*)
---

# Obsidian Vault Access

Vault: `/Users/cost/Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal notes` (CLI default target — do not pass `vault=` unless working with `TestClaude`).

## Tool Priority — strict order

1. **`obsidian` CLI** (`/usr/local/bin/obsidian`) — always use this for vault reads, searches, and navigation.
2. **Direct filesystem** (`cat`/`grep`/`find` over the vault path) — fallback ONLY if the CLI is genuinely unavailable (see Troubleshooting). Tell the user you fell back and why.
3. **Never** use the `mcp__obsidian__*` REST API tools. That server is deprecated here: it depends on the Local REST API plugin listening on `127.0.0.1:27124`, which is usually not running, and it fails with `Connection refused`.

## Writing Notes

Do not write to the vault from the main session. Spawn the `note-taker` agent — it owns the PARA structure, frontmatter schema, linking conventions, and the no-orphans rule. Give it what to write; it knows the rules.

Exception: trivial, explicitly-scoped appends the user dictated verbatim may use `obsidian append path="..." content="..."`.

## Reading & Searching

Arguments are `key=value`; quote values containing spaces. `path=` is exact (`folder/note.md`); `file=` resolves by name like a wikilink.

| Goal | Command |
|------|---------|
| Find notes containing text | `obsidian search query="immich" format=json` |
| Find text **with matching lines** | `obsidian search:context query="photos.chiker.dev" format=json` |
| Read a note | `obsidian read path="1. Projects/Home/Server/Server.md"` |
| List notes in a folder | `obsidian files folder="1. Projects/Home/Server" ext=md` |
| List folders | `obsidian folders folder="3. Resources"` |
| Note metadata (size, dates) | `obsidian file path="..."` |
| Outgoing links / backlinks | `obsidian links path="..."` / `obsidian backlinks path="..."` |
| Today's daily note | `obsidian daily:read` / `obsidian daily:path` |
| Recently opened notes | `obsidian recents` |
| Tags in vault | `obsidian tags` / `obsidian tag name="..."` |
| Vault stats | `obsidian vault` |
| Full command list | `obsidian --help` |

`obsidian --help` is the authority on flags — check it rather than guessing.

## Fast Path — one specific fact

For a **specific factual lookup** ("what's the IP of the corner WLED", "which PSU does the
floor lamp use"), use `vault-ask` instead of search-then-read. It fuses search, semantic
re-ranking and reading into a single call, so it costs one round trip rather than two:

```
vault-ask "what is the IP of Ana's floor lamp"          # question doubles as search terms
vault-ask "which PSU does the floor lamp use" "floor lamp"   # explicit terms when needed
```

It prints the top 2 candidates with probabilities, then both notes in full.

- **Read both.** Top-1 is right ~5/7 of the time, top-2 ~6/7. The runner-up is the recovery.
- **`obsidian search` returns PATH-ALPHABETICAL order, not relevance.** In benchmarking, the
  correct note was never at raw rank 1 (it landed at 17/17, 9/11, 46/57...). Never treat the
  first raw search hit as the best one — that is what the re-rank step is for.
- **Exit 2 means zero candidates.** Re-ranking cannot recover a note fast search never
  returned. Multi-word natural phrases often return nothing (`"wifi keeps dropping"` → 0).
  Retry with single distinctive nouns, then fall back to the Research Workflow below.
- Requires `TYPESAFE_API_KEY`; it calls a paid API once per invocation.

Use the full Research Workflow instead for **broad** questions ("tell me about my server
setup"), where there is no single right note to rank.

## Research Workflow

When a task needs vault context (e.g. "research my setup in obsidian"):

1. `obsidian search query="<topic>" format=json` — get candidate note paths. Run several searches in parallel for different terms.
2. `obsidian read path="..."` on each hit — read fully; don't answer from search snippets alone.
3. `obsidian links` / `obsidian backlinks` on the central note to pull in connected notes the search missed.
4. Prefer `search:context` when you need to locate a specific line (a config value, an IP, a domain) across many notes.

Notes are the user's own record of their setup: treat them as authoritative for intent and history, but verify anything live (running services, current config) against the actual system before acting on it.

## Troubleshooting

- `command not found` → confirm with `command -v obsidian`. Note `obs` on this machine is **OBS Studio**, not Obsidian.
- Commands hang or return nothing → the Obsidian desktop app must be running; check with `pgrep -x Obsidian`. Ask the user to open it rather than silently falling back.
- Wrong vault in results → `obsidian vaults` lists known vaults; `obsidian vault` shows the active one.
