#!/usr/bin/env nu
use ../colors.nu mocha

# Optimized AeroSpace workspace manager
# This script updates all workspace items in a single SketchyBar batch for maximum performance.

# 1. Determine which workspace is focused
let focused = if ($env.FOCUSED_WORKSPACE? | is-empty) {
    (bash -c "aerospace list-workspaces --focused" | str trim)
} else {
    $env.FOCUSED_WORKSPACE | str trim
}

# 2. Build the command arguments list
# We use a mutable list to collect all commands
mut args = []
for i in 1..9 {
    let name = $"workspace.($i)"
    if ($i | into string) == $focused {
        $args = ($args | append ["--set" $name "background.drawing=on" $"icon.color=($mocha.mauve)"])
    } else {
        $args = ($args | append ["--set" $name "background.drawing=off" $"icon.color=($mocha.text)"])
    }
}

# 3. Apply all updates at once
# We call sketchybar (which should be in the path)
sketchybar ...$args
sketchybar --update
