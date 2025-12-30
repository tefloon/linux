# Nushell Environment Config File
# This file is loaded before config.nu

# Environment Variables
$env.EDITOR = "subl -w"
$env.PAGER = "bat"
$env.BAT_PAGER = "less -RF"

# Add ~/.local/bin to PATH
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/bin")

# Zoxide and Starship initialization
source ($nu.default-config-dir | path join zoxide.nu)
source ($nu.default-config-dir | path join starship.nu)

# Load secrets if they exist (convert to Nushell format if needed)
# source ~/.nu_secrets  # Create this file if you have secrets

# LS_COLORS for file type coloring
$env.LS_COLORS = (
    "di=1;34:"      +  # directories - bold blue
    "ln=1;36:"      +  # symlinks - bold cyan  
    "ex=32:"        +  # executables - green
    "*.zip=33:"     +  # archives - yellow (NOT red!)
    "*.tar=33:"     +
    "*.gz=33:"      +
    "*.bz2=33:"     +
    "*.xz=33:"      +
    "*.7z=33:"      +
    "*.rar=33:"     +
    "*.zst=33:"     +
    "*.mp4=35:"     +  # videos - magenta
    "*.mkv=35:"     +
    "*.avi=35:"     +
    "*.mov=35:"     +
    "*.webm=35:"    +
    "*.jpg=33:"     +  # images - yellow
    "*.png=33:"     +
    "*.gif=33:"     +
    "*.webp=33:"    +
    "*.mp3=32:"     +  # audio - green
    "*.flac=32:"    +
    "*.wav=32:"     +
    "*.pdf=37:"     +  # documents - white
    "*.doc=37:"     +
    "*.docx=37:"    +
    "*.xls=37:"     +
    "*.xlsx=37"
)
