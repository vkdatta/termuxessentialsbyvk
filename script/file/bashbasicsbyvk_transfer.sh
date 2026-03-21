_view_selections_menu() {
  local -n _sel_ref="$1"

  while true; do
    echo
    if [ ${#_sel_ref[@]} -eq 0 ]; then
      echo "📋 No items selected yet."
    else
      echo "📋 Current selections (${#_sel_ref[@]}):"
      local i=1
      for s in "${_sel_ref[@]}"; do
        printf "  %2d) %s\n" "$i" "$(basename "$s")"
        i=$((i+1))
      done
    fi
    echo
    echo "c) Confirm selections   r) Remove items   q) Quit"
    read -p "Selection view: " sv_choice

    case "$sv_choice" in
      c|C)
        if [ ${#_sel_ref[@]} -eq 0 ]; then
          echo "⚠️  Nothing selected — add items before confirming."
        else
          echo "✅ Selections confirmed (${#_sel_ref[@]} item(s))"
          return 0
        fi
        ;;
      r|R)
        if [ ${#_sel_ref[@]} -eq 0 ]; then
          echo "⚠️  Nothing to remove."
          continue
        fi
        echo "Enter item number(s) to remove (e.g. 1,3 or 2-5):"
        read -p "Remove: " rm_input
        local rm_indices
        rm_indices=($(parse_selection "$rm_input" "${#_sel_ref[@]}"))
        if [ ${#rm_indices[@]} -eq 0 ]; then
          echo "❌ No valid numbers entered"
          continue
        fi
        # Build set of 1-based indices to remove
        local -A _to_remove=()
        for ri in "${rm_indices[@]}"; do
          _to_remove["$ri"]=1
        done
        local new_sel=()
        local j=1
        for s in "${_sel_ref[@]}"; do
          [ -z "${_to_remove[$j]+x}" ] && new_sel+=("$s")
          j=$((j+1))
        done
        _sel_ref=("${new_sel[@]}")
        echo "✅ Removed ${#rm_indices[@]} item(s). Remaining: ${#_sel_ref[@]}"
        ;;
      q|Q)
        exit 0
        ;;
      *)
        echo "⚠️  Invalid choice"
        ;;
    esac
  done
}

local_navigator() {
  local mode="$1"
  local start_path="${2:-$HOME}"
  local nav_path="$start_path"
  local nav_prefix=""
  local nav_force_show=false
  nav_result_path=""
  nav_selected_items=()

  while true; do
    echo
    if [ "$mode" == "source" ]; then
      echo "📂 SELECT SOURCE — Location: $nav_path${nav_prefix:+ [filter: ${nav_prefix^^}*]}"
    else
      echo "📂 SELECT DESTINATION — Location: $nav_path${nav_prefix:+ [filter: ${nav_prefix^^}*]}"
    fi

    local nav_total
    nav_total=$(count_items_in_path "$nav_path")
    local nav_imaginary=false
    local nav_items=()

    if [ "$nav_total" -gt "${index_mode_threshold:-200}" ] && ! $nav_force_show; then
      nav_imaginary=true
      if [ -n "$nav_prefix" ]; then
        local local_arr=()
        while IFS= read -r -d '' _f; do
          _bn="${_f##*/}"
          [[ "$_bn" == "." || "$_bn" == ".." ]] && continue
          ! $show_hidden_files && [[ "$_bn" == .* ]] && continue
          [[ "${_bn,,}" != "$nav_prefix"* ]] && continue
          local_arr+=("$_f")
        done < <(find "$nav_path" -maxdepth 1 -mindepth 1 -print0 2>/dev/null)
        local pfx_count="${#local_arr[@]}"
        if [ "$pfx_count" -le "${index_mode_threshold:-200}" ]; then
          nav_imaginary=false
          nav_items=("${local_arr[@]}")
        else
          display_imaginary_groups "$nav_path" "$nav_prefix" "$pfx_count"
        fi
      else
        display_imaginary_groups "$nav_path" "" "$nav_total"
      fi
    fi

    if ! $nav_imaginary; then
      if [ ${#nav_items[@]} -eq 0 ] && [ -n "$nav_prefix" ]; then
        build_items_for_prefix "$nav_path" "$nav_prefix"
        nav_items=("${items[@]}")
      elif [ ${#nav_items[@]} -eq 0 ]; then
        build_all_items "$nav_path"
        nav_items=("${items[@]}")
      fi
      if [ ${#nav_items[@]} -eq 0 ]; then
        echo "🛑 This directory is empty"
      else
        local idx=1
        for item in "${nav_items[@]}"; do
          [ -d "$item" ] && icon="📁" || icon="📄"
          printf "%2d) %s %s\n" "$idx" "$icon" "$(basename "$item")"
          idx=$((idx+1))
        done
      fi
    fi

    echo
    if [ "$mode" == "source" ]; then
      echo "Enter number(s) to add to selection (supports ranges: 1-3,5)"
      echo "u) Up   v) View selections   x) Cancel   q) Quit"
    else
      echo "Enter number to enter a subfolder"
      echo "u) Up   n) New folder   c) Confirm destination   x) Cancel   q) Quit"
    fi

    read -p "Nav: " nav_choice

    case "$nav_choice" in
      q|Q)
        exit 0
        ;;
      x|X)
        echo "🚫 Navigation cancelled"
        return 1
        ;;
      u|U)
        if [ "$nav_path" != "/" ]; then
          nav_path=$(dirname "$nav_path")
          nav_prefix=""
          nav_force_show=false
        fi
        ;;
      n|N)
        if [ "$mode" == "dest" ]; then
          read -p "📂 New folder name: " new_dir_name
          if [ -n "$new_dir_name" ]; then
            mkdir -p "$nav_path/$new_dir_name"
            echo "✅ Created: $nav_path/$new_dir_name"
            nav_path="$nav_path/$new_dir_name"
          fi
        else
          echo "⚠️  Invalid choice"
        fi
        ;;
      v|V)
        if [ "$mode" == "source" ]; then
          _view_selections_menu nav_selected_items
          [ $? -eq 0 ] && return 0
        else
          echo "⚠️  Invalid choice"
        fi
        ;;
      c|C)
        if [ "$mode" == "dest" ]; then
          nav_result_path="$nav_path"
          echo "✅ Destination confirmed: $nav_result_path"
          return 0
        else
          echo "⚠️  Use v) to view and confirm your selections"
        fi
        ;;
      *)
        if $nav_imaginary; then
          local matched=false
          local ch=""
          if [[ "$nav_choice" =~ ^[0-9]+$ ]] && [ "$nav_choice" -ge 1 ] && [ "$nav_choice" -le "${#imaginary_map[@]}" ]; then
            ch="${imaginary_map[$((nav_choice-1))]}"
            matched=true
          elif [[ ${#nav_choice} -eq 1 ]]; then
            ch="${nav_choice^^}"
            for gc in "${group_chars[@]}"; do
              [[ "$gc" == "$ch" ]] && matched=true && break
            done
            [[ "$matched" == false && "$nav_choice" == "#" ]] && ch="#" && matched=true
          fi
          if $matched; then
            [ "$ch" == "#" ] && nav_prefix="${nav_prefix}#" || nav_prefix="${nav_prefix}${ch,,}"
            nav_force_show=false
          else
            echo "⚠️  Invalid selection"
          fi
        else
          if [[ "$nav_choice" =~ ^[0-9,\-]+$ ]]; then
            if [ "$mode" == "source" ]; then
              local indices
              indices=($(parse_selection "$nav_choice" "${#nav_items[@]}"))
              if [ ${#indices[@]} -eq 0 ]; then
                echo "⚠️  No valid numbers"
              else
                for idx in "${indices[@]}"; do
                  nav_selected_items+=("${nav_items[$((idx-1))]}")
                done
                echo "➕ Added ${#indices[@]} item(s) — total selected: ${#nav_selected_items[@]}  (v to review)"
              fi
            else
              if [[ "$nav_choice" =~ ^[0-9]+$ ]] && [ "$nav_choice" -ge 1 ] && [ "$nav_choice" -le "${#nav_items[@]}" ]; then
                local sel="${nav_items[$((nav_choice-1))]}"
                if [ -d "$sel" ]; then
                  nav_path="$sel"
                  nav_prefix=""
                  nav_force_show=false
                else
                  echo "⚠️  Select a folder (📁) to navigate into, or c) to confirm this location"
                fi
              else
                echo "⚠️  Invalid selection"
              fi
            fi
          else
            echo "⚠️  Invalid selection"
          fi
        fi
        ;;
    esac
  done
}

gcloud_navigator() {
  local mode="$1"
  gcloud_nav_result_path=""
  gcloud_nav_selected_items=()

  local remote_path
  remote_path=$(gcloud cloud-shell ssh --authorize-session --command "echo \$HOME" 2>/dev/null | tail -1)
  [ -z "$remote_path" ] && remote_path="$HOME"

  while true; do
    echo
    if [ "$mode" == "source" ]; then
      echo "☁️  GCLOUD SOURCE — Location: $remote_path"
    else
      echo "☁️  GCLOUD DESTINATION — Location: $remote_path"
    fi

    local listing
    listing=$(gcloud cloud-shell ssh --authorize-session --command \
      "ls -1Ap '$remote_path' 2>/dev/null" 2>/dev/null)

    local -a remote_items=()
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      remote_items+=("$line")
    done <<< "$listing"

    if [ ${#remote_items[@]} -eq 0 ]; then
      echo "🛑 Remote directory is empty or inaccessible"
    else
      local idx=1
      for item in "${remote_items[@]}"; do
        if [[ "$item" == */ ]]; then
          printf "%2d) 📁 %s\n" "$idx" "${item%/}"
        else
          printf "%2d) 📄 %s\n" "$idx" "$item"
        fi
        idx=$((idx+1))
      done
    fi

    echo
    if [ "$mode" == "source" ]; then
      echo "Enter number(s) to add to selection (supports ranges: 1-3,5)"
      echo "u) Up   v) View selections   x) Cancel   q) Quit"
    else
      echo "Enter number to enter a subfolder"
      echo "u) Up   n) New folder   c) Confirm destination   x) Cancel   q) Quit"
    fi

    read -p "GCloud Nav: " gnav_choice

    case "$gnav_choice" in
      q|Q)
        exit 0
        ;;
      x|X)
        echo "🚫 GCloud navigation cancelled"
        return 1
        ;;
      u|U)
        remote_path=$(dirname "$remote_path")
        ;;
      n|N)
        if [ "$mode" == "dest" ]; then
          read -p "📂 New remote folder name: " new_rdir
          if [ -n "$new_rdir" ]; then
            gcloud cloud-shell ssh --authorize-session --command \
              "mkdir -p '$remote_path/$new_rdir'" 2>/dev/null
            echo "✅ Created remote: $remote_path/$new_rdir"
            remote_path="$remote_path/$new_rdir"
          fi
        else
          echo "⚠️  Invalid choice"
        fi
        ;;
      v|V)
        if [ "$mode" == "source" ]; then
          _view_selections_menu gcloud_nav_selected_items
          [ $? -eq 0 ] && return 0
        else
          echo "⚠️  Invalid choice"
        fi
        ;;
      c|C)
        if [ "$mode" == "dest" ]; then
          gcloud_nav_result_path="$remote_path"
          echo "✅ GCloud destination confirmed: $gcloud_nav_result_path"
          return 0
        else
          echo "⚠️  Use v) to view and confirm your selections"
        fi
        ;;
      *)
        if [[ "$gnav_choice" =~ ^[0-9,\-]+$ ]]; then
          if [ "$mode" == "source" ]; then
            local indices
            indices=($(parse_selection "$gnav_choice" "${#remote_items[@]}"))
            if [ ${#indices[@]} -eq 0 ]; then
              echo "⚠️  No valid numbers"
            else
              for idx in "${indices[@]}"; do
                local chosen="${remote_items[$((idx-1))]}"
                gcloud_nav_selected_items+=("$remote_path/${chosen%/}")
              done
              echo "➕ Added ${#indices[@]} item(s) — total selected: ${#gcloud_nav_selected_items[@]}  (v to review)"
            fi
          else
            if [[ "$gnav_choice" =~ ^[0-9]+$ ]] && [ "$gnav_choice" -ge 1 ] && [ "$gnav_choice" -le "${#remote_items[@]}" ]; then
              local sel="${remote_items[$((gnav_choice-1))]}"
              if [[ "$sel" == */ ]]; then
                remote_path="$remote_path/${sel%/}"
              else
                echo "⚠️  Select a folder (📁) to navigate into, or c) to confirm this location"
              fi
            else
              echo "⚠️  Invalid selection"
            fi
          fi
        else
          echo "⚠️  Invalid input"
        fi
        ;;
    esac
  done
}

perform_copy() {
  local dest="$1"
  shift
  local src_items=("$@")
  for item in "${src_items[@]}"; do
    [ ! -e "$item" ] && continue
    local base name ext count newbase
    base=$(basename -- "$item")
    name="${base%.*}"
    ext="${base##*.}"
    [[ "$base" == "$ext" ]] && ext=""
    count=1
    newbase="$base"
    while [ -e "$dest/$newbase" ]; do
      if [ -n "$ext" ]; then
        newbase="${name}${count}.${ext}"
      else
        newbase="${name}${count}"
      fi
      count=$((count+1))
    done
    cp -r -- "$item" "$dest/$newbase"
    echo "  ✅ Copied: $(basename "$item") → $dest/$newbase"
  done
}

perform_move() {
  local dest="$1"
  shift
  local src_items=("$@")
  for item in "${src_items[@]}"; do
    [ ! -e "$item" ] && continue
    mv -- "$item" "$dest/"
    echo "  ✅ Moved: $(basename "$item") → $dest/"
  done
}

transfer_menu() {

  echo
  echo "📦 TRANSFER — Step 1: Choose mode"
  echo "1) Intra-location  (local → local)"
  echo "2) To Drive        (local → Google Drive via rclone)"
  echo "3) To GCloud       (local → GCloud Shell)"
  echo "4) To Local        (GCloud Shell → local)"
  read -p "Mode [1-4]: " t_mode

  case "$t_mode" in
    1|2|3|4) ;;
    *)
      echo "❌ Invalid mode"
      return
      ;;
  esac

  echo
  echo "📦 TRANSFER — Step 2: Select source items"

  local step2_ok=false

  if [ "$t_mode" == "4" ]; then
    if ! command -v gcloud >/dev/null 2>&1; then
      echo "❌ gcloud not found in PATH."
      return
    fi
    echo "☁️  Establishing GCloud SSH for source navigation..."
    gcloud cloud-shell ssh --authorize-session --command "echo '✅ SSH ready'" 2>/dev/null
    gcloud_navigator "source"
    if [ $? -ne 0 ] || [ ${#gcloud_nav_selected_items[@]} -eq 0 ]; then
      echo "🚫 Transfer cancelled"
      return
    fi
    step2_ok=true
  else
    if $imaginary_mode; then
      select_imaginary_items_common "$path" "$group_prefix" && step2_ok=true
    else
      local_navigator "source" "$path"
      if [ $? -eq 0 ] && [ ${#nav_selected_items[@]} -gt 0 ]; then
        selected_items=("${nav_selected_items[@]}")
        step2_ok=true
      fi
    fi
  fi

  if ! $step2_ok; then
    echo "🚫 Transfer cancelled — no items selected"
    return
  fi

  echo
  echo "📦 TRANSFER — Step 3: Choose destination"

  local dest_ok=false
  local final_dest=""

  case "$t_mode" in
    1)
      local_navigator "dest" "$HOME"
      if [ $? -eq 0 ]; then
        final_dest="$nav_result_path"
        dest_ok=true
      fi
      ;;
    2)
      if ! command -v rclone >/dev/null 2>&1; then
        echo "❌ rclone not found in PATH."
        return
      fi
      final_dest="gdrive:/rclone"
      echo "📍 Destination: Google Drive ($final_dest)"
      dest_ok=true
      ;;
    3)
      if ! command -v gcloud >/dev/null 2>&1; then
        echo "❌ gcloud not found in PATH."
        return
      fi
      echo "☁️  Navigating GCloud for destination..."
      gcloud_navigator "dest"
      if [ $? -eq 0 ]; then
        final_dest="$gcloud_nav_result_path"
        dest_ok=true
      fi
      ;;
    4)
      local_navigator "dest" "$HOME"
      if [ $? -eq 0 ]; then
        final_dest="$nav_result_path"
        dest_ok=true
      fi
      ;;
  esac

  if ! $dest_ok || [ -z "$final_dest" ]; then
    echo "🚫 Transfer cancelled — no destination chosen"
    return
  fi

  echo
  echo "📦 TRANSFER — Step 4: Action"
  echo "c) Copy   m) Move"
  read -p "Action: " t_action

  local t_op
  case "$t_action" in
    c|C) t_op="copy" ;;
    m|M) t_op="move" ;;
    *)
      echo "❌ Invalid action. Transfer cancelled."
      return
      ;;
  esac

  echo
  echo "⚙️  Executing $t_op..."

  case "$t_mode" in
    1)
      if [ "$t_op" == "copy" ]; then
        perform_copy "$final_dest" "${selected_items[@]}"
        echo "✅ Copy complete → $final_dest"
      else
        perform_move "$final_dest" "${selected_items[@]}"
        echo "✅ Move complete → $final_dest"
      fi
      ;;
    2)
      for item in "${selected_items[@]}"; do
        local base
        base=$(basename "$item")
        if [ "$t_op" == "copy" ]; then
          echo "📤 rclone copy: $base → $final_dest/$base"
          rclone copy "$item" "$final_dest/$base" --progress --metadata
        else
          echo "📤 rclone move: $base → $final_dest/$base"
          rclone move "$item" "$final_dest/$base" --progress --metadata
        fi
      done
      echo "✅ Drive transfer complete"
      ;;
    3)
      echo "☁️  Transferring to GCloud Shell..."
      for item in "${selected_items[@]}"; do
        local base
        base=$(basename "$item")
        echo "📤 Sending $base → GCloud:$final_dest/"
        gcloud cloud-shell scp --recurse "localhost:$item" "cloudshell:$final_dest/"
        if [ $? -eq 0 ] && [ "$t_op" == "move" ]; then
          rm -rf -- "$item"
          echo "  🗑️  Removed local: $item"
        fi
      done
      echo "✅ Transfer to GCloud complete"
      ;;
    4)
      echo "☁️  Transferring from GCloud Shell to local..."
      for remote_item in "${gcloud_nav_selected_items[@]}"; do
        local base
        base=$(basename "$remote_item")
        echo "📥 Pulling $base → $final_dest/"
        gcloud cloud-shell scp --recurse "cloudshell:$remote_item" "localhost:$final_dest/"
        if [ $? -eq 0 ] && [ "$t_op" == "move" ]; then
          gcloud cloud-shell ssh --authorize-session --command "rm -rf '$remote_item'"
          echo "  🗑️  Removed from GCloud: $remote_item"
        fi
      done
      echo "✅ Transfer from GCloud complete"
      ;;
  esac

  selected_items=()
}
