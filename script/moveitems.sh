move_items() {
    echo "Select items to move (enter numbers separated by ,)"
    read -p "Item numbers: " itemlist
    IFS=',' read -ra indices <<< "$itemlist"
    selected_items=()
    for index in "${indices[@]}"; do
        if [[ $index =~ ^[0-9]+$ ]] && [ $index -ge 1 ] && [ $index -le ${#items[@]} ]; then
            selected_items+=("${items[$((index-1))]}")
        else
            echo "❌ Skipping invalid index: $index"
        fi
    done
    if [ ${#selected_items[@]} -eq 0 ]; then
        echo "❌ No valid items selected"
        return
    fi
    echo
    echo "📦 Selected items:"
    for item in "${selected_items[@]}"; do
        echo "- $(basename "$item")"
    done
    original_path="$path"
    path="$HOME"
    move_mode=true
    echo
    echo "🌍 Navigate to destination folder (select folder or use commands)"
    echo "Press 'c' at destination to confirm move"
    echo "Press 'b' to cancel move operation"
}
