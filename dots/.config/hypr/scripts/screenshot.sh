#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

notify() {
    "$SCRIPT_DIR/notify.sh" "$@"
}

# Ensure the screenshot directory exists
mkdir -p "$SCREENSHOT_DIR"

main() {
    local mode=$1
    local output=$2
    local dest
    dest="$SCREENSHOT_DIR/$(date +%Y-%m-%d-%H-%M-%S).png"
    local grim_args=()

    # Handle region selection
    if [ "$mode" == "region" ]; then
        local region
        # If slurp fails (e.g., user presses Escape), exit gracefully
        region=$(slurp) || {
            notify "Screenshot cancelled"
            exit 1
        }
        grim_args+=("-g" "$region")
    elif [ "$mode" = "window" ]; then
        region=$(hyprctl clients -j | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp) || {
            notify "Screenshot cancelled"
            exit 1
        }
        grim_args+=("-g" "$region")
    fi

    # Handle output routing without storing binary data in a variable
    if [ "$output" = "file" ]; then
        grim "${grim_args[@]}" "$dest"
        "$SCRIPT_DIR/notify.sh" "Screenshot saved to $dest"
    else
        # clipboard
        grim "${grim_args[@]}" - | wl-copy
        "$SCRIPT_DIR/notify.sh" "Screenshot copied to clipboard"
    fi
}

main "$@"
