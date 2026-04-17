if not type -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
end

function __install_plugins
    set -l urls $argv

    set list (fisher list)
    for url in $urls
        if string match -r $url $list >/dev/null
            continue
        end
        fisher install $url
    end
end

set -l plugins \
    nickeb96/puffer-fish \
    catppuccin/fish 

__install_plugins $plugins

fish_config theme choose catppuccin-frappe --color-theme=dark
