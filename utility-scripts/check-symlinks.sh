#!/bin/bash

dotfiles_dir="/home/antek/linux/dotfiles/.config"
config_dir="/home/antek/.config"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Checking dotfiles symlinks..."
echo "=============================="

# Check files
find "$dotfiles_dir" -type f | while read -r file; do
    relative_path="${file#$dotfiles_dir/}"
    target_path="$config_dir/$relative_path"
    
    if [[ -L "$target_path" ]]; then
        # Get the canonical path of the symlink target
        link_target=$(readlink -f "$target_path")
        canonical_file=$(readlink -f "$file")
        
        if [[ "$link_target" == "$canonical_file" ]]; then
            echo -e "${GREEN}✓${NC} FILE: $relative_path"
        else
            echo -e "${RED}✗${NC} FILE: $relative_path (points to: $(readlink "$target_path"), should point to: $file)"
        fi
    elif [[ -e "$target_path" ]]; then
        echo -e "${RED}✗${NC} FILE: $relative_path (exists but not a symlink)"
    else
        echo -e "${RED}✗${NC} FILE: $relative_path (missing)"
    fi
done

echo ""
echo "Directory structure check:"
echo "========================="

# Check directories - FIXED VERSION
find "$dotfiles_dir" -type d | while read -r dir; do
    relative_path="${dir#$dotfiles_dir/}"
    target_path="$config_dir/$relative_path"
    
    # Skip the root directory AND empty relative paths
    if [[ -n "$relative_path" && "$relative_path" != "." && "$relative_path" != "$dotfiles_dir" ]]; then
        if [[ -d "$target_path" ]]; then
            echo -e "${GREEN}✓${NC} DIR:  $relative_path"
        else
            echo -e "${RED}✗${NC} DIR:  $relative_path (missing)"
        fi
    fi
done