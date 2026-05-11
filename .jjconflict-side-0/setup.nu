#!/usr/bin/env nu

# Constants must be parse-time evaluatable
const BACKUP_DIR = ($nu.home-dir | path join '.backup')
const SCRIPT_PATH = (path self)
const SCRIPT_DIR = ($SCRIPT_PATH | path dirname)

def main [
    --force (-f)      # Overwrite existing files/symlinks
    --dry-run (-n)    # Show what would be done without making changes
] {
    if $dry_run {
        print "(Dry-run mode active: no changes will be made)"
    }

    print "--- Processing core dots ---"
    symlink-in-dir 'dots' '' --exclude ['.config'] --force=$force --dry-run=$dry_run
    symlink-in-dir 'dots' '.config' --force=$force --dry-run=$dry_run

    match $nu.os-info.name {
        'macos' => {
            print "--- Processing macOS specifics ---"
            let macos_links = [
                { src: '~/.config/nushell', dest: '~/Library/Application Support/nushell' }
            ]
            handle-symlinks $macos_links --force=$force --dry-run=$dry_run
        }
        'windows' => {
            print "--- Processing Windows specifics ---"
            # Ported from Rust: symlink_in_dir(ctx, "windows/dots", "", Some(&["Documents"]))
            symlink-in-dir 'windows/dots' '' --exclude ['Documents'] --force=$force --dry-run=$dry_run
            # Ported from Rust: symlink_in_dir(ctx, "windows/dots", "Documents", None)
            symlink-in-dir 'windows/dots' 'Documents' --force=$force --dry-run=$dry_run
        }
        _ => {
            print $"No specific setup for OS: ($nu.os-info.name)"
        }
    }

    print "--- Cloning external repositories ---"
    let externals = [
        { url: 'https://github.com/larpios/nvim-config', dest: '~/.config/nvim' }
    ]
    clone-repos $externals --force=$force --dry-run=$dry_run

    print "--- Setup complete ---"
}

# Symlink all files inside a directory to the home directory
def symlink-in-dir [
    base_dir: path       # e.g. 'dots'
    relative_path: path  # e.g. '.config'
    --exclude (-e): list<string> = []
    --force (-f)
    --dry-run (-n)
] {
    let source_root = $SCRIPT_DIR | path join $base_dir
    let search_dir = $source_root | path join $relative_path
    
    if not ($search_dir | path exists) {
        print $"Skipping: ($search_dir) does not exist."
        return
    }

    ls $search_dir | each { |entry|
        let file_name = $entry.name | path basename
        if ($file_name in $exclude) { return }

        # rel_path calculation mirroring Rust: path.strip_prefix(base)
        let rel_path = $entry.name | path relative-to $source_root
        let dest = $nu.home-dir | path join $rel_path
        
        handle-symlinks [{ src: $entry.name, dest: $dest }] --force=$force --dry-run=$dry_run
    }
}

# Create symlinks with backup and force support
def handle-symlinks [
    links: list<record<src: any, dest: any>>
    --force (-f)
    --dry-run (-n)
] {
    for link in $links {
        let src = $link.src | path expand
        let dest = $link.dest | path expand

        if ($dest | path exists) or (is-broken-link $dest) {
            if $force {
                print $"Overwriting ($dest)..."
                if not $dry_run {
                    rm -rf $dest
                }
            } else {
                print $"($dest) already exists, backing up..."
                backup-file $dest --dry-run=$dry_run
            }
        }

        print $"Symlinking ($src) -> ($dest)"
        if not $dry_run {
            mkdir ($dest | path dirname)
            if $nu.os-info.name == 'windows' {
                if ($src | path type) == 'dir' {
                    ^mklink /D $dest $src
                } else {
                    ^mklink $dest $src
                }
            } else {
                ln -sf $src $dest
            }
        }
    }
}

# Helper to check for broken symlinks (which 'path exists' returns false for)
def is-broken-link [p: path] {
    let parent = $p | path dirname
    if not ($parent | path exists) { return false }
    (ls -la $parent | where name == ($p | path expand) | is-not-empty) and (not ($p | path exists))
}

# Backup a file or directory
def backup-file [
    target: path
    --dry-run (-n)
] {
    if not ($target | path exists) { return }
    
    let name = $target | path basename
    let timestamp = (date now | format date "%Y%m%d_%H%M%S")
    let backup_path = $BACKUP_DIR | path join $"($name)_($timestamp)"

    print $"Backing up ($target) to ($backup_path)"
    if not $dry_run {
        mkdir $BACKUP_DIR
        mv $target $backup_path
    }
}

# Clone repositories using jj (preferred) or git
def clone-repos [
    repos: list<record<url: string, dest: string>>
    --force (-f)
    --dry-run (-n)
] {
    let has_jj = (which jj | is-not-empty)
    let has_git = (which git | is-not-empty)

    if not $has_jj and not $has_git {
        print "Error: Neither 'jj' nor 'git' found in PATH."
        return
    }

    for repo in $repos {
        let dest = $repo.dest | path expand
        
        if ($dest | path exists) {
            if $force {
                print $"Removing existing directory ($dest) for re-clone..."
                if not $dry_run { rm -rf $dest }
            } else {
                print $"($dest) already exists, skipping clone."
                continue
            }
        }

        if $dry_run {
            let tool = if $has_jj { "jj" } else { "git" }
            print $"[dry-run] ($tool) clone ($repo.url) ($dest)"
            continue
        }

        if $has_jj {
            print $"Cloning ($repo.url) using jj..."
            jj git clone $repo.url $dest
        } else {
            print $"Cloning ($repo.url) using git..."
            git clone $repo.url $dest
        }
    }
}
