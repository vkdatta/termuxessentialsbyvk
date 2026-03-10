determine_shared_dir() {
    if [ -d "$HOME/storage/shared" ]; then
        echo "$HOME/storage/shared/Download"
    else
        echo "/sdcard/Download"
    fi
}

force_open() {
    local src="$1"
    if [ ! -e "$src" ]; then
        echo "❌ File not found: $src"
        return 1
    fi
    local shared_dir
    shared_dir="$(determine_shared_dir)"
    mkdir -p "$shared_dir"
    local base ts dest
    base=$(basename "$src")
    ts=$(date +%s)
    dest="$shared_dir/${ts}_$base"
    cp -f -- "$src" "$dest" || { echo "❌ Failed to copy to shared storage"; return 1; }
    if command -v termux-open >/dev/null 2>&1; then
        termux-open "$dest" && return 0
    fi
    if command -v am >/dev/null 2>&1; then
        local mime
        if command -v file >/dev/null 2>&1; then
            mime=$(file --mime-type -b "$dest" 2>/dev/null || echo "application/octet-stream")
        else
            mime="application/octet-stream"
        fi
        am start -a android.intent.action.VIEW -d "file://$dest" -t "$mime" >/dev/null 2>&1 || echo "⚠️ Open via am failed"
        return 0
    fi
    echo "❌ No suitable open method available"
    return 1
}
