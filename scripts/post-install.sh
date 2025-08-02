#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"

CURRENT_STEP_MESSAGE="Setting up default programs"
status_msg

# PDF Documents
xdg-mime default org.pwmt.zathura.desktop application/pdf

# Images
xdg-mime default org.gnome.Loupe.desktop image/jpeg
xdg-mime default org.gnome.Loupe.desktop image/png
xdg-mime default org.gnome.Loupe.desktop image/gif
xdg-mime default org.gnome.Loupe.desktop image/webp
xdg-mime default org.gnome.Loupe.desktop image/bmp
xdg-mime default org.gnome.Loupe.desktop image/tiff
xdg-mime default org.gnome.Loupe.desktop image/svg+xml

# Web browsers
xdg-mime default thorium-browser.desktop x-scheme-handler/http
xdg-mime default thorium-browser.desktop x-scheme-handler/https
xdg-mime default thorium-browser.desktop text/html

# Text files and code
xdg-mime default sublime_text.desktop text/plain
xdg-mime default sublime_text.desktop text/x-python
xdg-mime default sublime_text.desktop text/x-shellscript
xdg-mime default sublime_text.desktop text/x-csrc
xdg-mime default sublime_text.desktop text/x-c++src
xdg-mime default sublime_text.desktop application/javascript
xdg-mime default sublime_text.desktop application/json
xdg-mime default sublime_text.desktop text/css
xdg-mime default sublime_text.desktop text/html
xdg-mime default sublime_text.desktop text/xml
xdg-mime default sublime_text.desktop text/x-log
xdg-mime default sublime_text.desktop application/x-yaml

# Office documents (OnlyOffice)
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document  # .docx
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.openxmlformats-officedocument.spreadsheetml.sheet        # .xlsx
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.openxmlformats-officedocument.presentationml.presentation # .pptx
xdg-mime default onlyoffice-desktopeditors.desktop application/msword                    # .doc
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.ms-excel             # .xls
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.ms-powerpoint        # .ppt
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.oasis.opendocument.text           # .odt
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.oasis.opendocument.spreadsheet    # .ods
xdg-mime default onlyoffice-desktopeditors.desktop application/vnd.oasis.opendocument.presentation   # .odp

# Video files (uosc/mpv)
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-msvideo        # .avi
xdg-mime default mpv.desktop video/quicktime        # .mov
xdg-mime default mpv.desktop video/x-matroska       # .mkv
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/x-flv            # .flv
xdg-mime default mpv.desktop video/3gpp             # .3gp
xdg-mime default mpv.desktop video/x-ms-wmv         # .wmv
xdg-mime default mpv.desktop video/ogg              # .ogv

# Audio files (system default is usually fine, but you could set Spotify for music)
# Note: These would only apply to local audio files, not streaming

# Archives (file manager or archive manager)
xdg-mime default org.kde.dolphin.desktop application/zip
xdg-mime default org.kde.dolphin.desktop application/x-tar
xdg-mime default org.kde.dolphin.desktop application/x-compressed-tar
xdg-mime default org.kde.dolphin.desktop application/x-bzip-compressed-tar
xdg-mime default org.kde.dolphin.desktop application/x-xz-compressed-tar
xdg-mime default org.kde.dolphin.desktop application/x-rar-compressed

# E-books (Calibre)
xdg-mime default calibre-ebook-viewer.desktop application/epub+zip
xdg-mime default calibre-ebook-viewer.desktop application/x-mobipocket-ebook
xdg-mime default calibre-ebook-viewer.desktop application/vnd.amazon.ebook

# Terminal
xdg-mime default kitty.desktop application/x-terminal-emulator

# File manager
xdg-mime default org.kde.dolphin.desktop inode/directory

# Email (if you handle email files)
# xdg-mime default thunderbird.desktop x-scheme-handler/mailto

# Torrents
xdg-mime default org.qbittorrent.qBittorrent.desktop application/x-bittorrent

# Configuration files
xdg-mime default sublime_text.desktop text/x-ini
xdg-mime default sublime_text.desktop application/x-desktop

status_ok

CURRENT_STEP_MESSAGE="Updating desktop database"
status_msg
update-desktop-database ~/.local/share/applications/ 2>/dev/null || status_skip
status_ok