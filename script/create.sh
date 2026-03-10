create_files() {
    read -p "📄 Enter filenames (separated by ,): " filelist
    IFS=',' read -ra files <<< "$filelist"
    for file in "${files[@]}"; do
        touch "$path/$file"
        echo "✅ Created file: $file"
    done
}

create_dirs() {
    read -p "📂 Enter folder names (separated by ,): " dirlist
    IFS=',' read -ra dirs <<< "$dirlist"
    for dir in "${dirs[@]}"; do
        mkdir -p "$path/$dir"
        echo "✅ Created folder: $dir"
    done
}
