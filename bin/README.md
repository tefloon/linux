# Custom Scripts

Located in `bin/` and automatically symlinked to `~/.local/bin`:

- [`cb`](#cb---clipboard-copy-tool) — print to stdout and copy to the clipboard in one pipe
- [`create-playlist`](#create-playlist) — build an M3U playlist for an album folder (Jellyfin-friendly)
- [`deck`](#deck---netrunner-deck-parser) — parse Netrunner deck lists to JSON
- [`get-transcript`](#get-transcript---youtube-transcript-fetcher) — fetch a YouTube transcript to a file
- [`graduate`](#graduate---symlink-helper) — move a config file to dotfiles repo and symlink it back
- [`kebabify`](#kebabify) — rename files and folders to kebab-case
- [`lxc`](#lxc---disposable-arch-container) — spin up a throwaway Arch container
- [`mdv`](#mdv---markdown-to-pdf) — create a temporary PDF from an MD and display it
- [`mdd`](#mdd---markdown-directory-formatter) — dump directory contents as markdown for AI tools
- [`ocr`](#ocr---ocr-screen-selection) — OCR a screen selection to the clipboard
- [`picker`](#picker---color-picker) — pick a screen colour to the clipboard
- [`screen-dimmer`](#screen-dimmer---screen-brightness-dimmer) — control screen brightness
- [`screenshot`](#screenshot---screenshot-to-clipboard) — screenshot a region to the clipboard
- [`screenshot-with-window`](#screenshot-with-window---screenshot-with-annotation) — screenshot, annotate, then copy
- [`tokens`](#tokens---token-counter) — count tokens in text or files

## `cb` - Clipboard Copy Tool
Prints to stdout AND copies to Wayland clipboard simultaneously. Perfect for piping command output:

```bash
   echo "Hello World" | cb
   cat file.txt | cb
```

## create-playlist

Build an **Extended M3U playlist** for one or more album folders — made for
getting ripped CDs into Jellyfin with correct track order and names.

### What it does

For each directory given (default: the current one), `create-playlist`:

1. **Scans audio files** in the folder, non-recursively — `mp3`, `flac`, `m4a`,
   `aac`, `ogg`, `opus`, `wma`, `wav` (case-insensitive). Cover art and other
   non-audio files are ignored.
2. **Reads tags** with a single `ffprobe` call per file: duration plus
   `disc`, `track`, `title` and `artist`.
3. **Sorts by disc, then track**, so `10` follows `9` instead of `1`. Files with
   no track tag fall back to a natural filename sort and land last.
4. **Labels each entry** as `Artist - Title`, falling back to just the title, or
   to the filename (minus extension) when tags are missing.
5. **Writes `<folder name>.m3u8` inside the folder**, using bare filenames so the
   playlist stays valid when the album is copied to Jellyfin.

### Notes

- **Skips folders with no audio** with a notice, instead of writing a broken file.
- **Batch-friendly** — pass many folders at once; a bad path is reported and the
  rest still process (exit status is non-zero if any fail).
- Handles `N/M` tag forms (`1/10` → `1`) and missing `disc` tags (default `1`).

### Usage

```sh
   create-playlist                 # the current directory
   create-playlist .               # the current directory
   create-playlist ~/rips/*/       # every album folder in a rip session
```

## deck - Netrunner Deck Parser
Parse Netrunner deck lists and output as JSON:

```bash
   deck decklist.txt  # Output JSON array of cards
```

## get-transcript - YouTube Transcript Fetcher
Fetch a YouTube video's transcript and save it as a kebab-case `.txt` file:

```bash
   get-transcript https://youtu.be/VIDEO_ID
```

## graduate - Symlink Helper
Adopt one or more individual files into your dotfiles repo, moving each
one into the mirrored location under the repo and symlinking it back.

```bash
  dotfiles-adopt.sh <file1> [file2] [file3] ...
```

Paths can be relative (to your current directory) or absolute, e.g.:
```bash
   cd ~/.config/waybar
   dotfiles-adopt.sh config.jsonc config_L.jsonc scripts/script1.sh
```
or
```
   dotfiles-adopt.sh ~/.zshrc ~/.gitconfig
```
This operates strictly on a PER-FILE basis - it never walks directories
and never symlinks a directory, only individual files you name
explicitly. Directory structure in the repo is recreated with mkdir -p
as needed.

## kebabify
Rename files and folders to clean **kebab-case**.
```bash
   Mój Ważny Plik'ów.TAR.GZ  →  moj-wazny-plikow.tar.gz
```

### What it does

For each name, `kebabify`:

1. **Lowercases** everything.
2. **Transliterates accents** to ASCII — Polish letters via an explicit map
   (`ż→z`, `ł→l`, `ą→a`, …) plus a Unicode NFKD fallback for other accented characters.
3. **Strips apostrophes** so `it's → its` (letters join instead of getting a hyphen).
4. Turns every other **non-alphanumeric run into a single hyphen**, trimming
   leading/trailing hyphens.
5. **Truncates by whole words** once the name passes a length limit (default `40`),
   never cutting mid-word.
6. **Preserves the extension**, including double extensions like `.tar.gz`,
   `.tar.bz2`, `.tar.xz`, `.tar.zst`.

### Safety

- **Collision-safe** — if the target name already exists, appends `-2`, `-3`, …
  so nothing is overwritten (checked case-insensitively).
- **Skips dotfiles/dotdirs** (anything starting with `.`) — hidden directories
  are not descended into either, so `.git` and friends are left completely alone.
- **Skips well-known project files** — `CLAUDE.md`, `README.md`, `HANDOFF.md`
  (case-insensitive).
- **Folders recurse fully** and the folder itself is renamed too, done
  **bottom-up** so child paths stay valid throughout the walk.

### Usage

```sh
   kebabify [options] PATH [PATH ...]
```

| Flag | Effect |
|------|--------|
| `PATH ...` | one or more files/folders to rename (required) |
| `-l, --limit N` | word-truncation length threshold (default: `40`) |
| `-n, --dry-run` | print planned renames without changing anything |
| `-R, --no-recurse` | for a folder, rename only the folder, not its contents |

### Examples

```sh
   kebabify -n .              # preview renaming everything here, incl. this folder
   kebabify ~/music/album     # rename a folder and its contents
   kebabify -R ~/music/album  # rename just the folder, leave contents alone
   kebabify *.mp3             # let the shell pick the targets
```

Note that `kebabify .` renames the current directory too. Your shell follows the
inode, so nothing breaks, but the prompt shows the old name until you `cd .`.
Passing no path at all is an error rather than an implicit `.` — a no-argument
command that recursively renames your whole working tree is a bad typo to have.

## `lxc` - Disposable Arch Container
Spin up a throwaway Arch LXC container, drop into a shell, and automatically destroy it on exit. Optionally bind-mount a host directory (read-only) — handy for testing this setup against your real repo without risking it:

```bash
   lxc                           # Ephemeral container named "archtest"
   lxc dotfiles-test ~/linux     # Mount ~/linux read-only for testing
```

## `mdv` - Markdown to PDF
Create a temporary PDF file in `/tmp` using `pandoc` and `weasyprint`. Display in Zathura then tear all the temp files down after the window is colsed

## `mdd` - Markdown Directory Formatter
Recursively converts directory contents to markdown format with syntax highlighting. Prints to `stdout` and copies to clipboard.

Great for sharing code context with AI tools:

```bash
   mdd /path/to/project
   mdd .  # Current directory
```

## `ocr` - OCR Screen Selection
Select a region of the screen and extract text using Tesseract OCR (supports Polish and English). Text is copied to clipboard:

```bash
   ocr  # Select region, text is copied to clipboard
```

## `picker` - Color Picker
Pick a color from anywhere on screen using hyprpicker. Color is copied to clipboard in hex format:

```bash
   picker  # Click anywhere to pick color
```

## `screen-dimmer` - Screen Brightness Dimmer
Compiled utility for controlling screen brightness/dimming:

```bash
   screen-dimmer  # Run the screen dimmer utility
```

## `screenshot` - Screenshot to Clipboard
Take a screenshot of a selected region and copy directly to clipboard:

```bash
   screenshot  # Select region, image copied to clipboard
```

## `screenshot-with-window` - Screenshot with Annotation
Take a screenshot with satty annotation tool for markup before copying:

```bash
   screenshot-with-window  # Select region, annotate, then copy
```

## `tokens` - Token Counter
Count tokens in text or files using tiktoken (OpenAI's tokenizer):

```bash
   tokens file.txt        # Count tokens in file
   echo "text" | tokens   # Count tokens from stdin
```
