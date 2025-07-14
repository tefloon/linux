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

### 2. Post-Install

- Reboot your system.
- At the login screen (SDDM), select the "uwsm" session from the menu.
- Log in and enjoy your new Hyprland desktop!

3. Cursors
- Install a hyprcursor theme (from Discord) and set it in hyprland.conf with `env = HYPRCURSOR_THEME,ThemeName`
- For X11 fallback (Electron apps): install an X11 cursor theme and create symlink: `sudo ln -sf /usr/share/icons/CursorTheme /usr/share/icons/default`
- Update GTK settings: `gsettings set org.gnome.desktop.interface cursor-theme 'CursorTheme'`

---

## What Gets Installed?

- System packages: See scripts/install_packages.sh
- AUR packages: Managed via yay
- Dotfiles: Symlinked from `dotfiles/` to your `$HOME/.config` and other locations.
- Personal scripts: symlinked from `bin/` to your `$HOME/.local/bin`
  - `cb`: prints to the standard output AND copies to clipboard. Use in a pipe: `cat somefile.txt | cb`
  - `mdd`: recursively traverses the folder, finds text files, formats them in a markdown format, prints them and copies to clipboard. Designed to be used with chatbots and note-taking apps like obsidian
  - `dim`: a screen-dimming utility for watching movies on multiple-screen setups. Based on great Marcelo Hernandez `dim` (https://github.com/marcelohdez/dim). Write `dim --help` for explanation how to use.
- Secrets: Pulled from Bitwarden and written to ~/.ssh/ and ~/.zsh_secrets

---

## Customization

- Edit package lists:
Modify scripts/install_packages.sh to add/remove packages.
- Dotfiles:
Whatever you put into the dotfiles/ directory will get symlinked to the corresponding location in $HOME.

---

## Troubleshooting
- If Electron apps (Franz, VSCode) don't respect cursor themes, ensure `/usr/share/icons/default` symlink exists

License


Personal use. Fork and adapt as you like!