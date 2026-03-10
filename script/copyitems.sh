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
