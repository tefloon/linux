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
