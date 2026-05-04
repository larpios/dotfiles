#!/usr/bin/env bash

__COMPLETION_DIR=""

if [ "$CURRENT_SHELL" = "bash" ] && [ "$BASH_COMPLETION_USER_DIR" != "" ]; then
    __COMPLETION_DIR="$(echo "$BASH_COMPLETION_USER_DIR" | cut -d , -f 1)"
elif [ "$CURRENT_SHELL" = "zsh" ]; then
    __COMPLETION_DIR="$HOME/.config/zsh/completions"
fi

if is_exe zoxide; then
    # Disable warning for not doing initialzing zoxide at the end of the rc file.
    export _ZO_DOCTOR=0
    eval "$(zoxide init "$CURRENT_SHELL")"
fi

if is_exe starship; then
    eval "$(starship init "$CURRENT_SHELL")"
fi

if is_exe fzf; then
    eval "$(fzf "--${CURRENT_SHELL}")"
fi

if is_exe yazi; then
    # yazi wrapper for changing current working directory
    y() {
        tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ "$cwd" != "" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd" || {
                unset tmp
                return 1
            }
        fi
        unset cwd

        rm -f -- "$tmp"
        unset tmp
    }
fi

if [ "$__COMPLETION_DIR" != "" ]; then
    mkdir -p "$__COMPLETION_DIR"

    if is_exe chezmoi; then
        chezmoi completion "$CURRENT_SHELL" >"$__COMPLETION_DIR/_chezmoi"
    fi

    if is_exe bat; then
        export BAT_THEME='Catppuccin Mocha'
        bat --completion "$CURRENT_SHELL" >"$__COMPLETION_DIR/_bat"
    fi

    if is_exe jj; then
        jj util completion "$CURRENT_SHELL" >"$__COMPLETION_DIR/_jj"
    fi

    if is_exe himalaya; then
        himalaya completion "$CURRENT_SHELL" >"$__COMPLETION_DIR/_himalaya"
    fi
fi

unset __COMPLETION_DIR
