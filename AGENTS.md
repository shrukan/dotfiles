
# AGENTS.md

Dotfiles managed with [chezmoi](https://www.chezmoi.io/). `dot_config/` is the
chezmoi source directory — files there map to `~/.config/` on the target system.
**Config changes belong in `dot_config/`, never in the live target.**

## Commands

`task --list` for the full set. The core loop is `task add TARGET` to import a
file into chezmoi, `task diff` to preview, `task apply` to apply. Tasks prefixed
`_` are internal and hidden from the list.

## Conventions

- **Scripts** (`scripts/*.sh`): no arguments installs (idempotent), `--uninstall`
  removes. They use `set -e`, detect dnf vs apt, and install to `~/.local/bin`
  (nvim uses `$INSTALL_PREFIX`). A new tool means a new script plus entries in
  `Taskfile.yml`, `install:all`, and the README.
- **Neovim** is LazyVim-based; each plugin gets its own file under
  `dot_config/nvim/lua/plugins/`. Mason handles LSPs, formatters, and linters.
  Keep the Prerequisites section of `dot_config/nvim/README.md` current.
- **Fonts** live in `scripts/fonts.sh` — updating one means updating the README
  font table too.
- **Git**: Conventional Commits, enforced by commitlint. Scopes: `repo`,
  `scripts`, `task`, `docker`, `readme`, `chezmoi`, `nvim`, `alacritty`.
  Pre-commit hooks run via prek.

## Gotchas

- `nvim-docker/Dockerfile` builds from the repo root, so it copies everything —
  including the nvim config.
