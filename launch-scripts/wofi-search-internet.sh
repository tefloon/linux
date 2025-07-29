#!/bin/bash

if pgrep -x "wofi" > /dev/null; then
    pkill wofi
else
    # Get search term from wofi
    search_term=$(echo "" | wofi --dmenu --prompt "Search: " --lines 0 --height 1 --hide-scroll --width 400)

    # Check if user entered something
    if [ -n "$search_term" ]; then
        # URL encode the search term (basic encoding for common characters)
        encoded_term=$(echo "$search_term" | sed 's/ /+/g' | sed 's/&/%26/g')
        
        # Open thorium browser with DuckDuckGo search
        thorium-browser "https://duckduckgo.com/?t=h_&q=$encoded_term&ia=web"
    fi
fi
