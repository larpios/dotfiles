const BACKUP_DIR = $nu.home-dir | path join '.backup'
const SCRIPT_PATH = path self
const SCRIPT_DIR = $SCRIPT_PATH | path dirname

def "main" [
    --force (-f) # Whether to force overwriting existing files
    --dry-run (-n) # Only print commands
] {
    if $dry_run {
        print $"Running in dry-run mode, no changes will be made."
    }
    symlink-in-dir 'dots' --exclude ['.config'] --dry-run=$dry_run
    symlink-in-dir 'dots/.config' --dry-run=$dry_run

    match $nu.os-info.name {
        'windows' => {
            symlink-in-dir 'windows/dots/Documents' --dry-run=$dry_run
        }
        'macos' => {
            symlink-in-dir 'macos/dots/Library/Application Support/' --dry-run=$dry_run
        }
    }

    clone-externals --dry-run=$dry_run

    return
}

def clone-externals [
    --force (-f) = false
    --dry-run (-n) = false
] {
    let externals = [
        ['https://github.com/larpios/nvim-config', '~/.config/nvim']
    ]

    $externals | par-each { |ext|
        print $"Cloning ($ext.0) into ($ext.1)..."

        let dest = $ext.1 | path expand
        if ($dest | path exists) {
            if $force {
                print $"($dest) already exists, overwriting..."
                if not $dry_run {
                    rm -rf $dest
                }
            } else {
                print $"($dest) already exists, skipping..."
                return
            }
        }

        if not $dry_run {
            git clone $ext.0 $dest
        }
    }

    return
}

def symlink-in-dir [
    dir: path
    --exclude (-e): list<path> = []
    --dry-run (-n) = false
] {
    cd ($SCRIPT_DIR | path join $dir)

    let files = ls -al *
    $files 
    | where { |f| not ($f.name in $exclude) }
    | par-each { |f| 
        symlink-file $f.name --dry-run=$dry_run
    }

    return
}

def symlink-file [
    file: path
    --dry-run (-n) = false
] {
    let full_path = $file | path expand
    let dest = $nu.home-dir | path join $file
    if ($dest | path exists) and (ls -al $dest | get type) != 'symlink' {
        print $"($dest) already exists, backing up..."
        send-to-backup $dest --dry-run=$dry_run
    }
    print $"Symlinking ($full_path) to ($nu.home-dir)..."
    if not $dry_run {
        ln -sf $full_path $dest
    }

    return
}

def send-to-backup [
    file: path
    --dry-run (-n) = false
] {
    print $"Moving ($file) to ($BACKUP_DIR)..."
    if not $dry_run {
        mkdir $BACKUP_DIR
        mv -pf $file $BACKUP_DIR
    }

    return
}
