#!/usr/bin/env bash

if ! [ -x "$HOME/.cargo/bin/sketchybarrc" ]; then
    cargo install --git https://github.com/larpios/sketchybar-config
fi

"$HOME/.cargo/bin/sketchybarrc"
