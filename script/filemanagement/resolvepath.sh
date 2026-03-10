init_path() {
    if [ $# -eq 1 ]; then
        target="$1"

        if [ -d "$target" ]; then
            path=$(get_abs_path "$target")

        elif [ -f "$target" ]; then
            selected=$(get_abs_path "$target")
            handle_file "$selected"
            exit $?

        else
            echo "❌ Error: '$target' not found" >&2
            exit 1
        fi
    fi
}
