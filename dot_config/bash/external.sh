#!/usr/bin/env bash

if is_exe zoxide; then
    eval "$(zoxide init bash)"
fi

if is_exe starship; then
    eval "$(starship init bash)"
fi

if is_exe bat; then
    eval "$(bat --theme catppuccin --completion bash)"
fi

if is_exe jj; then
    eval "$(jj util completion bash)"
fi

if is_exe fzf; then
    eval "$(fzf --bash)"
fi

