# Arch + Hyprland: Dotfiles & Setup Scripts

This repository contains my personal dotfiles and post-installation scripts for quickly configuring a fresh Arch Linux (or EndeavourOS) system with the Hyprland compositor.

The session is managed by `uwsm` for a clean, minimal startup process.

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

Install a minimal Arch Linux or EndeavourOS (the "No Desktop" option), then run:

```bash
curl -sL https://raw.githubusercontent.com/tefloon/linux/main/bootstrap.sh | sudo bash
```

This will:
- Clone the repo to your user's home directory
- Run the main setup script as your user
- Configure `/etc/fstab` with personal drive mounts
- Set up personal hosts file
- Configure git remote for SSH access

### 2. **Post-Install**

- Reboot your system
- At the login screen (SDDM), select the "uwsm" session
- Log in and enjoy your Hyprland desktop!

### 3. **Cursor Setup**

- Install a hyprcursor theme and set it in `hyprland.conf`: `env = HYPRCURSOR_THEME,ThemeName`
- For X11 fallback: `sudo ln -sf /usr/share/icons/CursorTheme /usr/share/icons/default`
- Update GTK settings: `gsettings set org.gnome.desktop.interface cursor-theme 'CursorTheme'`

---

## What Gets Installed?

### Core Hyprland Stack
- **Compositor**: `hyprland`, `hyprpaper`, `waybar`, `wofi`, `kitty`
- **System**: `mako`, `swaylock`, `swayidle`, `wl-clipboard`
- **Screenshots**: `grim`, `slurp`
- **Portals**: `polkit-kde-agent`, `xdg-desktop-portal-hyprland`
- **Qt/Wayland**: `qt5-wayland`, `qt6-wayland`, `qt5ct`, `qt6ct`

### Development & Productivity
- **Text Editors**: Sublime Text 4, VS Code, Cursor
- **File Management**: `yazi`, `fd`, `bat`, `tree`
- **Shells**: `zsh` with `zsh-syntax-highlighting`, `zsh-autosuggestions`, `zoxide`
- **Tools**: `jq`, `bitwarden-cli`, `keychain`, `tealdeer`

### Applications
- **Browsers**: Thorium Browser, Brave
- **Communication**: Ferdium (messaging), KDE Connect
- **Media**: Kodi, Spotify, `spotifyd`, `spotify-player`
- **Office**: OnlyOffice, Obsidian, Calibre
- **Gaming**: Steam, Lutris
- **Utilities**: `copyq`, `corectrl`, `qbittorrent`

### Custom Scripts
Located in `bin/` and symlinked to `~/.local/bin`:
- **`cb`**: Print to stdout AND copy to clipboard (for piping)
- **`mdd`**: Recursively format text files as markdown for AI/note-taking
- **`dim`**: Multi-monitor screen dimming utility for movies

---

## Configuration Structure

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

## Customization

### Adding Packages
Edit `scripts/install_packages.sh` to add/remove packages:
- Official packages: Add to `install_pkg` calls
- AUR packages: Add to `install_aur_pkg` calls

### Dotfiles
Place any config files in `dotfiles/` and they'll be automatically symlinked to the corresponding location in `$HOME`.

### Personal Hosts
Edit `dotfiles/hosts` to add custom host entries (automatically linked to `/etc/hosts`).

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

### Electron Apps & Cursors
If Electron apps don't respect cursor themes:
```bash
sudo ln -sf /usr/share/icons/YourCursorTheme /usr/share/icons/default
```

### Bitwarden Authentication
If secrets retrieval fails, ensure you're logged in:
```bash
bw login
bw unlock
```

### Game Mode Toggle
Waybar includes a game mode toggle (🎮) that:
- Disables animations, blur, shadows
- Removes gaps and rounding
- Enables tearing for better gaming performance

### Testing
#### 1. Create a new user with
```bash
sudo useradd -m testuser -G wheel
sudo passwd testuser
# Set a simple password you'll remember
```

#### 2. Reboot
```bash
bashsudo reboot
```

#### 3. Once logged in as testuser
Open a terminal and run:
```bash
bashwhoami          # Verify you're testuser
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
---

## License

Personal use. Fork and adapt as you like!