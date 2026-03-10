rename_item() {
    local target="$1"
    local dir newname
    if [ -d "$target" ]; then
        dir=$(dirname -- "$target")
        read -p "📝 Enter new folder name for '$(basename "$target")': " newname
        mv -v "$target" "$dir/$newname"
    elif [ -f "$target" ]; then
        dir=$(dirname -- "$target")
        read -p "📝 Enter new file name for '$(basename "$target")': " newname
        mv -v "$target" "$dir/$newname"
    else
        echo "❌ Cannot rename: '$target' not found." >&2
        return 1
    fi
}
