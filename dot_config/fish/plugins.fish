if not type -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source 
    fisher install jorgebucaran/fisher
end

function __install_plugin -a url
    if fisher list | string match -r $url >/dev/null
        return
    end
    fisher install $url
end

__install_plugin nickeb96/puffer-fish
