[ -f "bashbasicsbyvk.cfg" ] && source "bashbasicsbyvk.cfg"

: "${show_all_types:=false}"

settings_menu() {
    echo "⚙️ Settings:"
    echo "1) Hidden file settings"
    read -p "Enter choice [1]: " main_choice
    case "$main_choice" in
        1) hidden_file_settings ;;
        *) echo "❌ Invalid choice" ;;
    esac
}

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

    echo "show_all_types=$show_all_types" > "bashbasicsbyvk.cfg"
    echo "✅ Hidden file setting saved and persistent"
}
