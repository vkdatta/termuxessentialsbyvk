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
