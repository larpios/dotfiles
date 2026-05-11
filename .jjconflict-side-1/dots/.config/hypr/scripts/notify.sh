#!/usr/bin/env bash

notify() {
    local message=$1
    hyprctl notify -1 3000 "rgb(c6a0f6)" "fontsize:20 $message"
}

notify "$@"
