# Archcraft Post-Install: Dotfiles & Setup Scripts

This repository contains my personal dotfiles and post-installation scripts for quickly configuring a fresh [Archcraft](https://archcraft.io/) (Openbox) system to my preferred environment.

## Features

- Automated installation of essential packages (official & AUR)
- Symlinks for dotfiles (`.zshrc`, Openbox config, SSH config, etc.)
- Bitwarden CLI integration for secrets (SSH keys, API tokens)
- Custom scripts and aliases for productivity
- Openbox keybindings and theming
- FZF, Zoxide, and other modern CLI tools
- Easily extensible for VMs or bare metal

---

## Quick Start

### 1. **Prepare Your System**

- Install [Archcraft](https://archcraft.io/) (Openbox edition recommended)

### 2. **Clone This Repo**

```sh
cd ~
git clone https://github.com/tefloon/linux.git
cd linux
```

### 3. **Run the Setup Script**

- For **bare metal**:
  ```sh
  ./setup.sh
  ```
- For **VM installs** (skips disk mounting):
  ```sh
  ./setup.sh --vm
  ```

> **Note:**  
> - You’ll be prompted for your `sudo` password.
> - Bitwarden CLI will prompt you to log in and unlock your vault for secrets retrieval.

---

## What Gets Installed?

- **System packages:** See [`scripts/install_packages.sh`](scripts/install_packages.sh)
- **AUR packages:** Managed via `yay`
- **Dotfiles:** Symlinked from `dotfiles/` to your `$HOME`
- **Secrets:** Pulled from Bitwarden and written to `~/.ssh/` and `~/.zsh_secrets`
- **Openbox:** Custom keybindings, theme, and mouse actions

---

## What to do after install?

- Setup the theme and color scheme for Sublime
- Import Bookmarks

---

## Customization

- **Edit package lists:**  
  Modify `scripts/install_packages.sh` to add/remove packages.
- **Dotfiles:**  
  Whatever you put into the `dotfiles/` will get symlinked in the same place in `$HOME`.
  
---

## Troubleshooting

- **File exists errors:**  
  Remove conflicting files as instructed, then re-run the setup.
- **Permissions:**  
  All scripts are made executable; dotfiles are set to correct permissions.

---

## TODO

- Remove unneeded Archcraft defaults (e.g., plank)
- Refine virtual desktop and autostart setup

---

## Credits

- Openbox config adapted from [adi1090x](https://github.com/adi1090x)
- Inspired by various dotfiles and Arch install scripts

---

## License

Personal use. Fork and adapt as you like!