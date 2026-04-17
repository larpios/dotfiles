#!/usr/bin/env sh

alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lla='ls -la'

if is_exe eza; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza --icons --group-directories-first -l'
    alias la='eza --icons --group-directories-first -a'
    alias l='eza --icons --group-directories-first -l'
    alias lla='eza --icons --group-directories-first -la'
fi

alias v='nvim'
alias "v."='nvim .'
