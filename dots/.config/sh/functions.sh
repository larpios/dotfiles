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

info() {
    printf "%b\n" "${C_BLUE}[info] $*${C_RESET}"
}

warn() {
    printf "%b\n" "${C_YELLOW}[warn] $*${C_RESET}"
}

error() {
    printf "%b\n" "${C_RED}[error] $*${C_RESET}" >&2
}

is_exe() (
    cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
)

within() (
    cwd="$1"
    shift

    if [ "$cwd" = "" ]; then
        error "must specify cwd"
        return 1
    elif [ ! -d "$cwd" ]; then
        error "$("$C_GREEN" "\`$cwd\`" "$C_RED") is not a directory"
        return 1
    fi

    cd "$cwd" || return 1
    "$@"
)

path_append() {
    __add_to_path "append" "$@"
}

path_prepend() {
    __add_to_path "prepend" "$@"
}

__add_to_path() {
    __mode="$1"
    if [ "$__mode" = "" ]; then
        error "Must specify \`mode\`"
        return 1
    elif [ "$__mode" != "prepend" ] && [ "$__mode" != "append" ]; then
        error "Must specify \`mode\` as \`prepend\` or \`append\`"
        unset __mode
        return 1
    fi

    shift 1

    for p in "$@"; do
        case ":$PATH:" in
        *":$p:"*) continue ;;
        esac
        if [ "$PATH" = "" ]; then
            PATH=$p
        else
            if [ "$__mode" = "prepend" ]; then
                PATH=$p:$PATH
            else
                PATH=$PATH:$p
            fi
        fi
    done
    unset __mode

    export PATH
}

__cleanup() {
    unset C_GREEN C_RED C_GREEN C_YELLOW C_BLUE C_PURPLE C_CYAN C_WHITE C_RESET

    unset -f "${FUNCNAME:-__cleanup}"
}

__cleanup
