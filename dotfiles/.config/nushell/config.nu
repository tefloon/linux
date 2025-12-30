# Nushell Config File

# Main configuration
$env.config = {
    show_banner: false
    
    # History configuration
    history: {
        max_size: 10000
        sync_on_enter: true
        file_format: "sqlite"
        isolation: false
    }
    
    # Completion configuration
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
    }
    
    # LS configuration
    ls: {
        use_ls_colors: true
        clickable_links: true
    }
    
    # Table configuration
    table: {
        mode: rounded
        index_mode: always
        show_empty: true
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
        }
    }
    
    # Color configuration
    color_config: {
        # Basic types
        separator: white
        leading_trailing_space_bg: { attr: n }
        header: green_bold
        empty: blue
        bool: white
        int: white
        filesize: cyan
        duration: white
        date: dark_gray
        range: white
        float: white
        string: white
        nothing: white
        binary: white
        cell-path: white
        row_index: green_bold
        record: white
        list: white
        block: white
        hints: dark_gray
        
        # Shapes (syntax highlighting in the command line)
        shape_garbage: { fg: white bg: red attr: b }
        shape_binary: purple_bold
        shape_bool: light_cyan
        shape_int: purple_bold
        shape_float: purple_bold
        shape_range: yellow_bold
        shape_internalcall: cyan_bold
        shape_external: cyan
        shape_externalarg: green_bold
        shape_literal: blue
        shape_operator: yellow
        shape_signature: green_bold
        shape_string: green
        shape_string_interpolation: cyan_bold
        shape_list: cyan_bold
        shape_table: blue_bold
        shape_record: cyan_bold
        shape_block: blue_bold
        shape_filepath: cyan
        shape_directory: blue_bold
        shape_globpattern: cyan_bold
        shape_variable: purple
        shape_flag: blue_bold
        shape_custom: green
        shape_nothing: light_cyan
    }
}

$env.config.hooks = {
    pre_prompt: [{ ||
        # Add newline before prompt (except for the very first prompt)
        if (history | length) > 0 {
            print ""
        }
    }]
}

# ============================================================================
# ALIASES
# ============================================================================

# Basic commands
alias sdn = shutdown now
alias vim = nvim
alias q = qalc
alias cd.. = cd ..

# File management
alias dgd = dragon-drop -x

# LS aliases (using native Nushell ls)
alias ll = ls -l
alias l = ls -l

# Utility aliases
alias ncdu = ncdu --color dark

# ============================================================================
# CUSTOM COMMANDS
# ============================================================================

# Open files with default application (background)
def s [...args] {
    xdg-open ...$args
}

# Better man pages with bat
def man [page: string] {
    ^man $page | col -bx | bat --language=man --plain
}

# Git log with bat pager
def "git log" [...args] {
    ^git log ...$args | bat --style=plain --paging=always
}

# Custom ls variations
def lm [] {
    ls | sort-by modified -r
}

def lt [] {
    ls | where type == dir
}

def "l." [] {
    ls -la | where name =~ '^\.'
}