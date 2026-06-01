# Commands for working with symbolic links

export def "is-symlink" [] : [path -> bool, list<path> -> list<bool>] {
    let input = $in

    if ($input | describe | str contains 'list') {
        $input | each { symlink is-valid }
    } else {
        if not ($input | path exists --no-symlink) {
            error make {
                msg: $"($input) does not exist"
                labels: [
                    {
                        text: 'Path does not exist'
                        span: (metadata $input).span
                    }
                ]
            }
        }

        ($input | path type) == 'symlink'
    }
}

export def "symlink is-valid" [] : [path -> bool, list<path> -> list<bool>] {
    let input = $in

    if ($input | describe | str contains 'list') {
        return ($input | each { symlink is-valid })
    }

    if not ($input | is-symlink) {
        false 
    } else {
        $input | path exists
    }
}

export def "symlink is-broken" [] : [path -> bool, list<path> -> list<bool>] {
    $in | symlink is-valid | each { |v| not $v }
}

export def "symlink follow" [] : [path -> path, list<path> -> list<path>] {
    let path_input = $in

    if ($path_input | describe | str contains 'list') {
        return ($path_input | each { symlink follow })
    }

    if ($path_input | is-empty) {
        return ''
    }

    if not ($path_input | path exists) {
        error make {
            msg: $"($path_input) does not exist"
            labels: [
                {
                    text: 'Path does not exist'
                    span: (metadata $path_input).span
                }
            ]
        }
    }
    if not ($path_input | is-symlink) {
        error make {
            msg: $"($path_input) is not a symlink"
            labels: [
                {
                    text: 'Path is not a symlink'
                    span: (metadata $path_input).span
                }
            ]
        }
    }

    $in | path expand
}

# Convert a symlink to its target file
export def "symlink into-target" [
    link: path
    --copy-to (-c): oneof<path, nothing> = null # Instead of replacing the symlink, copy to the given path
    --yes (-y) # Don't prompt for confirmation
] {
    let link_target = $link | symlink follow 
    let dest = $copy_to | default $link

    if not $yes and ($dest | path exists) {
        let overwrite = input $"Do you want to overwrite `($dest)` with `($link_target)`? [y/N]: " | str downcase

        if $overwrite == 'y' {
            rm $dest
            cp $link_target $dest
        }
    } else {
        cp -i $link_target $dest
    }
}
