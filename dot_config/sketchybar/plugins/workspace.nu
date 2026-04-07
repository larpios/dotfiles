#!/usr/bin/env nu
use ../colors.nu mocha

# AeroSpace workspace sync plugin
# Triggered by: aerospace_workspace_change (from AeroSpace) or mouse.clicked

# AeroSpace passes $AEROSPACE_FOCUSED_WORKSPACE, but SketchyBar passes it 
# as $FOCUSED_WORKSPACE because of the user's 'FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE' arg.
# Fallback to CLI if the variable is missing (e.g. on manual reload).

let current_workspace = ($env.FOCUSED_WORKSPACE? | default (bash -c "aerospace list-workspaces --focused" | str trim))
let workspace_item_number = ($env.NAME | split row "." | last)

if $current_workspace == $workspace_item_number {
    sketchybar --set $env.NAME "background.drawing=on" $"icon.color=($mocha.mauve)"
} else {
    sketchybar --set $env.NAME "background.drawing=off" $"icon.color=($mocha.text)"
}
