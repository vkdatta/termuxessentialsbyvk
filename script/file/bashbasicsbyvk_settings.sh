#!/usr/bin/env bash

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bashbasicsbyvk"
SETTINGS_FILE="$CONFIG_DIR/config"

mkdir -p "$CONFIG_DIR"

DEFAULT_SHOW_HIDDEN_FILES=false
DEFAULT_INDEX_MODE_THRESHOLD=200
DEFAULT_TERMINAL_BG_COLOR=""
DEFAULT_TERMINAL_TEXT_COLOR=""

unset show_hidden_files
unset index_mode_threshold
unset terminal_bg_color
unset terminal_text_color

[ -f "$SETTINGS_FILE" ] && source "$SETTINGS_FILE"

: "${show_hidden_files:=$DEFAULT_SHOW_HIDDEN_FILES}"
: "${index_mode_threshold:=$DEFAULT_INDEX_MODE_THRESHOLD}"
: "${terminal_bg_color:=$DEFAULT_TERMINAL_BG_COLOR}"
: "${terminal_text_color:=$DEFAULT_TERMINAL_TEXT_COLOR}"

_get_rc_file() {
    local current_shell
    current_shell="$(basename "${SHELL:-bash}")"
    case "$current_shell" in
        zsh)  echo "$HOME/.zshrc" ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        *)    echo "$HOME/.bashrc" ;;
    esac
}

_MARKER_BEGIN="# ── bashbasicsbyvk colors BEGIN ──"
_MARKER_END="# ── bashbasicsbyvk colors END ──"

_normalize_hex() {
    echo "${1#\#}" | tr '[:lower:]' '[:upper:]'
}

_valid_hex() {
    local hex
    hex="$(_normalize_hex "$1")"
    [[ "$hex" =~ ^[0-9A-Fa-f]{6}$ ]]
}

_hex_to_rgb() {
    local hex
    hex="$(_normalize_hex "$1")"
    printf "%d %d %d" \
        "$((16#${hex:0:2}))" \
        "$((16#${hex:2:2}))" \
        "$((16#${hex:4:2}))"
}

apply_colors() {
    if [ -n "$terminal_bg_color" ] && _valid_hex "$terminal_bg_color"; then
        read -r r g b <<< "$(_hex_to_rgb "$terminal_bg_color")"
        printf "\e[48;2;%d;%d;%dm" "$r" "$g" "$b"
    fi
    if [ -n "$terminal_text_color" ] && _valid_hex "$terminal_text_color"; then
        read -r r g b <<< "$(_hex_to_rgb "$terminal_text_color")"
        printf "\e[38;2;%d;%d;%dm" "$r" "$g" "$b"
    fi
    if [ -n "$terminal_bg_color" ] || [ -n "$terminal_text_color" ]; then
        printf "\e[2J\e[H"
    fi
}

reset_colors() {
    printf "\e[0m"
    printf "\e[2J\e[H"
}

_persist_colors_to_rc() {
    local rc_file
    rc_file="$(_get_rc_file)"
    touch "$rc_file"
    _remove_colors_from_rc
    local block=""
    block+="$_MARKER_BEGIN\n"
    if [ -n "$terminal_bg_color" ] && _valid_hex "$terminal_bg_color"; then
        read -r r g b <<< "$(_hex_to_rgb "$terminal_bg_color")"
        block+="printf '\\e[48;2;${r};${g};${b}m'\n"
    fi
    if [ -n "$terminal_text_color" ] && _valid_hex "$terminal_text_color"; then
        read -r r g b <<< "$(_hex_to_rgb "$terminal_text_color")"
        block+="printf '\\e[38;2;${r};${g};${b}m'\n"
    fi
    if [ -n "$terminal_bg_color" ] || [ -n "$terminal_text_color" ]; then
        block+="printf '\\e[2J\\e[H'\n"
    fi
    block+="$_MARKER_END"
    printf "\n%b\n" "$block" >> "$rc_file"
}

_remove_colors_from_rc() {
    local rc_file
    rc_file="$(_get_rc_file)"
    [ -f "$rc_file" ] || return
    local tmp_file="${rc_file}.bbvk_tmp"
    awk "
        /^# ── bashbasicsbyvk colors BEGIN ──$/ { skip=1 }
        !skip { print }
        /^# ── bashbasicsbyvk colors END ──$/ { skip=0 }
    " "$rc_file" > "$tmp_file" && mv "$tmp_file" "$rc_file"
}

settings_menu() {
    echo "⚙️  Settings:"
    echo "1) Hidden file settings      (current: $show_hidden_files)"
    echo "2) Index mode threshold      (current: $index_mode_threshold)"
    echo "3) Terminal background color (current: ${terminal_bg_color:-terminal default})"
    echo "4) Terminal text color       (current: ${terminal_text_color:-terminal default})"
    echo "5) Restore ALL settings to default"
    read -p "Enter choice [1-5]: " main_choice
    case "$main_choice" in
        1) hidden_file_settings ;;
        2) index_mode_threshold_settings ;;
        3) terminal_bg_color_settings ;;
        4) terminal_text_color_settings ;;
        5) restore_all_defaults ;;
        *) echo "❌ Invalid choice" ;;
    esac
}

hidden_file_settings() {
    echo ""
    echo "🗂️  Hidden file settings:"
    echo "  Current: $show_hidden_files"
    echo "  Default: $DEFAULT_SHOW_HIDDEN_FILES"
    echo ""
    echo "1) Show normal files only"
    echo "2) Show all files including hidden"
    echo "3) Restore default (→ $DEFAULT_SHOW_HIDDEN_FILES)"
    echo "0) Back"
    read -p "Enter choice [0-3]: " s_choice
    case "$s_choice" in
        1) show_hidden_files=false; save_settings; echo "✅ Now showing normal files only" ;;
        2) show_hidden_files=true; save_settings; echo "✅ Now showing all files including hidden" ;;
        3) show_hidden_files=$DEFAULT_SHOW_HIDDEN_FILES; save_settings; echo "✅ Restored to default (→ $DEFAULT_SHOW_HIDDEN_FILES)" ;;
        0) return ;;
        *) echo "❌ Invalid choice" ;;
    esac
}

index_mode_threshold_settings() {
    echo ""
    echo "🗂️  Index mode threshold:"
    echo "  Use index-based sorting if files/folders in path exceed this number."
    echo "  Current: $index_mode_threshold"
    echo "  Default: $DEFAULT_INDEX_MODE_THRESHOLD"
    echo ""
    echo "1) Set new threshold"
    echo "2) Restore default (→ $DEFAULT_INDEX_MODE_THRESHOLD)"
    echo "0) Back"
    read -p "Enter choice [0-2]: " t_choice
    case "$t_choice" in
        1)
            read -p "Enter new threshold (positive integer): " new_threshold
            if [[ "$new_threshold" =~ ^[0-9]+$ ]] && [ "$new_threshold" -gt 0 ]; then
                index_mode_threshold=$new_threshold
                save_settings
                echo "✅ Threshold set to $index_mode_threshold"
            else
                echo "❌ Invalid. Must be a positive integer."
            fi
            ;;
        2) index_mode_threshold=$DEFAULT_INDEX_MODE_THRESHOLD; save_settings; echo "✅ Restored to default (→ $DEFAULT_INDEX_MODE_THRESHOLD)" ;;
        0) return ;;
        *) echo "❌ Invalid choice" ;;
    esac
}

terminal_bg_color_settings() {
    echo ""
    echo "🎨  Terminal background color:"
    echo "  Current: ${terminal_bg_color:-terminal default}"
    echo "  Default: ${DEFAULT_TERMINAL_BG_COLOR:-terminal default}"
    echo ""
    echo "1) Set new color (e.g. #1e1e2e or 1e1e2e)"
    echo "2) Clear color (restore terminal default)"
    echo "3) Restore default (→ ${DEFAULT_TERMINAL_BG_COLOR:-terminal default})"
    echo "0) Back"
    read -p "Enter choice [0-3]: " b_choice
    case "$b_choice" in
        1)
            read -p "Color: " input_color
            if _valid_hex "$input_color"; then
                terminal_bg_color="$(_normalize_hex "$input_color")"
                save_settings; _persist_colors_to_rc; apply_colors
                echo "✅ Background set to #$terminal_bg_color — active now and on every new session"
            else
                echo "❌ Invalid — must be 6 hex digits (e.g. #1e1e2e or 1e1e2e)"
            fi
            ;;
        2) terminal_bg_color=""; save_settings; _persist_colors_to_rc; reset_colors; apply_colors; echo "✅ Background cleared — using terminal default" ;;
        3) terminal_bg_color=$DEFAULT_TERMINAL_BG_COLOR; save_settings; _persist_colors_to_rc; reset_colors; apply_colors; echo "✅ Restored to default (→ ${DEFAULT_TERMINAL_BG_COLOR:-terminal default})" ;;
        0) return ;;
        *) echo "❌ Invalid choice" ;;
    esac
}

terminal_text_color_settings() {
    echo ""
    echo "🎨  Terminal text color:"
    echo "  Current: ${terminal_text_color:-terminal default}"
    echo "  Default: ${DEFAULT_TERMINAL_TEXT_COLOR:-terminal default}"
    echo ""
    echo "1) Set new color (e.g. #cdd6f4 or cdd6f4)"
    echo "2) Clear color (restore terminal default)"
    echo "3) Restore default (→ ${DEFAULT_TERMINAL_TEXT_COLOR:-terminal default})"
    echo "0) Back"
    read -p "Enter choice [0-3]: " c_choice
    case "$c_choice" in
        1)
            read -p "Color: " input_color
            if _valid_hex "$input_color"; then
                terminal_text_color="$(_normalize_hex "$input_color")"
                save_settings; _persist_colors_to_rc; apply_colors
                echo "✅ Text color set to #$terminal_text_color — active now and on every new session"
            else
                echo "❌ Invalid — must be 6 hex digits (e.g. #cdd6f4 or cdd6f4)"
            fi
            ;;
        2) terminal_text_color=""; save_settings; _persist_colors_to_rc; reset_colors; apply_colors; echo "✅ Text color cleared — using terminal default" ;;
        3) terminal_text_color=$DEFAULT_TERMINAL_TEXT_COLOR; save_settings; _persist_colors_to_rc; reset_colors; apply_colors; echo "✅ Restored to default (→ ${DEFAULT_TERMINAL_TEXT_COLOR:-terminal default})" ;;
        0) return ;;
        *) echo "❌ Invalid choice" ;;
    esac
}

restore_all_defaults() {
    echo ""
    echo "⚠️  This will reset ALL settings to factory defaults:"
    echo "  show_hidden_files    → $DEFAULT_SHOW_HIDDEN_FILES"
    echo "  index_mode_threshold → $DEFAULT_INDEX_MODE_THRESHOLD"
    echo "  terminal_bg_color    → ${DEFAULT_TERMINAL_BG_COLOR:-terminal default}"
    echo "  terminal_text_color  → ${DEFAULT_TERMINAL_TEXT_COLOR:-terminal default}"
    echo ""
    read -p "Are you sure? [y/N]: " confirm
    case "$confirm" in
        [yY]|[yY][eE][sS])
            show_hidden_files=$DEFAULT_SHOW_HIDDEN_FILES
            index_mode_threshold=$DEFAULT_INDEX_MODE_THRESHOLD
            terminal_bg_color=$DEFAULT_TERMINAL_BG_COLOR
            terminal_text_color=$DEFAULT_TERMINAL_TEXT_COLOR
            save_settings
            _remove_colors_from_rc
            reset_colors
            echo "✅ All settings restored to factory defaults"
            ;;
        *) echo "↩️  Cancelled — no changes made" ;;
    esac
}

save_settings() {
    {
        echo "show_hidden_files=$show_hidden_files"
        echo "index_mode_threshold=$index_mode_threshold"
        echo "terminal_bg_color=$terminal_bg_color"
        echo "terminal_text_color=$terminal_text_color"
    } > "$SETTINGS_FILE"
}

apply_colors
