#!/usr/bin/env bash

is_exe() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

within() {
    local cwd="$1"
    local rest=${*:2}

    (
        cd "$cwd" || return 1
        "$rest"
    )
}

if is_exe yazi; then
    y() {
        local tmp
        tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ "$cwd" != "" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd" || return 1
        fi
        rm -f -- "$tmp"
    }
fi
