#!/usr/bin/env bash
PATH="$HOME/.nix-profile/bin:/usr/local/bin:/bin:/usr/bin:$HOME/.cargo/bin:$PATH"

REPO_URL='https://github.com/larpios/sketchybar-config'
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/sketchybar"
REPO_PATH="$DATA_DIR/sketchybar-config"
BINARY_PATH="$HOME/.cargo/bin/sketchybarrc"
LOG_PATH="$DATA_DIR/sketchybar.log"

LOG_WRITTEN=false

write_log() {
    if ! "$LOG_WRITTEN"; then
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" >"$LOG_PATH"
        echo '' >>"$LOG_PATH"
        LOG_WRITTEN=true
    fi
    echo "$*" >>"$LOG_PATH"
}

debug() {
    write_log "[debug]" "$@"
}

warn() {
    write_log "[warn]" "$@"
}

error() {
    write_log "[error]" "$@"
}

has_update() (
    debug "Checking if sketchybar-config has updates..."
    cd "$REPO_PATH" || exit 1

    old_commit=$(git rev-parse HEAD)

    git fetch
    git pull --rebase

    new_commit=$(git rev-parse HEAD)

    if [ "$old_commit" != "$new_commit" ]; then
        debug "sketchybar-config has updates"
        return
    else
        debug "sketchybar-config is up to date"
        return 1
    fi
)

main() {
    debug "Checking if cargo is installed..."
    if ! command -v cargo >/dev/null 2>&1; then
        warn "cargo is not installed"
        if ! command -v nu >/dev/null 2>&1; then
            error "nu is not installed"
            exit 1
        fi

        # Fallback to nu
        warn "Falling back to nu"
        nu main.nu
        exit
    fi
    debug "cargo is installed"

    debug "Checking if sketchybar-config is cloned..."
    if [ ! -d "$REPO_PATH/.git" ]; then
        debug "Cloning sketchybar-config..."
        mkdir -p "$DATA_DIR"
        if ! git clone "$REPO_URL" "$REPO_PATH"; then
            error "Failed to clone sketchybar-config"
            exit 2
        fi
    fi
    debug "sketchybar-config is cloned"

    debug "Checking if sketchybar-config has updates or is not installed..."
    if has_update || [ ! -f "$BINARY_PATH" ]; then
        debug "Installing sketchybar-config..."
        if ! cargo install --path "$REPO_PATH"; then
            error "Failed to install sketchybar-config"
            exit 3
        fi
    fi

    "$BINARY_PATH"
}

main
