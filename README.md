# dotfiles

This repository contains my personal configuration files (dotfiles) for various tools and applications, managed with [chezmoi](https://www.chezmoi.io/). It aims to provide a consistent and reproducible development environment across different machines.

## Features

* **Chezmoi Integration:** Seamless management and synchronization of dotfiles across systems.
* **Neovim:** My fully customized neovim setup, see [README](nvim/README.md).
* **Alacritty:** Customized fast terminal emulator.
* **Zellij:** Terminal multiplexer with vim-style keybindings.
* **Scripts:** This repository provides bash scripts for installing dependencies, such as chezmoi, neovim, and fonts.
* **Task:** For development and maintenance tasks, this repository uses [Task](https://taskfile.dev/#/).
* **Dockerized Neovim:** An isolated Docker environment for Neovim, perfect for offline use, testing, or consistent development environments without polluting the host system.
* **AI Tools:** Shell functions for Claude Code, Codex CLI, OpenCode, and Crush with Headroom token compression and local models via Lemonade.

## Installation & Setup

Follow these steps to set up your dotfiles on a new machine.

### 1. Clone the Repository

First, clone this dotfiles repository to your local machine:

```bash
git clone https://github.com/shrukan/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Install Chezmoi

If `chezmoi` is not already installed on your system, run the provided installation script:

```bash
./scripts/chezmoi.sh
```

This script will download and install the latest `chezmoi` binary to `~/.local/bin`.

To uninstall:

```bash
./scripts/chezmoi.sh --uninstall
```

### 3. Initialize and Apply Dotfiles with Chezmoi

Now, use `chezmoi` to link and apply your dotfiles. This command will initialize `chezmoi` with this repository as its source and then apply all the configurations.

```bash
chezmoi init --apply --source ~/.dotfiles
```

## Updating Dotfiles

To update your dotfiles after pulling new changes from the GitHub repository:

1. **Pull latest changes:**

    ```bash
    cd ~/.dotfiles
    git pull origin main 
    ```

2. **Apply changes with chezmoi:**

    ```bash
    task apply
    ```

   This copies the changes from the repository to your actual dotfiles
   (`~/.config/alacritty/`, etc.). Use `task apply` rather than plain
   `chezmoi apply`: the task passes the repository as chezmoi's source
   directory, which the Neovim link below is built from.

### Neovim config

`~/.config/nvim` is a symlink to `nvim/` in this repository, not a copy. Edits,
new or deleted plugin files and `:Lazy update` change the repository directly,
so the only steps left are `git commit` and `git push`. `task apply` creates
the link on a new machine; move an existing `~/.config/nvim` away first.

## Task

This repository also has a taskfile with all the used tasks. Task can easily be installed with

```bash
./scripts/task.sh
```

A lot of the different commands mentioned in this file, are also available via task.
All available tasks can be listed with

```bash
task --list
```

## Scripts

All installation scripts follow a consistent pattern:

* Run without arguments to install
* Run with `--uninstall` to remove

| Script | Description |
|---|---|
| `./scripts/chezmoi.sh` | Install/uninstall chezmoi |
| `./scripts/prek.sh` | Install/uninstall prek (pre-commit hooks) |
| `./scripts/alacritty.sh` | Install/uninstall alacritty |
| `./scripts/fonts.sh` | Install/uninstall configured fonts |
| `./scripts/nvim-deps.sh` | Install/uninstall Neovim runtime dependencies (fzf, ripgrep, lazygit, Go, Node.js, uv, templ, tree-sitter-cli) |
| `./scripts/nvim.sh [PREFIX] [VERSION]` | Install/uninstall neovim from source |
| `./scripts/zellij.sh` | Install/uninstall zellij |
| `./scripts/task.sh` | Install/uninstall task |

### Uninstalling

Each tool has a corresponding uninstall task:

```bash
task uninstall:chezmoi
task uninstall:prek
task uninstall:alacritty
task uninstall:task
task uninstall:zellij
```

For fonts and neovim, use the script directly:

```bash
./scripts/fonts.sh --uninstall
./scripts/nvim.sh --uninstall
```

## Fonts

Fonts are installed to `~/.local/share/fonts` and managed via the `install:fonts` task. To install all configured fonts:

```bash
task install:fonts
```

To uninstall:

```bash
./scripts/fonts.sh --uninstall
```

| Font | Nerd Font variant |
|---|---|
| JetBrainsMono | Yes |

## AI Tools

Shell functions for AI coding assistants are provided in `dot_bashrc.d/ai-tools.sh`. Source this file (or your shell profile will pick it up) to get:

| Function | Description |
|---|---|
| `ai_claude_local()` | Claude Code with local Qwen model via Lemonade + Headroom compression |
| `ai_claude_cloud()` | Claude Code with paid Anthropic API + Headroom compression |
| `ai_codex_local()` | Codex CLI with local Qwen model via Lemonade + Headroom compression |
| `ai_codex_cloud()` | Codex CLI with the paid OpenAI API / ChatGPT subscription + Headroom compression |
| `ai_opencode_headroom()` | OpenCode with Headroom compression + Lemonade local model |
| `ai_crush_local()` | Crush with local model + Headroom compression |
| `ai_lemonade_restart()` | Restart the Lemonade systemd service |
| `ai_headroom_restart_proxy()` | Restart the Headroom compression proxy |

## Dockerized Neovim (offline)

The image in `nvim-docker/` holds Neovim, the config, all plugins, Mason tools,
Tree-sitter parsers and the Go tools. It uses podman when installed, docker otherwise.
Inside, `NVIM_OFFLINE=1` stops every download. Go modules are not part of the
image: the container uses whatever Go setup the calling shell has (see below).

**Go version.** gopls, golangci-lint and delve are built with the image's Go,
and they can only analyse code whose `go` directive is not newer than that.
Build with a `GO_VERSION` at least as new as every project you open:

```bash
task docker:nvim:build GO_VERSION=1.27.4
```

### On the online machine

```bash
task docker:nvim:build
task docker:nvim:save                                   # -> nvim-env.tar.gz
task docker:nvim:test-offline WORKSPACE=~/src/workspace # check with --network none
```

`WORKSPACE` is the directory holding `go.work` (or the project's `go.mod`). It is
mounted at the same absolute path, so relative `go.work` paths resolve.
Run the tasks from inside the project (`task -d ~/.dotfiles ...`) so the
container starts there.

**On the airgapped machine** only `nvim-env.tar.gz` and `nvim-docker/run.sh`
are needed; neither task nor this repository:

```bash
gunzip -c nvim-env.tar.gz | podman load        # or: task docker:nvim:load
cd ~/src/workspace/myproject
./run.sh --workspace ~/src/workspace
```

**Go modules** come from the environment `run.sh` is called from. It forwards
`GOPROXY`, `GOSUMDB`, `GOFLAGS`, `GOWORK`, `GOPRIVATE`, `GONOSUMDB`,
`GONOPROXY`, `GOTOOLCHAIN` and `CGO_ENABLED` when they are set; unset ones keep
the image defaults (`GOPROXY=off`, `GOSUMDB=off`, `GOTOOLCHAIN=local`). So:

* with an internal module proxy, export `GOPROXY` (and `GONOSUMDB`/`GOPRIVATE`
  as your setup needs) before calling `run.sh`;
* with a vendored source bundle, source its environment file first, so
  `GOFLAGS=-mod=vendor` and `GOWORK` reach the container. `GOWORK` must point
  inside the mounted workspace. `GOROOT` and `PATH` are not forwarded; the
  image brings its own Go, which must be at least the bundle's Go version.

`run.sh --help` lists its options; the `docker:nvim:run`, `shell` and
`test-offline` tasks call it.

**As `nvim` everywhere.** Installed under the name `nvim`, the script passes
every argument to nvim in the container, so the shell, git and `$EDITOR` all
use it. Files outside the workspace are refused instead of opening an empty
buffer whose save would be lost with the container.

```bash
install -m 755 run.sh ~/.local/bin/nvim
echo 'export NVIM_ENV_WORKSPACE=~/src/workspace' >> ~/.bashrc   # dir holding go.work
echo 'export NVIM_ENV_OFFLINE=1' >> ~/.bashrc                   # optional: no network
source ~/.bashrc
```

### What the container can see

Everything that runs in the container can use what is listed here, including
code you did not write: plugins, npm-based language servers, Mason binaries.
`run.sh` therefore passes in only what editing, building and git need.

| From the host | In the container | Access | Why |
| --- | --- | --- | --- |
| The workspace (`--workspace`) | same absolute path | read-write | the files you edit; relative `go.work` paths resolve |
| Go module cache, if it exists (`GOMODCACHE_HOST`, else `go env GOMODCACHE`) | `/root/go/pkg/mod` | read-write | modules without downloading them |
| `nvim-env-cache` volume (not a host directory) | `/root/.cache` | read-write, kept across runs | Go build, gopls and golangci-lint caches |
| ssh agent (`SSH_AUTH_SOCK`) | `/ssh-agent` | can sign with the keys, cannot read them | git over ssh |
| `~/.ssh/config`, `known_hosts`, `*.pub` | `/root/.ssh/` | read-only | host aliases, ports, host keys, which key to use |
| `~/.gitconfig`, `~/.config/git` | `/root/` | read-only | name and email for commits |
| Host CA bundle (`SSL_CERT_FILE`, else the system one) | `/etc/ssl/certs/ca-certificates.crt`, also set as `SSL_CERT_FILE` and `NODE_EXTRA_CA_CERTS` | read-only | Go, git, curl, Node and Python tools trust an in-house proxy or git server |
| Go variables (`GOPROXY`, `GOFLAGS`, `GOWORK`, ... see above), `TERM`, `COLORTERM` | environment | — | module source, colours |

**Not visible:** the rest of your home directory, so private ssh keys, shell
history, browser data and other credentials; files outside the workspace
(`nvim` refuses them); every other environment variable, `GOROOT` and `PATH`
included. The image contains none of this either, so `nvim-env.tar.gz` can be
copied around without leaking anything.

**What follows from it:**

* Code in the container can read and change the workspace, like any editor
  plugin on the host can.
* While the container runs, it can *use* your ssh keys through the agent, but
  never copy them. `ssh-add -c` makes the agent ask before every use, so
  nothing can use a key unnoticed.
* `~/.gitconfig` must not hold credentials (tokens in `url.*.insteadOf`, the
  `store` credential helper), since it is readable inside.
* The CA bundle holds only public root certificates, no secrets. It decides
  which servers the container trusts, so it is exactly the trust of the host.
  Client certificates (mutual TLS) are not passed in; a proxy that requires
  one is not reachable from the container.

**Git over ssh.** The agent must hold the keys: load them once per session
with `ssh-add` (or set `AddKeysToAgent yes` in `~/.ssh/config`).
`Permission denied (publickey)` in the container means the agent is missing
or empty; check with `ssh-add -l`. New host keys cannot be saved from inside
(`known_hosts` is read-only); connect once from the host.

**Process and memory.** The container runs with `--init`, which reaps
orphaned processes; without it they pile up as zombies until Go can no longer
create threads. Thanks to the cache volume only the first start pays a cold
workspace load (several GB for gopls on a large workspace); removing the
volume is always safe.

With rootless podman, files the container writes stay yours; with rootful
docker they are owned by root.
