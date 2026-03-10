render_directory() {

    echo

    if $move_mode; then
        echo "🚚 MOVE MODE: Select destination folder"
    elif $copy_mode; then
        echo "📋 COPY MODE: Select destination folder"
    else
        echo "📂 Location: $path"
    fi

    items=("$path"/*)

    if [ ${#items[@]} -eq 0 ]; then
        echo "🛑 This directory is empty"
        return
    fi

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
}
