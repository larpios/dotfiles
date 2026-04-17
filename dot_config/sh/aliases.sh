#!/usr/bin/env sh

alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lla='ls -la'

if is_exe eza; then
    __width=$((COLUMNS * 60 / 100))

    alias ls="eza --icons --hyperlink --group-directories-first --width $__width"
    alias ll="eza -lG --icons --hyperlink --group-directories-first --smart-group --width $__width"
    alias la="eza -a --icons --hyperlink --group-directories-first --width $__width"
    alias l="eza -lG --icons --hyperlink --group-directories-first --smart-group --width $__width"
    alias lla="eza -laG --icons --hyperlink --group-directories-first --width $__width"

    unset __width
fi

alias v='nvim'
alias "v."='nvim .'
alias g='git'
