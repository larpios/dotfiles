function info
    echo (set_color blue)$argv(set_color normal)
end

function warn
    echo (set_color yellow)$argv(set_color normal)
end

function error
    echo (set_color red)$argv(set_color normal) >&2
end

function is_exe -a cmd -d "Check if command exists"
    type -q $cmd
end

function within -a cwd -d "Run command within certain directory"
    set -l cmd $argv[2..]

    if not test -d $cwd
        error "$cwd is not a directory"
        return 1
    end

    pushd $cwd > /dev/null
    $cmd
    popd > /dev/null
end
