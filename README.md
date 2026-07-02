# dotfiles

This repository contains my personal configuration files (dotfiles) for various tools and applications, managed with [chezmoi](https://www.chezmoi.io/). It aims to provide a consistent and reproducible development environment across different machines.

## Features

* **Chezmoi Integration:** Seamless management and synchronization of dotfiles across systems.
* **Neovim:** My fully customized neovim setup, see [README](dot_config/nvim/README.md).
* **Alacritty:** Customized fast terminal emulator.
* **Scripts:** This repository provides bash scripts for installing dependencies, such as chezmoi, neovim, and fonts.
* **Task:** For development and maintenance tasks, this repository uses [Task](https://taskfile.dev/#/).
* **Dockerized Neovim:** An isolated Docker environment for Neovim, perfect for offline use, testing, or consistent development environments without polluting the host system.

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
    chezmoi apply
    ```

   This will sync any changes from your cloned `~/.dotfiles` directory to your actual dotfiles (`~/.config/nvim/`, etc.).

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
| `./scripts/task.sh` | Install/uninstall task |

### Uninstalling

Each tool has a corresponding uninstall task:

```bash
task uninstall:chezmoi
task uninstall:prek
task uninstall:alacritty
task uninstall:task
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
