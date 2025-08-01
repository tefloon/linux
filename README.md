# Arch + Hyprland: Dotfiles & Setup Scripts

This repository contains my personal dotfiles and automated setup scripts for quickly configuring a fresh Arch Linux (or EndeavourOS) system with the Hyprland compositor.

The session is managed by `uwsm` for a clean, minimal startup process.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Features](#features)
- [Quick Start](#quick-start)
- [What Gets Installed](#what-gets-installed)
- [Configuration Structure](#configuration-structure)
- [Custom Scripts](#custom-scripts)
- [Secrets Management](#secrets-management)
- [Asset Management](#asset-management)
- [Key Bindings](#key-bindings)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Testing](#testing)
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

---

## Quick Start

### 1. **Bootstrap Installation**

After installing a minimal Arch Linux or EndeavourOS (use the "No Desktop" option), run the bootstrap script as root:

```bash
curl -sL https://raw.githubusercontent.com/tefloon/linux/main/bootstrap.sh | sudo bash
```

**What the bootstrap script does:**
- Installs git if not present
- Clones this repository to your user's home directory
- Runs the main setup script (`setup.sh`) as your user
- Configures `/etc/fstab` with personal drive mounts (customize in bootstrap.sh)
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

### 2. **Post-Install Setup**

1. **Reboot your system** to ensure all services start properly
2. **Log in** and you should see your Hyprland desktop with:
   - Waybar at the top
   - Auto-started applications (browser, terminal, messaging)
   - Custom wallpaper and cursor theme

### 3. **Initial Configuration**

**Cursor Theme:**
- The setup installs Bibata Modern Classic automatically
- For X11 app compatibility: `sudo ln -sf /home/antek/.local/share/icons/Bibata-Modern-Classic /home/antek/.local/share/icons/default`
- Update GTK settings: `gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'`

**Secrets Setup (Optional):**
If you use Bitwarden for managing SSH keys and environment variables:
```bash
bw login  # Enter your credentials
bw unlock  # Enter your master password
./scripts/retrieve_secrets.sh  # Pull SSH keys and env vars
```

---

## What Gets Installed?

### Core Hyprland Stack
- **Compositor**: `hyprland`, `hyprpaper`, `waybar`, `wofi`, `kitty`
- **System**: `mako`, `swaylock`, `swayidle`, `wl-clipboard`
- **Screenshots**: `grim`, `slurp`
- **Portals**: `polkit-kde-agent`, `xdg-desktop-portal-hyprland`
- **Qt/Wayland**: `qt5-wayland`, `qt6-wayland`, `qt5ct`, `qt6ct`
- **Session Management**: `uwsm` (Universal Wayland Session Manager)

### Development & Productivity
- **Text Editors**: Sublime Text 4, VS Code, Cursor
- **File Management**: `yazi` (terminal file manager), `fd`, `bat`, `tree`
- **Shells**: `zsh` with `zsh-syntax-highlighting`, `zsh-autosuggestions`, `zoxide`
- **Tools**: `jq`, `bitwarden-cli`, `keychain`, `tealdeer` (tldr client)
- **Version Control**: Git with SSH key management

### Applications
- **Browsers**: Thorium Browser (default), Brave
- **Communication**: Ferdium (multi-platform messaging), KDE Connect
- **Media**: Kodi, Spotify, `spotifyd`, `spotify-player`
- **Office**: OnlyOffice, Obsidian (note-taking), Calibre (ebook management)
- **Gaming**: Steam, Lutris
- **Utilities**: `copyq` (clipboard manager), `corectrl` (AMD GPU control), `qbittorrent`

### System Enhancements
- **Audio**: PipeWire with WirePlumber
- **Themes**: Bibata cursor theme, custom Waybar styling
- **Fonts**: Development and UI font packages
- **Performance**: Custom kernel parameters and optimizations

## Custom Scripts

Located in `bin/` and symlinked to `~/.local/bin`:

- **`cb`**: Print to stdout AND copy to Wayland clipboard simultaneously (perfect for piping command output)
- **`mdd`**: Recursively converts directory contents to markdown format with syntax highlighting for AI tools and documentation

---

## Configuration Structure

### Repository Layout
```
linux/
├── README.md              # This file
├── setup.sh              # Main setup script
├── bootstrap.sh          # Root installation script
├── bin/                  # Custom utility scripts
│   ├── cb               # Clipboard copy tool
│   └── mdd              # Markdown directory formatter
├── scripts/             # Setup automation scripts
│   ├── install_packages.sh    # Package installation
│   ├── setup_dotfiles.sh      # Dotfile symlinking
│   ├── setup_shell.sh         # Shell configuration
│   ├── retrieve_secrets.sh    # Bitwarden integration
│   └── [other setup scripts]
├── dotfiles/            # Configuration files
│   └── hosts           # Custom hosts file
├── assets/             # Themes, wallpapers, archives
│   ├── icons/         # Cursor themes
│   └── wallpapers/    # Desktop backgrounds
└── launch-scripts/     # Application launchers
```

### Hyprland Config Organization
```
~/.config/hypr/
├── hyprland.conf          # Main config (sources others)
└── hyprland/
    ├── env.conf           # Environment variables
    ├── execs.conf         # Autostart applications
    ├── general.conf       # Window manager settings
    ├── keybinds.conf      # Key bindings
    ├── rules.conf         # Window rules
    └── colors.conf        # Color scheme
```

### Setup Script Dependencies
```
setup.sh
├── scripts/install_packages.sh    # Installs all packages
├── scripts/setup_shell.sh          # Configures zsh
├── scripts/setup_scripts.sh        # Links bin/ scripts
├── scripts/setup_dotfiles.sh       # Links config files
├── scripts/setup_launch_scripts.sh # Sets up launchers
├── scripts/setup_assets.sh         # Extracts themes/assets
├── scripts/setup_system.sh         # System configurations
└── scripts/retrieve_secrets.sh     # Bitwarden secrets
```

### Multi-Monitor Setup
- **HDMI-A-2** (Left): Workspaces 1, 4
- **DP-1** (Center): Workspaces 2, 5  
- **HDMI-A-1** (Right): Workspaces 3, 6
- **Special workspace**: `magic` for scratchpad (Obsidian)

### Key Applications & Workspaces
- **Workspace 2**: Thorium Browser (auto-start)
- **Workspace 3**: Kitty terminal (auto-start)
- **Workspace 4**: Ferdium messaging (auto-start)
- **Special workspace**: Obsidian notes (auto-start)

---

## Secrets Management

The setup integrates with Bitwarden CLI for secure credential management:

```bash
# Retrieve SSH keys and environment secrets
./scripts/retrieve_secrets.sh

# Test mode (dry run)
./scripts/retrieve_secrets.sh --test
```

This automatically:
- Extracts SSH keys from Bitwarden to `~/.ssh/`
- Creates environment variables in `~/.zsh_secrets`
- Sets proper permissions (600 for private keys, 644 for public)

---

## Asset Management

The setup automatically handles assets in the `assets/` directory:

- **Archives** (`.zip`, `.tar.gz`, etc.): Extracted to `~/.local/share/`
- **Images** (`.png`, `.jpg`, etc.): Symlinked to `~/.local/share/`
- **Launch scripts**: Available at `~/.local/share/launch-scripts/`

---

## Quick Reference

### Common Commands
```bash
# Reload Hyprland config
hyprctl reload

# Check running processes
hyprctl clients

# Monitor information
hyprctl monitors

# Take screenshot
grim -g "$(slurp)" ~/screenshot.png

# Restart Waybar
killall waybar && waybar &

# Update system
yay -Syu
```

### Directory Quick Access
- **Configs**: `~/.config/hypr/`
- **Scripts**: `~/linux/scripts/`
- **Custom bins**: `~/.local/bin/`
- **Wallpapers**: `~/.local/share/wallpapers/`
- **Assets**: `~/.local/share/`

## Customization

### Adding Packages
Edit `scripts/install_packages.sh` to add/remove packages:
```bash
# Official packages
install_pkg "package-name"

# AUR packages  
install_aur_pkg "aur-package-name"
```

### Adding Dotfiles
1. Place config files in `dotfiles/` directory
2. Run `bash scripts/setup_dotfiles.sh` to create symlinks
3. Files maintain the same relative path structure

### Custom Hosts
Edit `dotfiles/hosts` to add custom host entries (automatically linked to `/etc/hosts` by bootstrap.sh).

### Personalizing the Setup
- **Monitor setup**: Edit `hyprland/rules.conf` for your monitor layout
- **Keybindings**: Modify `hyprland/keybinds.conf`
- **Autostart apps**: Update `hyprland/execs.conf`
- **Colors/theme**: Adjust `hyprland/colors.conf` and Waybar configs

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
| `Super + 1-6` | Switch workspaces |
| `Super + Q` | Close window |
| `Super + V` | Toggle floating |
| `Print` | Screenshot selection |
| `Super + I` | Window info (class/title) |

---

## Troubleshooting

### Common Issues

**Installation Failed/Stopped:**
```bash
# Check what failed
journalctl -xe

# If the problem was a package, check the logs in /tmp/pacman.log and /tmp/yay.log
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

**Electron Apps & Cursors:**
If Electron apps don't respect cursor themes:
```bash
sudo ln -sf /home/<username>/.local/share/icons/Bibata-Modern-Classic /home/<username>/.local/share/icons/default
# and/or
sudo ln -sf /usr/share/icons/Bibata-Modern-Classic /usr/share/icons/default
```

**Bitwarden Authentication:**
If secrets retrieval fails:
```bash
bw login     # Use your email
bw unlock    # Enter master password
bw sync      # Ensure latest data
```

**Multi-Monitor Issues:**
- Check monitor names: `hyprctl monitors`
- Update `hyprland/rules.conf` with correct monitor names
- Restart Hyprland: `hyprctl reload`

**Performance Issues:**
- Use game mode toggle in Waybar (🎮) for gaming
- Disable animations in `hyprland/general.conf`
- Check GPU drivers: `lspci -k | grep -A 2 -E "(VGA|3D)"`

**Network Issues:**
- Check network manager: `systemctl status NetworkManager`
- WiFi problems: `nmcli device wifi list`
- DNS issues: Check `/etc/resolv.conf`

**Audio Problems:**
- Restart PipeWire: `systemctl --user restart pipewire`
- Check audio devices: `pactl list sinks`
- Volume control: `pavucontrol`

## Testing

### Validation Steps

After installation, verify everything works:

```bash
# Check key applications
which hyprland waybar wofi kitty

# Verify dotfiles are linked
ls -la ~/.config/hypr/
ls -la ~/.zshrc

# Test custom scripts
cb --help     # Should show usage or work silently
mdd --help    # Should work with directory

# Check secrets (if using Bitwarden)
ls -la ~/.ssh/
echo $SSH_AUTH_SOCK

# Test Hyprland features
hyprctl version
hyprctl monitors
wofi --show drun --allow-images &  # Test app launcher
```

### Performance Verification
```bash
# Check system resources
htop

# GPU information (if applicable)
lspci | grep -i vga
glxinfo | grep "OpenGL renderer"

# Check audio
pactl info
```

### Full System Test
#### 1. Create a new user with
```bash
sudo useradd -m testuser -G wheel
sudo passwd testuser
# Set a simple password you'll remember
```

#### 2. Reboot
```bash
reboot
```

#### 3. Once logged in as testuser
Open a terminal and run:
```bash
whoami          # Verify you're testuser
echo $HOME      # Should be /home/testuser
cd ~
git clone https://github.com/tefloon/linux.git
cd linux
./setup.sh
```

#### 4. Clean up
```bash
# Back on your main user
sudo userdel -r testuser
```

---

## Maintenance & Updates

### Keeping the System Updated
```bash
# Update all packages
yay -Syu

# Update this dotfiles repo
cd ~/linux
git pull

# Re-run setup if needed
./setup.sh
```

### Performance Monitoring
- Use `htop` or `btop` for system monitoring
- Check GPU usage with `corectrl` (AMD) or `nvidia-smi` (NVIDIA)
- Monitor disk usage: `df -h` and `du -sh ~/.local/share/`

---

## License

Personal use. Fork and adapt as you like!

**System Specs Tested On:**
- Arch Linux (latest)
- EndeavourOS 2024+
- AMD/Intel/NVIDIA GPUs supported
- 8GB+ RAM recommended