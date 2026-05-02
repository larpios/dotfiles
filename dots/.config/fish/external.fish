if type -q chezmoi
    chezmoi completion fish --output "$__fish_config_dir/completions/chezmoi.fish"
end

if type -q zoxide
    set -gx _ZO_DOCTOR 0
    zoxide init fish | source
end

if type -q starship
    source (starship init fish --print-full-init | psub)
end

if type -q bat
    set -gx BAT_THEME 'Catppuccin Mocha'
    bat --completion fish >"$__fish_config_dir/completions/bat.fish"
end

if type -q jj
    jj util completion fish >"$__fish_config_dir/completions/jj.fish"
end

if type -q fzf
    fzf --fish | source
end

if type -q yazi
    function y -d "Change directory with yazi"
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        command yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end
