<!-- headroom:rtk-instructions -->
# RTK (Rust Token Killer) - Token-Optimized Commands

When running shell commands, **always prefix with `rtk`**. This reduces context
usage by 60-90% with zero behavior change. If rtk has no filter for a command,
it passes through unchanged — so it is always safe to use.

## Key Commands
```bash
# Git (59-80% savings)
rtk git status          rtk git diff            rtk git log

# Files & Search (60-75% savings)
rtk ls <path>           rtk read <file>         rtk grep <pattern>
rtk find <pattern>      rtk diff <file>

# Test (90-99% savings) — shows failures only
rtk pytest tests/       rtk cargo test          rtk test <cmd>

# Build & Lint (80-90% savings) — shows errors only
rtk tsc                 rtk lint                rtk cargo build
rtk prettier --check    rtk mypy                rtk ruff check

# Analysis (70-90% savings)
rtk err <cmd>           rtk log <file>          rtk json <file>
rtk summary <cmd>       rtk deps                rtk env

# GitHub (26-87% savings)
rtk gh pr view <n>      rtk gh run list         rtk gh issue list

# Infrastructure (85% savings)
rtk docker ps           rtk kubectl get         rtk docker logs <c>

# Package managers (70-90% savings)
rtk pip list            rtk pnpm install        rtk npm run <script>
```

## Rules
- In command chains, prefix each segment: `rtk git add . && rtk git commit -m "msg"`
- For debugging, use raw command without rtk prefix
- `rtk proxy <cmd>` runs command without filtering but tracks usage
<!-- /headroom:rtk-instructions -->

# CLAUDE.md

This is the dotfiles repository for the user, managed with [chezmoi](https://www.chezmoi.io/).

## Repository Structure

```
.
├── dot_config/            # chezmoi source directory
│   ├── alacritty/        # Alacritty terminal config
│   ├── nvim/             # Neovim config (LazyVim-based)
│   └── opencode/          # OpenCode AI editor config
├── dot_bashrc.d/          # chezmoi source directory (maps to ~/.bashrc.d/)
│   └── ai-tools.sh        # Claude Code / OpenCode / Crush helpers
├── scripts/               # Install/uninstall scripts
│   ├── chezmoi.sh        # Install chezmoi (--uninstall flag)
│   ├── prek.sh           # Install prek pre-commit hooks (--uninstall flag)
│   ├── alacritty.sh      # Install alacritty (--uninstall flag)
│   ├── fonts.sh          # Install fonts (--uninstall flag)
│   ├── nvim.sh           # Install nvim from source (--uninstall flag)
│   ├── nvim-deps.sh      # Install Neovim runtime deps (Go, Node.js, uv, lazygit, templ, tree-sitter-cli) (--uninstall flag)
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

### Task
- `Taskfile.yml` defines all automation. Use `task --list` to see available tasks.
- Internal tasks start with `_` prefix and are not listed in `task --list`.
- The `install:all` task should include all install tasks for a complete setup.

### Git
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) via commitlint.
- Scopes: `repo`, `scripts`, `task`, `docker`, `readme`, `chezmoi`, `nvim`, `alacritty`, `ai`.
- Pre-commit hooks are managed by prek (configured in `prek.toml`).

### AI Tools
- `dot_bashrc.d/ai-tools.sh` — shell functions for Claude Code, OpenCode, and Crush with Headroom compression.
  - `ai_claude_local()` / `ai_claude_cloud()` — Claude Code with local or Anthropic API
  - `ai_opencode_headroom()` — OpenCode with Headroom compression + Lemonade local model
  - `ai_crush_local()` — Crush with local model
  - `ai_headroom_restart_proxy()` / `ai_headroom_ensure_proxy()` — manage headroom proxy
  - `ai_lemonade_restart()` — restart lemonade systemd service
- `dot_config/opencode/` — OpenCode configuration (providers, MCP servers, LSP).
  - Lemonade provider: local Qwen models via `http://127.0.0.1:13305/v1`
  - Headroom provider: compression proxy via `http://127.0.0.1:8787/v1`
  - MCP servers: headroom (token compression), serena (codebase indexing)
  - LSP: enabled (`"lsp": true`) for built-in language servers
- Headroom proxy port: `8787` (defined in `ai-tools.sh` and opencode config).

## Important Notes for Agents

1. **Never modify files outside of `dot_config/` for chezmoi-managed configs.** Config changes go in `dot_config/`.
2. **When making changes to nvim plugins**, add/update the corresponding file under `dot_config/nvim/lua/plugins/`.
3. **When adding new scripts**, update both the README.md and Taskfile.yml.
4. **Fonts** are managed via `scripts/fonts.sh` — updating requires updating both the script and README.md font table.
5. **The nvim Dockerfile** builds from `.` (the repo root), so it copies everything including the nvim config.
6. **AI tool shell functions** live in `dot_bashrc.d/ai-tools.sh` — managed by chezmoi (maps to `~/.bashrc.d/ai-tools.sh`).
