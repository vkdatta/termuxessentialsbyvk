#!/usr/bin/env bash

SCRIPT_HOME="$(dirname "${BASH_SOURCE[0]}")"
SETTINGS_FILE="$SCRIPT_HOME/bashbasicsbyvk.cfg"

[ -f "$SETTINGS_FILE" ] && source "$SETTINGS_FILE"

: "${show_hidden_files:=false}"
: "${imaginary_threshold:=200}"

settings_menu() {
    echo "⚙️ Settings:"
    echo "1) Hidden file settings"
    echo "2) Imaginary mode threshold"
    read -p "Enter choice [1-2]: " main_choice
    case "$main_choice" in
        1) hidden_file_settings ;;
        2) imaginary_threshold_settings ;;
        *) echo "❌ Invalid choice" ;;
    esac
}

hidden_file_settings() {
    echo "🗂️ Hidden file settings:"
    echo "1) Show normal types (default)"
    echo "2) Show all types (including hidden)"
    read -p "Enter choice [1-2]: " s_choice
    case "$s_choice" in
        1) show_hidden_files=false ;;
        2) show_hidden_files=true ;;
        *) echo "❌ Invalid choice"; return ;;
    esac

    save_settings
    echo "✅ Hidden file setting saved and persistent"
}

imaginary_threshold_settings() {
    echo "🗂️ Imaginary mode threshold:"
    echo "Use index-based sorting if number of files/folders in path exceeds a number."
    echo "Current: $imaginary_threshold"
    read -p "Enter new threshold number: " new_threshold
    if [[ "$new_threshold" =~ ^[0-9]+$ ]] && [ "$new_threshold" -gt 0 ]; then
        imaginary_threshold=$new_threshold
        save_settings
        echo "✅ Threshold set to $imaginary_threshold and saved"
    else
        echo "❌ Invalid number. Must be a positive integer."
    fi
}

save_settings() {
    {
        echo "show_hidden_files=$show_hidden_files"
        echo "imaginary_threshold=$imaginary_threshold"
    } > "$SETTINGS_FILE"
}
