#!/usr/bin/env bash

if is_exe zoxide; then
    eval "$(zoxide init bash)"
fi

if is_exe starship; then
    eval "$(starship init bash)"
fi

if is_exe atuin; then
    eval "$(atuin init bash)"
fi
