#!/usr/bin/env bash

C_GREEN="\033[0;32m"
C_RED="\033[0;31m"
C_GREEN="\033[0;32m"
C_YELLOW="\033[0;33m"
C_BLUE="\033[0;34m"
C_PURPLE="\033[0;35m"
C_CYAN="\033[0;36m"
C_WHITE="\033[0;37m"
C_RESET="\033[0m"

_path() {
    echo -ne "${C_GREEN}$1${2:-$C_RESET}"
}

_wrap() {
    local color="$1"
    local text="$2"
    local outer="${3:-$C_RESET}"
}

info() {
    echo -e "${C_BLUE}$*${C_RESET}"
}

warn() {
    echo -e "${C_YELLOW}$*${C_RESET}"
}

error() {
    echo -e "${C_RED}$*${C_RESET}"
}

is_exe() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

within() {
    local cwd="$1"
    local rest=${*:2}

    if [ "$cwd" = "" ]; then
        error "must specify cwd"
        return 1
    elif [ ! -d "$cwd" ]; then
        error "$(_path "$cwd" "$C_RED") is not a directory"
        return 1
    fi

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
