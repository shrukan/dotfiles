# dotfiles

This repository contains my personal configuration files (dotfiles) for various tools and applications, managed with [chezmoi](https://www.chezmoi.io/). It aims to provide a consistent and reproducible development environment across different machines.

## Features

* **Chezmoi Integration:** Seamless management and synchronization of dotfiles across systems.
* **Neovim:** My fully customized neovim setup, see [README](dot_config/nvim/README.md).
* **Scripts:** This repository provides bash scripts for installing dependencies, such as chezmoi and neovim.
* **Task:** For development and maintenance tasks, this repository uses [Task](https://taskfile.dev/#/).

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
./scripts/install-chezmoi.sh
```

This script will download and install the latest `chezmoi` binary to `~/.local/bin`.

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
