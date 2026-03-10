find_menu() {
    echo "🔍 Find mode in: $path"
    echo "1) Find file/folder names"
    echo "2) Find inside file contents"
    read -p "Choice: " ftype

    local -a results=()
    case "$ftype" in
        1)
            read -p "Name pattern (e.g. report): " pat
            mapfile -t results < <(find "$path" -name "*$pat*" 2>/dev/null | head -100)
            ;;
        2)
            read -p "Text to search inside files: " pat
            mapfile -t results < <(grep -rl "$pat" "$path" 2>/dev/null | head -100)
            ;;
        *) return ;;
    esac

    if [ ${#results[@]} -eq 0 ]; then
        echo "No results."
        return
    fi

    echo "📋 Found ${#results[@]} results:"
    for i in "${!results[@]}"; do
        local rel=$(realpath --relative-to="$path" "${results[$i]}" 2>/dev/null || basename "${results[$i]}")
        printf "%3d) %s\n" $((i+1)) "$rel"
    done

    echo "Enter item number to go"
    echo "q/h) exit"
    while true; do
        read -p "Action: " act
        case "$act" in
            q|Q|h|H) return ;;
            [0-9]*)
                local num="${act#g}"
                if [[ $num =~ ^[0-9]+$ ]] && (( num >=1 && num <= ${#results[@]} )); then
                    local target="${results[$((num-1))]}"
                    if [ -d "$target" ]; then
                        path="$target"
                    elif [ -f "$target" ]; then
                        handle_file "$target"
                    fi
                    return
                fi
                ;;
            *) echo "Invalid. Use g<number> or q" ;;
        esac
    done
}
