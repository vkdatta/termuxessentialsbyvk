force_share() {
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
    if command -v termux-share >/dev/null 2>&1; then
        termux-share -a send -c file "$dest" 2>/dev/null || termux-share "$dest"
        return 0
    fi
    if command -v am >/dev/null 2>&1; then
        local mime
        if command -v file >/dev/null 2>&1; then
            mime=$(file --mime-type -b "$dest" 2>/dev/null || echo "application/octet-stream")
        else
            mime="application/octet-stream"
        fi
        am start -a android.intent.action.SEND -t "$mime" --es android.intent.extra.SUBJECT "$(basename "$dest")" --stream "file://$dest" >/dev/null 2>&1 2>/dev/null || {
            am start -a android.intent.action.SEND -t "$mime" --es android.intent.extra.STREAM "file://$dest" >/dev/null 2>&1 || echo "⚠️ Share via am failed"
        }
        return 0
    fi
    echo "❌ No suitable share method available"
    return 1
}
