render_directory() {
    echo
    if $move_mode; then
        echo "🚚 MOVE MODE: Select destination folder"
    elif $copy_mode; then
        echo "📋 COPY MODE: Select destination folder"
    else
        echo "📂 Location: $path"
    fi
    echo

    items=("$path"/*)

    if [ ${#items[@]} -eq 0 ]; then
        echo "🛑 This directory is empty"
    else
        idx=1
        for item in "${items[@]}"; do
            if [ -d "$item" ]; then
                icon="📁"
            else
                icon="📄"
            fi
            printf "%2d) %s %s\n" "$idx" "$icon" "$(basename "$item")"
            idx=$((idx+1))
        done
    fi

    echo
    if $move_mode || $copy_mode; then
        echo "c) Confirm   x) Cancel"
    fi
    echo
}
handle_move_mode() {
    case "$choice" in
        c|C)
            for item in "${selected_items[@]}"; do
                mv -v "$item" "$path/"
            done
            echo "✅ Items moved successfully"
            move_mode=false
            path="$original_path"
            selected_items=()
            return 0
            ;;

        x|X)
            echo "🚫 Move cancelled"
            move_mode=false
            path="$original_path"
            selected_items=()
            return 0
            ;;
    esac
    return 1
}
perform_copy() {
    for item in "${selected_items[@]}"; do
        if [ ! -e "$item" ]; then
            echo "❌ Item not found: $(basename "$item")"
            continue
        fi
        base=$(basename -- "$item")
        name="${base%.*}"
        ext="${base##*.}"
        if [[ "$base" == "$ext" ]]; then
            name="$base"
            ext=""
        fi
        count=1
        newbase="$base"
        while [ -e "$path/$newbase" ]; do
            if [ -n "$ext" ]; then
                newbase="${name}_${count}.${ext}"
            else
                newbase="${name}_${count}"
            fi
            count=$((count+1))
        done
        cp -r -- "$item" "$path/$newbase"
        echo "📋 Copied: $(basename "$item") → $newbase"
    done
}
handle_copy_mode() {
    case "$choice" in
        c|C)
            perform_copy
            echo "✅ Items copied successfully"
            copy_mode=false
            path="$original_path"
            selected_items=()
            return 0
            ;;

        x|X)
            echo "🚫 Copy operation cancelled"
            copy_mode=false
            path="$original_path"
            selected_items=()
            return 0
            ;;
    esac
    return 1
}
