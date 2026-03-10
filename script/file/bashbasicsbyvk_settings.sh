#!/usr/bin/env bash

# --- NEW: CRITICAL PATH ANCHORING ---
# This finds the directory where this script actually sits on your disk
SCRIPT_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="$SCRIPT_HOME/bashbasicsbyvk.cfg"

# --- DEBUG: See where the anchor is ---
# echo "DEBUG: Settings will be saved to: $SETTINGS_FILE"

# 1. Source using the absolute path
[ -f "$SETTINGS_FILE" ] && source "$SETTINGS_FILE"

# 2. Source your other logic files (assuming they are in the same folder)
source "$SCRIPT_HOME/0_run.sh"
source "$SCRIPT_HOME/bashbasicsbyvk_settings.sh"

: "${show_all_types:=false}"

# ====================== MODIFIED SETTINGS FUNCTION ======================

hidden_file_settings() {
    echo "🗂️ Hidden file settings:"
    echo "1) Show normal types (default)"
    echo "2) Show all types (including hidden)"
    read -p "Enter choice [1-2]: " s_choice
    case "$s_choice" in
        1) show_all_types=false ;;
        2) show_all_types=true ;;
        *) echo "❌ Invalid choice"; return ;;
    esac

    # CRITICAL: Write to the ANCHORED path, not the current 'path' variable
    echo "show_all_types=$show_all_types" > "$SETTINGS_FILE"
    
    echo "✅ Settings saved to: $SETTINGS_FILE"
    echo "📝 Current Value: $show_all_types"
}

# ... [Rest of your helper functions: get_top_level_files, etc.] ...

# ====================== UPDATED MAIN LOOP START ======================

# Keep 'path' for navigation, but 'SCRIPT_HOME' stays for the config
path=$(pwd) 
move_mode=false
# ... rest of your variables ...
