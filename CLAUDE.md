# CLAUDE.md

This is the dotfiles repository for the user, managed with [chezmoi](https://www.chezmoi.io/).

## Repository Structure

```text
.
├── dot_config/            # chezmoi source directory
│   ├── alacritty/        # Alacritty terminal config
│   ├── nvim/             # Neovim config
│   └── zellij/           # Zellij terminal multiplexer config
├── scripts/              # Install/uninstall scripts
│   ├── chezmoi.sh        # Install chezmoi (--uninstall flag)
│   ├── prek.sh           # Install prek pre-commit hooks (--uninstall flag)
│   ├── alacritty.sh      # Install alacritty (--uninstall flag)
│   ├── fonts.sh          # Install fonts (--uninstall flag)
│   ├── nvim.sh           # Install nvim from source (--uninstall flag)
│   ├── nvim-deps.sh      # Install Neovim runtime deps (Go, Node.js, uv, lazygit, templ, tree-sitter-cli) (--uninstall flag)
│   ├── zellij.sh         # Install zellij (--uninstall flag)
│   └── task.sh           # Install task runner (--uninstall flag)
├── nvim-docker/          # Dockerized neovim environment
│   ├── Dockerfile
│   └── setup-nvim-in-container.sh
├── Taskfile.yml          # Task runner definitions
├── prek.toml             # Prek pre-commit hook config
├── .commitlintrc.yml     # Commit message linting rules
└── .gitignore
```

## Key Patterns & Conventions

### Chezmoi

- `dot_config/` is the chezmoi source directory. Files here map to `~/.config/` on the target system.
- Use `task add TARGET` to import new files into chezmoi source.
- Use `task apply` to apply changes. Use `task diff` to preview.
- The `_chezmoi` internal task wraps all chezmoi commands with `--source="{{.ROOT_DIR}}"`.

### Scripts

- All scripts in `scripts/` follow the same pattern:
  - No arguments → install (idempotent, skips if already installed)
  - `--uninstall` → remove installed binary/files
- Scripts use `set -e` and detect the package manager (dnf/apt) automatically.
- Scripts install to `~/.local/bin` unless otherwise noted (nvim uses `$INSTALL_PREFIX`).
- When adding a new tool, create a new script and add corresponding tasks in Taskfile.yml.

### Neovim

- The nvim config is built on [LazyVim](https://lazyvim.github.io/).
- Plugins are managed via lazy.nvim. Each plugin gets its own file under `dot_config/nvim/lua/plugins/`.
- Mason handles language servers, formatters, and linters.
- The `dot_config/nvim/README.md` "Prerequisites" section should be kept updated with system-level dependencies.

### Zellij

- The zellij config lives in `dot_config/zellij/config.kdl`.
- It uses the `onedark` theme, has clear-defaults bindings with vim-style pane/tab navigation, and loads the `zellij:link` plugin.
- The install script is `scripts/zellij.sh` (uses `--uninstall` flag, downloads from GitHub releases).

### Task

- `Taskfile.yml` defines all automation. Use `task --list` to see available tasks.
- Internal tasks start with `_` prefix and are not listed in `task --list`.
- The `install:all` task should include all install tasks for a complete setup.

### Git

- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) via commitlint.
- Scopes: `repo`, `scripts`, `task`, `docker`, `readme`, `chezmoi`, `nvim`, `alacritty`.
- Pre-commit hooks are managed by prek (configured in `prek.toml`).

## Important Notes for Agents

1. **Never modify files outside of `dot_config/` for chezmoi-managed configs.** Config changes go in `dot_config/`.
2. **When making changes to nvim plugins**, add/update the corresponding file under `dot_config/nvim/lua/plugins/`.
3. **When adding new scripts**, update both the README.md and Taskfile.yml.
4. **Fonts** are managed via `scripts/fonts.sh` — updating requires updating both the script and README.md font table.
5. **The nvim Dockerfile** builds from `.` (the repo root), so it copies everything including the nvim config.
