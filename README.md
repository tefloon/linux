# Arch + Hyprland: Dotfiles & Setup Scripts

This repository contains my personal dotfiles and automated setup scripts for quickly configuring a fresh Arch Linux (or EndeavourOS) system with the Hyprland compositor.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Features](#features)
- [Quick Start](#quick-start)
- [What Gets Installed](#what-gets-installed)
- [Repository Structure](#repository-structure)
- [Setup Scripts](#setup-scripts)
- [Custom Scripts](#custom-scripts)
- [Secrets Management](#secrets-management)
- [Asset Management](#asset-management)
- [Configuration](#configuration)
- [Key Bindings](#key-bindings)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Maintenance](#maintenance)
- [License](#license)

## Prerequisites

- **Fresh Arch Linux or EndeavourOS installation** ("No Desktop" option recommended)
- **Internet connection** for package downloads
- **User account with sudo privileges** (must be in `wheel` group)
- **Git** (will be installed automatically if missing)

## Features

- **Automated installation** of essential packages (official & AUR via yay)
- **Modular Hyprland configuration** with organized config files
- **Symlinked dotfiles** for all configs (`hypr`, `waybar`, `kitty`, `.zshrc`, etc.)
- **Bitwarden CLI integration** for secrets management (SSH keys, API tokens)
- **Custom productivity scripts** and shell aliases
- **Modern Wayland tooling**: `wofi`, `swaylock`, `grim`, `slurp`, `mako`
- **Multi-monitor support** with workspace assignments
- **Asset management** with automatic extraction and symlinking
- **Personal host configuration** and SSH key management
- **Status indicators** for all setup steps with clear success/failure feedback

---

## Quick Start

### 1. Bootstrap Installation

After installing a minimal Arch Linux or EndeavourOS (use the "No Desktop" option), run the bootstrap script as root:

```bash
curl -sL https://raw.githubusercontent.com/tefloon/linux/main/bootstrap.sh | sudo bash
```

**What the bootstrap script does:**
- Installs git if not present
- Clones this repository to your user's home directory (`~/linux`)
- Runs the main setup script (`setup.sh`) as your user
- Configures `/etc/fstab` with personal drive mounts (customize in bootstrap.sh before running)
- Links personal hosts file to `/etc/hosts`
- Switches git remote to SSH for easier future updates

**If you prefer manual installation:**
```bash
# As regular user
cd ~
git clone https://github.com/tefloon/linux.git
cd linux
./setup.sh
```

### 2. Post-Install Setup

1. **Reboot your system** to ensure all services start properly
2. **Log in** and you should see your Hyprland desktop with:
   - Multiple Waybar instances (one per monitor)
   - Auto-started applications (Ferdium, Obsidian, terminal)
   - Custom wallpaper and cursor theme (Bibata Modern Classic)
3. **Run `sudo tailscale up` to join the tailnet**
4. **Run `retrieve-secrets.sh` to get all the SSH keys, .env, GPG etc. from Bitwarden**
5. **Setup the SDDM theme by running `bash -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)`"

### 3. Secrets Retrieval

The `retrive-secrets.sh` script will pull secrets from Bitwarden. Those include SSH keys, PGP/GPG private keys and environment variables.

#### SSH Keys
Bitwarden supports SSH keys as an asset type so the script will pull them (both private and public) and put them in `~/.ssh/`.

#### PGP/GPG keys
There is no way to store PGP/GPG keys in Bitwarden natively, so the script will look for notes with "pgp" or "gpg" in the name,
extract them and import them to the keyring.

#### Environment variables
The script will look for notes with "secret" in the name, extract the contents parse it as environment variables and add them to the file `~/.zsh_secrets` 


---

## What Gets Installed?

### Core Hyprland Stack
- **Compositor & Session**: `hyprland`, `uwsm`
- **Wallpaper & Bar**: `hyprpaper`, `waybar`
- **Launcher & Terminal**: `wofi`, `kitty`
- **Notifications & Lock**: `mako`, `swaylock`
- **Clipboard & Screenshots**: `wl-clipboard`, `cliphist`, `grim`, `slurp`
- **Portals**: `polkit-kde-agent`, `xdg-desktop-portal-hyprland`
- **Qt/Wayland**: `qt5-wayland`, `qt6-wayland`, `qt5ct`, `qt6ct`

### Development & Productivity
- **Text Editors**: Sublime Text 4, VS Code, Cursor
- **File Management**: `yazi` (terminal file manager), `fd`, `bat`, `tree`
- **Shells**: `zsh` with `zsh-syntax-highlighting`, `zsh-autosuggestions`, `zoxide`
- **Tools**: `jq`, `bitwarden-cli`, `keychain`, `tealdeer` (tldr client)
- **Version Control**: Git with comprehensive SSH configuration

### Applications
- **Browsers**: Thorium Browser (default), Brave
- **Communication**: Ferdium (multi-platform messaging), KDE Connect
- **Media**: Kodi, Spotify, `spotifyd`, `spotify-player`
- **Office**: OnlyOffice, Obsidian (note-taking), Calibre (ebook management)
- **Utilities**: 
  - `copyq` (clipboard manager with history)
  - `cliphist` (Wayland clipboard history)
  - `corectrl` (AMD GPU control)
  - `qbittorrent`
  - `gnome-calendar`

### System Enhancements
- **Audio**: PipeWire with WirePlumber, EasyEffects
- **Themes**: Bibata cursor theme, adw-gtk3-dark GTK theme
- **Fonts**: Development and UI font packages
- **System**: `ntfs-3g` for NTFS support

---

## Repository Structure

```
linux/
├── README.md                   # This file
├── setup.sh                    # Main setup orchestrator
├── bootstrap.sh                # Root installation script
│
├── bin/                        # Custom utility scripts
│   ├── cb                      # Clipboard copy tool (stdout + clipboard)
│   ├── deck                    # Netrunner deck list parser (JSON output)
│   ├── mdd                     # Markdown directory formatter
│   ├── ocr                     # OCR screen selection (tesseract)
│   ├── picker                  # Color picker (hyprpicker)
│   ├── screen-dimmer           # Screen brightness dimmer utility
│   ├── screenshot              # Screenshot to clipboard
│   ├── screenshot-with-window  # Screenshot with satty annotation
│   └── tokens                  # Token counter (tiktoken)
│
├── scripts/                    # Modular setup scripts
│   ├── status.sh              # Status message helpers (used by all scripts)
│   ├── install-packages.sh    # Package installation
│   ├── setup-shell.sh         # Shell configuration (zsh)
│   ├── setup-scripts.sh       # Links bin/ scripts to ~/.local/bin
│   ├── setup-dotfiles.sh      # Symlinks all dotfiles
│   ├── setup-launch-scripts.sh # Sets up application launchers
│   ├── setup-assets.sh        # Extracts themes, wallpapers
│   ├── setup-system.sh        # System-level configurations
│   ├── post-install.sh        # Post-installation tasks
│   ├── post-install-scripts/  # Post-install subscripts
│   │   ├── setup-services.sh  # Enable services, add user to groups
│   │   ├── setup-default-browser.sh # Browser MIME configuration
│   │   └── set-default-programs.sh  # Default app associations
│   └── retrieve-secrets.sh    # Bitwarden integration
│
├── dotfiles/                   # Configuration files (symlinked to ~/)
│   ├── .gitconfig             # Git configuration
│   ├── .ssh/config            # SSH configuration
│   ├── .zshrc                 # Zsh configuration
│   ├── hosts                  # Custom hosts file
│   └── .config/               # Application configs
│       ├── hypr/              # Hyprland configuration
│       ├── waybar/            # Waybar configuration
│       ├── kitty/             # Kitty terminal config
│       └── ...                # Other app configs
│
├── assets/                     # Themes, wallpapers, archives
│   ├── icons/                 # Cursor themes
│   └── wallpapers/            # Desktop backgrounds
│
└── launch-scripts/             # Application launchers
    └── launch-nwg.sh          # NWG panel launcher
```

### Hyprland Config Organization

The Hyprland configuration is modular and organized:

```
~/.config/hypr/
├── hyprland.conf               # Main config (sources all others)
└── hyprland/
    ├── env.conf                # Environment variables
    ├── execs.conf              # Autostart applications
    ├── general.conf            # Window manager settings
    ├── keybinds.conf           # Key bindings
    ├── rules.conf              # Window rules & workspace assignments
    └── colors.conf             # Color scheme
```

---

## Setup Scripts

The `setup.sh` script orchestrates the entire installation by calling modular scripts in sequence:

```
setup.sh
├── scripts/install-packages.sh     # Install all packages (pacman + AUR)
├── scripts/setup-shell.sh          # Configure zsh with plugins
├── scripts/setup-scripts.sh        # Link custom bin/ scripts
├── scripts/setup-dotfiles.sh       # Symlink all dotfiles
├── scripts/setup-launch-scripts.sh # Setup application launchers
├── scripts/setup-assets.sh         # Extract and setup themes/wallpapers
├── scripts/setup-system.sh         # System configs (theme, shell, hosts)
├── scripts/post-install.sh         # Post-installation tasks
│   ├── setup-services.sh           # Enable services, add to groups
│   ├── setup-default-browser.sh    # Browser MIME configuration
│   └── set-default-programs.sh     # Default app associations
└── scripts/retrieve-secrets.sh     # Fetch secrets from Bitwarden
```

Each script includes status indicators for every step, making it easy to see what succeeded, failed, or was skipped.

---

## Custom Scripts

Located in `bin/` and automatically symlinked to `~/.local/bin`:

### `cb` - Clipboard Copy Tool
Prints to stdout AND copies to Wayland clipboard simultaneously. Perfect for piping command output:

```bash
echo "Hello World" | cb
cat file.txt | cb
```

### `mdd` - Markdown Directory Formatter
Recursively converts directory contents to markdown format with syntax highlighting. Great for sharing code context with AI tools:

```bash
mdd /path/to/project
mdd .  # Current directory
```

### `ocr` - OCR Screen Selection
Select a region of the screen and extract text using Tesseract OCR (supports Polish and English). Text is copied to clipboard:

```bash
ocr  # Select region, text is copied to clipboard
```

### `picker` - Color Picker
Pick a color from anywhere on screen using hyprpicker. Color is copied to clipboard in hex format:

```bash
picker  # Click anywhere to pick color
```

### `screenshot` - Screenshot to Clipboard
Take a screenshot of a selected region and copy directly to clipboard:

```bash
screenshot  # Select region, image copied to clipboard
```

### `screenshot-with-window` - Screenshot with Annotation
Take a screenshot with satty annotation tool for markup before copying:

```bash
screenshot-with-window  # Select region, annotate, then copy
```

### `tokens` - Token Counter
Count tokens in text or files using tiktoken (OpenAI's tokenizer):

```bash
tokens file.txt        # Count tokens in file
echo "text" | tokens   # Count tokens from stdin
```

### `deck` - Netrunner Deck Parser
Parse Netrunner deck lists and output as JSON:

```bash
deck decklist.txt  # Output JSON array of cards
```

### `screen-dimmer` - Screen Brightness Dimmer
Compiled utility for controlling screen brightness/dimming:

```bash
screen-dimmer  # Run the screen dimmer utility
```

---

### SSH Configuration

The repository includes a comprehensive SSH config (`.ssh/config`) with:
- GitHub SSH key configuration
- Personal server connections (Pi, server, Hostinger)
- ControlMaster for connection multiplexing
- Automatic ForwardAgent for GitHub

---

## Asset Management

The `setup_assets.sh` script automatically handles assets in the `assets/` directory:

- **Archives** (`.zip`, `.tar.gz`, `.tar.xz`, etc.): Automatically extracted to `~/.local/share/`
- **Images** (`.png`, `.jpg`, `.svg`, etc.): Symlinked to `~/.local/share/`
- **Cursor Themes**: Extracted and installed system-wide
- **Wallpapers**: Made available for hyprpaper

All assets maintain proper permissions and ownership.

---

## Configuration

### Multi-Monitor Setup

Configured for 3 monitors with workspace assignments:

- **HDMI-A-2** (Left): Workspaces 1, 4
- **DP-1** (Center): Workspaces 2, 5
- **HDMI-A-1** (Right): Workspaces 3, 6
- **Special workspace `magic`**: Scratchpad for Obsidian

### Auto-Started Applications

```
Workspace 2: Ferdium (messaging)
Special magic: Obsidian (notes)
```

Additional auto-starts:
- KDE Connect (phone integration)
- EasyEffects (audio processing)
- Clipboard history (cliphist)
- Polkit authentication agent

### System Configuration

- **Shell**: Zsh with syntax highlighting, autosuggestions, and zoxide
- **Theme**: adw-gtk3-dark (dark mode enabled)
- **Cursor**: Bibata Modern Classic (24px)
- **Clipboard**: cliphist for text and image history
- **Audio**: PipeWire + WirePlumber + EasyEffects

---

## Key Bindings

| Binding | Action |
|---------|---------|
| `Super + T` | Open terminal (kitty) |
| `Super + D` | Application launcher (wofi) |
| `Super + F` | Notes (Obsidian) |
| `Super + R` | Text editor (Sublime) |
| `Super + B` | Browser (Thorium) |
| `Super + S` | Toggle scratchpad |
| `Super + 1-6` | Switch to workspace 1-6 |
| `Super + Shift + 1-6` | Move window to workspace 1-6 |
| `Super + Q` | Close window |
| `Super + V` | Toggle floating |
| `Super + I` | Window info (class/title) |
| `Print` | Screenshot selection |
| `Super + Print` | Screenshot full screen |

*Note: Full keybindings are defined in `~/.config/hypr/hyprland/keybinds.conf`*

---

## Customization

### Adding Packages

Edit `scripts/install_packages.sh` and add your packages:

```bash
# Official repository packages
install_pkg "package-name"

# AUR packages
install_aur_pkg "aur-package-name"
```

Then re-run: `source scripts/install_packages.sh`

### Adding Dotfiles

1. Place your config file in the `dotfiles/` directory, maintaining the same path structure as it would be in `~/`
2. Run `bash scripts/setup_dotfiles.sh` to create symlinks
3. Files automatically maintain the correct relative paths

Example:
```
dotfiles/.config/foo/config.yml → ~/.config/foo/config.yml
dotfiles/.zshrc → ~/.zshrc
```

### Personalizing the Setup

- **Monitor layout**: Edit `~/.config/hypr/hyprland/rules.conf`
- **Keybindings**: Modify `~/.config/hypr/hyprland/keybinds.conf`
- **Autostart apps**: Update `~/.config/hypr/hyprland/execs.conf`
- **Colors/theme**: Adjust `~/.config/hypr/hyprland/colors.conf` and Waybar configs
- **Custom hosts**: Edit `dotfiles/hosts` (automatically linked to `/etc/hosts`)
- **Drive mounts**: Edit `bootstrap.sh` to customize `/etc/fstab` entries

---

## Troubleshooting

### Common Issues

**Installation Failed/Stopped:**
```bash
# Check system logs
journalctl -xe

# Check package installation logs
cat /tmp/pacman.log
cat /tmp/yay.log

# Restart from where it stopped
cd ~/linux
./setup.sh
```

**Missing Packages:**
```bash
# Re-run package installation
cd ~/linux
source scripts/install_packages.sh
```

**Dotfiles Not Applied:**
```bash
# Re-run dotfile setup
cd ~/linux
bash scripts/setup_dotfiles.sh
```

### Specific Problems

**Electron Apps & Cursor Theme:**

If Electron apps don't respect cursor themes:
```bash
# Create default cursor symlink
sudo ln -sf ~/.local/share/icons/Bibata-Modern-Classic ~/.local/share/icons/default
# Or system-wide
sudo ln -sf /usr/share/icons/Bibata-Modern-Classic /usr/share/icons/default
```

**Multi-Monitor Issues:**

```bash
# Check monitor names
hyprctl monitors

# Update hyprland/rules.conf with correct names
nano ~/.config/hypr/hyprland/rules.conf

# Reload Hyprland
hyprctl reload
```

**Network Issues:**

```bash
# Check network manager
systemctl status NetworkManager

# WiFi problems
nmcli device wifi list

# DNS issues
cat /etc/resolv.conf
```

**Audio Problems:**

```bash
# Restart PipeWire
systemctl --user restart pipewire

# Check audio devices
pactl list sinks

# Volume control GUI
pavucontrol
```

**Performance Issues:**

- Use game mode toggle in Waybar (🎮) for gaming
- Disable animations in `~/.config/hypr/hyprland/general.conf`
- Check GPU drivers: `lspci -k | grep -A 2 -E "(VGA|3D)"`

---

## Maintenance

### Keeping the System Updated

```bash
# Update all packages
yay -Syu

# Update dotfiles repo
cd ~/linux
git pull

# Re-run setup if needed (safe to run multiple times)
./setup.sh
```

### Performance Monitoring

- Use `htop` or `btop` for system monitoring
- Check GPU usage: `corectrl` (AMD) or `nvidia-smi` (NVIDIA)
- Monitor disk usage: `df -h` and `du -sh ~/.local/share/`


---

## Quick Reference

### Common Commands

```bash
# Reload Hyprland config
hyprctl reload

# Check running windows
hyprctl clients

# Monitor information
hyprctl monitors

# Take screenshot
grim -g "$(slurp)" ~/screenshot.png

# Restart Waybar
killall waybar && waybar &

# Update system
yay -Syu

# Clear clipboard history
cliphist wipe
```

### Directory Quick Access

- **Hyprland configs**: `~/.config/hypr/`
- **Scripts**: `~/linux/scripts/`
- **Custom bins**: `~/.local/bin/`
- **Wallpapers**: `~/.local/share/wallpapers/`
- **Assets**: `~/.local/share/`
- **Launch scripts**: `~/.local/share/launch-scripts/`

---

## License

Personal use. Fork and adapt as you like!

**System Specs Tested On:**
- Arch Linux (latest)
- EndeavourOS 2024+
- AMD/Intel/NVIDIA GPUs supported
- 8GB+ RAM recommended

---

## Contributing

This is a personal dotfiles repository, but feel free to:
- Fork and adapt for your own use
- Submit issues if you find bugs
- Suggest improvements via pull requests

**Note**: This setup includes personal configurations (SSH hosts, drive mounts, etc.). Remember to customize these for your own system before using!
