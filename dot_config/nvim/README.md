# Neovim Config

This is my Neovim configuration built from scratch.

## Prerequisites

### System-level dependencies

These must be installed on your system before the config will work fully:

| Tool | Purpose |
|---|---|
| [neovim](https://neovim.io/) (0.10+) | Editor |
| [git](https://git-scm.com/) | Plugin management, gitsigns.nvim |
| [go](https://go.dev/) | gopls, golangci-lint, delve, neotest |
| [python3](https://www.python.org/) + pip + venv | zuban, ruff, mbake |
| [node](https://nodejs.org/) + npm | typescript-language-server, eslint_d, angular-language-server |
| [templ](https://github.com/a-h/templ) | templ LSP server |
| [lazygit](https://github.com/jesseduffield/lazygit) | lazygit.nvim plugin |
| `make` + `gcc`/`clang` | telescope-fzf-native.nvim build step |

All LSP servers, formatters, linters, and debuggers are installed automatically by Mason on first launch.

### Neovim setup

On first launch, Neovim will automatically:

1. Install plugins via [Lazy.nvim](https://github.com/folke/lazy.nvim)
2. Install Mason tools (LSP servers, formatters, linters, debuggers)
3. Install Tree-sitter parsers

You can also run these manually:

```vim
:Lazy sync
:MasonToolsUpdateSync
:TSUpdate
```

## Plugins

| Category | Plugins |
|---|---|
| **Plugin manager** | lazy.nvim |
| **LSP / tools** | mason.nvim, mason-tool-installer.nvim, nvim-lspconfig |
| **Completion** | blink.cmp |
| **Formatting** | conform.nvim |
| **Linting** | nvim-lint |
| **Syntax** | nvim-treesitter, nvim-ts-autotag |
| **UI** | noice.nvim, lualine.nvim, which-key.nvim, vim-illuminate, neoscroll, blink-indent.lua, lspsaga.nvim, lsp-lines.nvim |
| **File management** | telescope.nvim, telescope-fzf-native.nvim, neo-tree.nvim |
| **Git** | gitsigns.nvim, lazygit.nvim |
| **Debugging / testing** | nvim-dap, nvim-dap-go, neotest, neotest-golang |
| **Extras** | nvim-autopairs, nvim-surround, comment.nvim, neogen, markview.nvim, venv-selector.nvim, hardtime.nvim, toggleterm.nvim, lazydev.nvim |
| **AI** | windsurf.nvim (Codeium) |

## Known problems

1. Golangci-lint was updated to version 2 (breaking change) and nvim-lint needs some fixing. Using the linter in the terminal of neovim works.
2. Golines, gci and gofumpt are all used for formatting go code, hence formatting a go file can take some time.

## Supported languages

1. Go
2. Lua
3. Typescript
4. Angular
5. Docker
