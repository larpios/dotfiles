#!/usr/bin/env bash
PATH="$HOME/.nix-profile/bin:/usr/local/bin:/bin:/usr/bin:$HOME/.cargo/bin:$PATH"

REPO_URL='https://github.com/larpios/sketchybar-config'
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/sketchybar"
REPO_PATH="$DATA_DIR/sketchybar-config"
BINARY_PATH="$HOME/.cargo/bin/sketchybarrc"

# Fallback to nu
if ! command -v cargo >/dev/null 2>&1; then
    nu main.nu
    exit
fi

if [ ! -d "$DATA_DIR" ]; then
    mkdir -p "$DATA_DIR"
    git clone "$REPO_URL" "$REPO_PATH"
fi

has_update() (
    cd "$REPO_PATH" || exit 1

    old_commit=$(git rev-parse HEAD)

    git fetch
    git pull

    new_commit=$(git rev-parse HEAD)

    if [ "$old_commit" != "$new_commit" ]; then
        return 0
    else
        return 1
    fi
)

if has_update || [ ! -f "$BINARY_PATH" ]; then
    cargo install --path "$REPO_PATH"
fi

"$BINARY_PATH"
