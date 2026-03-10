delete_items() {
    echo "Select items to delete (enter numbers separated by ,)"
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
    echo "⚠️ WARNING: You are about to delete the following items:"
    for item in "${selected_items[@]}"; do
        echo "- $(basename "$item")"
    done
    read -p "Are you sure? This cannot be undone. (y/n): " confirm
    if [[ $confirm != "y" && $confirm != "Y" ]]; then
        echo "🚫 Deletion cancelled"
        return
    fi
    for item in "${selected_items[@]}"; do
        if [ -e "$item" ]; then
            rm -rf -- "$item"
            echo "🗑️ Deleted: $(basename "$item")"
        else
            echo "❌ Item not found: $(basename "$item")"
        fi
    done
}
