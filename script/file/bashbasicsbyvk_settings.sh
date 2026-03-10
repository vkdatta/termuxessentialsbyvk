echo "--- 🔍 Debug: Script Startup ---"
if [ -f "bashbasicsbyvk.cfg" ]; then
    echo "📍 Found 'bashbasicsbyvk.cfg'. Loading settings..."
    source "bashbasicsbyvk.cfg"
    echo "📝 Current value of show_all_types after source: $show_all_types"
else
    echo "📍 'bashbasicsbyvk.cfg' not found. Using defaults."
fi

# Ensure the variable has a default if the file was empty or missing
: "${show_all_types:=false}"
echo "📝 Final value for this session: $show_all_types"
echo "--------------------------------"

hidden_file_settings() {
    echo "🗂️ Hidden file settings:"
    echo "1) Show normal types (default)"
    echo "2) Show all types (including hidden)"
    read -p "Enter choice [1-2]: " s_choice
    
    case "$s_choice" in
        1) 
            show_all_types=false 
            echo "DEBUG: User chose 1. Setting variable to false."
            ;;
        2) 
            show_all_types=true 
            echo "DEBUG: User chose 2. Setting variable to true."
            ;;
        *) 
            echo "❌ Invalid choice"
            return 
            ;;
    esac

    # --- THE CRITICAL WRITE STEP ---
    echo "DEBUG: Attempting to write to 'bashbasicsbyvk.cfg'..."
    
    # We use 'printf' to avoid trailing spaces and '>' to overwrite completely
    printf "show_all_types=%s\n" "$show_all_types" > "bashbasicsbyvk.cfg"
    
    # Check if the write actually worked
    if [ $? -eq 0 ]; then
        echo "✅ SUCCESS: Write command exit code 0."
        echo "📍 Physical Location: $(pwd)/bashbasicsbyvk.cfg"
        echo "📄 ACTUAL FILE CONTENT NOW:"
        cat "bashbasicsbyvk.cfg"
    else
        echo "❌ ERROR: Write command failed! Do you have write permissions in $(pwd)?"
    fi
}

settings_menu() {
    echo "⚙️ Settings:"
    echo "1) Hidden file settings"
    read -p "Enter choice [1]: " main_choice
    case "$main_choice" in
        1) hidden_file_settings ;;
        *) echo "❌ Invalid choice" ;;
    esac
}
