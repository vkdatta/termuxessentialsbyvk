initiate_copy() {
    echo "Select items to copy (enter numbers separated by ,)"
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
    echo "📦 Selected items to copy:"
    for item in "${selected_items[@]}"; do
        echo "- $(basename "$item")"
    done
    echo
    echo "Choose copy target:"
    echo "1) Local (navigate to destination folder as before)"
    echo "2) Google Drive via rclone (perform immediate rclone copy)"
    read -p "Enter choice [1-2]: " copy_choice
    case "$copy_choice" in
        1)
            original_path="$path"
            path="$HOME"
            copy_mode=true
            echo
            echo "📋 COPY MODE: Navigate to destination folder"
            echo "Press 'c' at destination to confirm copy"
            echo "Press 'b' to cancel copy operation"
            ;;
        2)
           if ! command -v rclone >/dev/null 2>&1; then
                echo "❌ rclone not found in PATH. Please install rclone and configure a remote named 'gdrive'."
                selected_items=()
                return
            fi
            remote_path="gdrive:/rclone"
            echo
            echo "📤 Starting rclone copy to: $remote_path"
            for item in "${selected_items[@]}"; do
                if [ ! -e "$item" ]; then
                    echo "❌ Item not found: $(basename "$item")"
                    continue
                fi
                base=$(basename "$item")
                echo
                echo "📤 Copying $(basename "$item") → $remote_path/$base"
                rclone copy "$item" "$remote_path/$base" --progress --metadata
                rc=$?
                if [ $rc -ne 0 ]; then
                    echo "❌ rclone failed for $(basename "$item") (exit code $rc)"
                else
                    echo "✅ rclone succeeded for $(basename "$item")"
                fi
            done
            echo
            echo "✅ All requested rclone copy operations finished."
            selected_items=()
            ;;        
        *)
            echo "❌ Invalid choice. Cancelled copy."
            selected_items=()
            ;;
    esac
}
