# Repository guidance

GNU Stow dotfiles for macOS and Linux. Start with [README.md](README.md)
for package layout, safe Stow reconciliation and theme conventions; follow
[CONTRIBUTING.md](CONTRIBUTING.md) for checks, change scope and approval boundaries.

- Package paths mirror the home directory; `scripts/` contains helpers, not
  Stow packages. Check OS-specific and server overlays when changing shared files.
- `nvim/.config/nvim` is a separate repository pinned by a gitlink; preserve it
  unless a submodule update is explicitly in scope.
- Shared agent tooling is optional. Its committed guide is
  [scripts/agents/README.md](scripts/agents/README.md); no personal skill install,
  private notes or external memory is required to understand this repository.
