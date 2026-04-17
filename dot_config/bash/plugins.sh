#!/usr/bin/env bash

CURL_DOWNLOAD_DIR="$BASH_DATA_DIR/curl/"

mkdir -p "$CURL_DOWNLOAD_DIR"

_setup_plugin_github() {
    local url="$1"
    local post_hook="$2"
    local dependencies="${*:3}"
    local reponame
    reponame="$(basename "$url" | sed 's/\.git//')"
    local target
    target="$BASH_DATA_DIR/$reponame"

    for dep in "${dependencies[@]}"; do
        if ! is_exe "$dep"; then
            echo "$dep is not installed"
            return 1
        fi
    done

    if [ -d "$target/.git" ]; then
        git -C "$target" pull
    else
        git clone --recursive --depth 1 --shallow-submodules "$url" "$BASH_DATA_DIR/$reponame"
    fi

    if [ "$post_hook" != "" ]; then
        (
            cd "$target" || return 1
            eval "$post_hook"
        )
    fi
}

# =============================== Disabled ======================================================================
# {
#     # ble.sh
# (
#     cd "$CURL_DOWNLOAD_DIR" || exit 1
#     if [ -d ble-nightly ]; then
#         exit 0
#     fi
#     curl -L https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJf -
# )
#     # source "$CURL_DOWNLOAD_DIR/ble-nightly/ble.sh"
# }
