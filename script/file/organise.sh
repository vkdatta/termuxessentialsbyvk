get_top_level_files() {
    local p="$1"
    local -a fl=()
    for f in "$p"/*; do
        [ -f "$f" ] && fl+=("$f")
    done
    echo "${fl[@]}"
}

get_min_max_year() {
    local p="$1"
    local min_y=99999 max_y=0
    local -a files
    read -ra files <<< "$(get_top_level_files "$p")"
    for f in "${files[@]}"; do
        local y=$(get_year "$f")
        (( y < min_y )) && min_y=$y
        (( y > max_y )) && max_y=$y
    done
    echo "$min_y $max_y"
}

get_mtime() {
    stat -c %Y "$1" 2>/dev/null || echo 0
}

get_year() {
    local ts=$(get_mtime "$1")
    date -d "@$ts" +%Y 2>/dev/null || echo 0
}

get_month_num() {
    local ts=$(get_mtime "$1")
    date -d "@$ts" +%m 2>/dev/null || echo 0
}

get_day() {
    local ts=$(get_mtime "$1")
    date -d "@$ts" +%d 2>/dev/null || echo 0
}

get_month_name() {
    local ts=$(get_mtime "$1")
    date -d "@$ts" +%b | tr '[:upper:]' '[:lower:]' 2>/dev/null || echo "unknown"
}

organise_by_ext() {
    echo "📁 Organise by extension:"
    echo "1) All files by ext"
    echo "2) Selected extension"
    read -p "Choice: " ech
    local -a files
    read -ra files <<< "$(get_top_level_files "$path")"
    [ ${#files[@]} -eq 0 ] && { echo "No files"; return; }

    case "$ech" in
        1)
            declare -A exts
            for f in "${files[@]}"; do
                local b=$(basename "$f")
                local e="${b##*.}"
                [ "$e" = "$b" ] && e="noext"
                exts["$e"]=1
            done
            for e in "${!exts[@]}"; do
                local folder="$path/...$e"
                mkdir -p "$folder"
                if [ "$e" = "noext" ]; then
                    for f in "${files[@]}"; do
                        [[ "$(basename "$f")" != *.* ]] && mv -v "$f" "$folder/"
                    done
                else
                    for f in "$path"/*."$e"; do [ -f "$f" ] && mv -v "$f" "$folder/"; done
                fi
            done
            ;;
        2)
            read -p "Extension (e.g. py or .py): " inputext
            local ext="${inputext#.}"
            [ -z "$ext" ] && ext="noext"
            local folder="$path/...$ext"
            mkdir -p "$folder"
            if [ "$ext" = "noext" ]; then
                for f in "${files[@]}"; do
                    [[ "$(basename "$f")" != *.* ]] && mv -v "$f" "$folder/"
                done
            else
                for f in "$path"/*."$ext"; do [ -f "$f" ] && mv -v "$f" "$folder/"; done
            fi
            ;;
    esac
    echo "✅ Organised by extension"
}

organise_by_year() {
    local min_max=($(get_min_max_year "$path"))
    local min_y=${min_max[0]} max_y=${min_max[1]}
    local -a files
    read -ra files <<< "$(get_top_level_files "$path")"
    [ ${#files[@]} -eq 0 ] && { echo "No files"; return; }

    read -p "Number of years to group (1 = each year separate): " group_y
    [[ $group_y =~ ^[0-9]+$ ]] || group_y=1

    for f in "${files[@]}"; do
        local y=$(get_year "$f")
        if [ "$group_y" -eq 1 ]; then
            local gname="...$y"
            mkdir -p "$path/$gname"
            mv -v "$f" "$path/$gname/"
        else
            local offset=$(( y - min_y ))
            local gstart=$(( min_y + (offset / group_y) * group_y ))
            local gend=$(( gstart + group_y - 1 ))
            [ $gend -gt $max_y ] && gend=$max_y
            local gname="...${gstart}-${gend}"
            local sub="...$y"
            mkdir -p "$path/$gname/$sub"
            mv -v "$f" "$path/$gname/$sub/"
        fi
    done
    echo "✅ Organised by year(s)"
}

organise_by_year_month() {
    local min_max=($(get_min_max_year "$path"))
    local min_y=${min_max[0]} max_y=${min_max[1]}
    local -a files
    read -ra files <<< "$(get_top_level_files "$path")"
    [ ${#files[@]} -eq 0 ] && { echo "No files"; return; }

    read -p "Number of years to group: " group_y
    [[ $group_y =~ ^[0-9]+$ ]] || group_y=1
    read -p "Number of months to group: " group_m
    [[ $group_m =~ ^[0-9]+$ ]] || group_m=1
    local -a month_abbr=(jan feb mar apr may jun jul aug sep oct nov dec)

    for f in "${files[@]}"; do
        local y=$(get_year "$f")
        local mnum=$(get_month_num "$f")
        local m_idx=$((10#$mnum - 1))
        local monthname="${month_abbr[$m_idx]}"

        # Year level
        if [ "$group_y" -eq 1 ]; then
            local year_leaf="$path/...$y"
        else
            local offset=$(( y - min_y ))
            local gstart=$(( min_y + (offset / group_y) * group_y ))
            local gend=$(( gstart + group_y - 1 ))
            [ $gend -gt $max_y ] && gend=$max_y
            local year_group="...${gstart}-${gend}"
            local year_sub="...$y"
            local year_leaf="$path/$year_group/$year_sub"
        fi
        mkdir -p "$year_leaf"

        # Month level
        if [ "$group_m" -eq 1 ]; then
            local mgname="...$monthname"
            local mleaf="$year_leaf/$mgname"
        else
            local mgroup_idx=$(( (10#$mnum -1) / group_m ))
            local mstart=$(( mgroup_idx * group_m + 1 ))
            local mend=$(( mstart + group_m - 1 ))
            [ $mend -gt 12 ] && mend=12
            local mstart_name="${month_abbr[$((mstart-1))]}"
            local mend_name="${month_abbr[$((mend-1))]}"
            local mgname="...${mstart_name}-${mend_name}"
            local msub="...$monthname"
            local mleaf="$year_leaf/$mgname/$msub"
        fi
        mkdir -p "$mleaf"
        mv -v "$f" "$mleaf/"
    done
    echo "✅ Organised by year(s) > month(s)"
}

organise_by_year_month_date() {
    local min_max=($(get_min_max_year "$path"))
    local min_y=${min_max[0]} max_y=${min_max[1]}
    local -a files
    read -ra files <<< "$(get_top_level_files "$path")"
    [ ${#files[@]} -eq 0 ] && { echo "No files"; return; }

    read -p "Number of years to group: " group_y
    [[ $group_y =~ ^[0-9]+$ ]] || group_y=1
    read -p "Number of months to group: " group_m
    [[ $group_m =~ ^[0-9]+$ ]] || group_m=1
    read -p "Number of days to group: " group_d
    [[ $group_d =~ ^[0-9]+$ ]] || group_d=1
    local -a month_abbr=(jan feb mar apr may jun jul aug sep oct nov dec)

    for f in "${files[@]}"; do
        local y=$(get_year "$f")
        local mnum=$(get_month_num "$f")
        local m_idx=$((10#$mnum - 1))
        local monthname="${month_abbr[$m_idx]}"
        local dnum_clean=$((10#$(get_day "$f")))

        # Year level
        if [ "$group_y" -eq 1 ]; then
            local year_leaf="$path/...$y"
        else
            local offset=$(( y - min_y ))
            local gstart=$(( min_y + (offset / group_y) * group_y ))
            local gend=$(( gstart + group_y - 1 ))
            [ $gend -gt $max_y ] && gend=$max_y
            local year_group="...${gstart}-${gend}"
            local year_sub="...$y"
            local year_leaf="$path/$year_group/$year_sub"
        fi
        mkdir -p "$year_leaf"

        # Month level
        if [ "$group_m" -eq 1 ]; then
            local mgname="...$monthname"
            local mleaf="$year_leaf/$mgname"
        else
            local mgroup_idx=$(( (10#$mnum -1) / group_m ))
            local mstart=$(( mgroup_idx * group_m + 1 ))
            local mend=$(( mstart + group_m - 1 ))
            [ $mend -gt 12 ] && mend=12
            local mstart_name="${month_abbr[$((mstart-1))]}"
            local mend_name="${month_abbr[$((mend-1))]}"
            local mgname="...${mstart_name}-${mend_name}"
            local msub="...$monthname"
            local mleaf="$year_leaf/$mgname/$msub"
        fi
        mkdir -p "$mleaf"

        # Date level
        if [ "$group_d" -eq 1 ]; then
            local dgname="...$dnum_clean"
            local final_path="$mleaf/$dgname"
        else
            local dgroup_idx=$(( (dnum_clean - 1) / group_d ))
            local dstart=$(( dgroup_idx * group_d + 1 ))
            local dend=$(( dstart + group_d - 1 ))
            [ $dend -gt 31 ] && dend=31
            local dgname="...${dstart}-${dend}"
            local dsub="...$dnum_clean"
            local final_path="$mleaf/$dgname/$dsub"
        fi
        mkdir -p "$final_path"
        mv -v "$f" "$final_path/"
    done
    echo "✅ Organised by year(s) > month(s) > date(s)"
}

unorganise() {
    echo "🔄 Unorganise and bring to current location:"
    echo "1) Unorganise all"
    echo "2) Unorganise selected folders"
    read -p "Choice: " uch

    if [ "$uch" = "1" ]; then
        echo "Flattening all subfolders recursively..."
        find "$path" -mindepth 2 -type f -exec mv -v {} "$path/" \;
        find "$path" -type d -empty -delete
        echo "✅ All files brought to current location. Empty folders removed."
    else
        if select_items_common "UNORGANISE (folders only)"; then
            for dir in "${selected_items[@]}"; do
                [ -d "$dir" ] || continue
                echo "Unorganising $dir..."
                find "$dir" -type f -exec mv -v {} "$path/" \;
                find "$dir" -type d -empty -delete
            done
        fi
    fi
}

organise_menu() {
    echo "🗂️ Organise files in current location ($path):"
    echo "1) Organise by ext"
    echo "2) Organise by year(s) (metadata)"
    echo "3) Organise by year(s) > month(s) (metadata)"
    echo "4) Organise by year(s) > month(s) > date(s) (metadata)"
    echo "5) Unorganise and bring it to current location"
    read -p "Enter choice [1-5]: " och
    case "$och" in
        1) organise_by_ext ;;
        2) organise_by_year ;;
        3) organise_by_year_month ;;
        4) organise_by_year_month_date ;;
        5) unorganise ;;
        *) echo "❌ Invalid choice" ;;
    esac
}
