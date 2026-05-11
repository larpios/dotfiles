alias ls 'ls --color=auto'
alias ll 'ls -l'
alias la 'ls -a'
alias lla 'ls -la'

if type -q eza
    set -l width (math -s0 $COLUMNS x 60 / 100)
    alias ls "eza --color=auto --icons --hyperlink --group-directories-first --width $width"
    alias ll "eza -lG --color=auto --icons --hyperlink --group-directories-first --smart-group --width $width"
    alias la "eza -a --color=auto --icons --hyperlink --group-directories-first --width $width"
    alias lla "eza -laG --color=auto --icons --hyperlink --group-directories-first --smart-group --width $width"
end

alias v nvim
alias 'v.' 'nvim .'
alias g git
