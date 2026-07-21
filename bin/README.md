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

### `get-transcript` - YouTube Transcript Fetcher
Fetch a YouTube video's transcript and save it as a kebab-case `.txt` file:

```bash
get-transcript https://youtu.be/VIDEO_ID
```

### `lxc` - Disposable Arch Container
Spin up a throwaway Arch LXC container, drop into a shell, and automatically destroy it on exit. Optionally bind-mount a host directory (read-only) — handy for testing this setup against your real repo without risking it:

```bash
lxc                           # Ephemeral container named "archtest"
lxc dotfiles-test ~/linux     # Mount ~/linux read-only for testing
```

### `screen-dimmer` - Screen Brightness Dimmer
Compiled utility for controlling screen brightness/dimming:

```bash
screen-dimmer  # Run the screen dimmer utility
```

### kebabify

Rename files and folders to clean **kebab-case**.

```
Mój Ważny Plik'ów.TAR.GZ  →  moj-wazny-plikow.tar.gz
```

#### What it does

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

#### Safety

- **Collision-safe** — if the target name already exists, appends `-2`, `-3`, …
  so nothing is overwritten (checked case-insensitively).
- **Skips dotfiles/dotdirs** (anything starting with `.`).
- **Skips well-known project files** — `CLAUDE.md`, `README.md`, `HANDOFF.md`
  (case-insensitive).
- **Folders recurse fully** and the folder itself is renamed too, done
  **bottom-up** so child paths stay valid throughout the walk.

## Usage

```sh
kebabify [options] PATH [PATH ...]
```

| Flag | Effect |
|------|--------|
| `PATH ...` | one or more files/folders to rename (required) |
| `-l, --limit N` | word-truncation length threshold (default: `40`) |
| `-n, --dry-run` | print planned renames without changing anything |
| `-R, --no-recurse` | for a folder, rename only the folder, not its contents |
