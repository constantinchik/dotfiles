# Contributing

Keep changes bounded to the requested packages or documents. Inspect Git status,
the proposed base and the affected helpers first. Preserve unrelated edits;
use a clean isolated worktree when the existing checkout is dirty. Stage owned
paths explicitly and review the complete incremental diff before publication.
Keep private procedures, account data, credentials, network/device inventories
and personal absolute paths out of committed documentation.

Repository changes and PR publication do not authorize merging, installation,
re-stowing, changing live links/storage, service operations or device actions.
Obtain explicit approval for those operations and their scope. Existing installer
commands are operational entrypoints, not validation steps; read the
[installation cautions](README.md#installation) before considering them.

## Offline checks

From the repository root, Python 3.9+ and Git suffice for these existing shared
library checks; no package installation, client login or service is needed:

```sh
python3 scripts/agents/skill_library.py check --repo-only
```

The existing test suite creates a scratch tree under `Path.home()`. This wrapper
runs the same suite with that method temporarily redirected to a disposable
directory, leaving the real home and agent profiles untouched. Fixture installs
and backups stay inside that directory; bytecode writes are disabled. Resolving
the temporary path avoids symlink aliases in filesystem assertions on macOS.

```sh
python3 -B - <<'PYTEST'
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch
import runpy
import sys

with TemporaryDirectory(prefix="dotfiles-doc-check-") as scratch:
    with patch.object(Path, "home", return_value=Path(scratch).resolve()):
        sys.argv = ["scripts/agents/test_skill_library.py"]
        runpy.run_path(sys.argv[0], run_name="__main__")
PYTEST
```

Also run `git diff --check`, inspect the diff for private data and verify new
repository links and required paths exist in the proposed committed tree.
For documentation-only work, do not run installers or provision dependencies
just to validate prose. For other changes, select checks from the affected
source rather than assuming this library suite covers every package.

Report offline checks separately from fresh-client discovery, live installation
and physical/device acceptance. Static file presence and passing fixture tests
do not establish any of those runtime outcomes. Shared-library maintenance and
discovery details remain in [its guide](scripts/agents/README.md).
