go_up() {
    [ "$path" != "/" ] && path=$(dirname "$path")
}
