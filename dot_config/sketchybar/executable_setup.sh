#!/usr/bin/env bash
PATH="$HOME/.nix-profile/bin:/usr/local/bin:/bin:/usr/bin:$HOME/.cargo/bin:$PATH"

BINARY_PATH="$HOME/.cargo/bin/sketchybarrc"

if [ ! -f "$BINARY_PATH" ]; then
    cargo install --git https://github.com/larpios/sketchybar-config
fi

"$BINARY_PATH"
