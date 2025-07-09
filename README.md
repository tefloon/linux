# Arch + Hyprland: Dotfiles & Setup Scripts

This repository contains my personal dotfiles and post-installation scripts for quickly configuring a fresh Arch Linux (or EndeavourOS) system with the Hyprland compositor.

The session is managed by `uwsm` for a clean, minimal startup process.

## Features

- Automated installation of essential packages (official & AUR)
- Symlinks for all configs (`hypr`, `waybar`, `.zshrc`, etc.)
- Bitwarden CLI integration for secrets (SSH keys, API tokens)
- Custom scripts and aliases for productivity
- Hyprland keybindings and theming
- Wayland-native tooling: `wofi`, `swaylock`, `grim`, `slurp`
- Easily extensible for VMs or bare metal

---

## Quick Start

### 1. **Prepare Your System**

- Install a minimal Arch Linux or EndeavourOS (the "No Desktop" option).
- Run the `bootstrap.sh` script from this repo as root:
  ```sh
  curl -sL https://raw.githubusercontent.com/tefloon/linux/main/bootstrap.sh | bash
  ```
  This will clone the repo to your user's home directory and run the main setup script.

2. Post-Install

- Reboot your system.
- At the login screen (SDDM), select the "uwsm" session from the menu.
- Log in and enjoy your new Hyprland desktop!

---

What Gets Installed?

- System packages: See scripts/install_packages.sh
- AUR packages: Managed via yay
- Dotfiles: Symlinked from dotfiles/ to your $HOME/.config and other locations.
- Secrets: Pulled from Bitwarden and written to ~/.ssh/ and ~/.zsh_secrets

---

Customization

- Edit package lists:
Modify scripts/install_packages.sh to add/remove packages.
- Dotfiles:
Whatever you put into the dotfiles/ directory will get symlinked to the corresponding location in $HOME.

---

License


Personal use. Fork and adapt as you like!