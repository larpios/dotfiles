#!/usr/bin/env sh

if is_exe chezmoi; then
    if [ "$CURRENT_SHELL" = "bash" ]; then
        eval "$(chezmoi completion "$CURRENT_SHELL")"
    elif [ "$CURRENT_SHELL" = "zsh" ]; then
        chezmoi completion "$CURRENT_SHELL" >~/.config/zsh/completions/_chezmoi
    fi
fi

if is_exe zoxide; then
    # Disable warning for not doing initialzing zoxide at the end of the rc file.
    export _ZO_DOCTOR=0
    eval "$(zoxide init "$CURRENT_SHELL")"
fi

if is_exe starship; then
    eval "$(starship init "$CURRENT_SHELL")"
fi

if is_exe bat; then
    export BAT_THEME='Catppuccin Mocha'
    if [ "$CURRENT_SHELL" = "bash" ]; then
        eval "$(bat --completion "$CURRENT_SHELL")"
    elif [ "$CURRENT_SHELL" = "zsh" ]; then
        bat --completion "$CURRENT_SHELL" >~/.config/zsh/completions/_bat
    fi
fi

if is_exe jj; then
    if [ "$CURRENT_SHELL" = "bash" ]; then
        eval "$(jj util completion "$CURRENT_SHELL")"
    elif [ "$CURRENT_SHELL" = "zsh" ]; then
        jj util completion "$CURRENT_SHELL" >~/.config/zsh/completions/_jj
    fi
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
