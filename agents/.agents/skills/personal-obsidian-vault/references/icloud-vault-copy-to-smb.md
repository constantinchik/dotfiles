# Explicit staging copies of an iCloud-backed vault
Use only when the user requests a separate SMB/FileCloud test copy. Discover the active source through `obsidian vault` help/info. Obtain the exact destination and do not move/delete the original vault.

On macOS prefer `ditto` over old system rsync for CloudDocs/iCloud data: rsync can fail with mmap/resource-deadlock errors. Require a fresh, nonexisting destination; do not delete an existing copy as an implicit preparation step. Use shell-quoted, user-approved source and destination variables, then `ditto "$src" "$dst"`. Apply restrictive permissions only to the new copy and only within approved scope.

Compare source/destination file counts and sizes; report partial-copy errors rather than claiming completion. Test on the actual client before calling it synchronized. A one-time copy is not a two-way sync system.
