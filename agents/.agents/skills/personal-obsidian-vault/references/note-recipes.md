# Local note recipes

## Routing
Verify deeper folders through the CLI; these are starting points, not a frozen inventory.

| Kind | Root |
| --- | --- |
| active outcome/project | `1. Projects/` |
| ongoing responsibility | `2. Areas/` |
| guide | `3. Resources/Guides/` |
| hardware | `3. Resources/Hardware/` |
| idea | `3. Resources/Ideas/` |
| learning | `3. Resources/Learning/` |
| quotation | `3. Resources/Quotes/` |
| recipe | `3. Resources/Cooking/` |
| research | `3. Resources/Research/` |
| software | `3. Resources/Software/` |

Use matching established subfolders, e.g. Hardware's Computers & Peripherals or Guides' topic folders. Home & Furniture, Storage and Vehicles also have established resource routes; discover their current paths. `_QuickNote/` is the ambiguous inbox, not the default. Other roots: `4. Archive/`, `Daily/`, `Templates/`, `Excalidraw/`.

Optional `vault-classify "Title"` accepts note text on stdin and suggests two routing buckets via a paid API. Use only when routing is genuinely unclear. Do not feed it `status:`: historical tests found that field uninformative. Treat guide/software and research/area boundaries cautiously; low-confidence alternatives go back to the user. It never files notes itself.

## Format
Match nearby notes/templates. Usual frontmatter: lowercase-hyphenated `tags`, `type`, `status`, `created`, `source`; optional `related`, `category`, `url`, `price`, `platform`. Resource templates generally use type resource/idea/project and status active/planning/ideation/completed/archived; inventory templates may have specific hardware/purchased values.

Use `## Related` and the existing created/updated footer style. No wikilink aliases in tables. Ordinary Resources folders use `.base` views, not new index.md files; a separately approved wiki keeps its own schema. Daily notes use the current template/plugin conventions and are opt-in. Keep updates before the footer.

## Hardware and implementation notes
Read the project and linked component notes. Record voltage, bus/address/baud, GPIO/boot-strap constraints and pull-ups where relevant; distinguish sourced specs from physical breakout/clone checks. Purchased-device notes include variant/source, observed price, interfaces/power, intended use and outstanding verification—not just catalog text.

When an approved note update follows implementation, distinguish planned, current-trial and verified-final state. Offer extra component notes/backlinks separately if outside the approved note scope.
