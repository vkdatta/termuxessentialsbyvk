get_abs_path() {
    local target="$1"
    if [ -d "$target" ]; then
        cd -- "$target" && pwd
    elif [ -f "$target" ]; then
        local dir=$(dirname -- "$target")
        local base=$(basename -- "$target")
        echo "$(cd -- "$dir" && pwd)/$base"
    else
        echo "Error: '$target' does not exist" >&2
        return 1
    fi
}
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
