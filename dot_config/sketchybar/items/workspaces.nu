use ../colors.nu mocha
use ../icons.nu icons

# Add the custom event first
sketchybar --add event aerospace_workspace_change

const PADDING = 6
const CORNER_RADIUS = 6

# AeroSpace workspaces 1-9
for i in 1..9 {
    let workspace_name = $"workspace.($i)"
    sketchybar --add item $workspace_name "left"
    sketchybar --set $workspace_name $"icon=($i)" $"icon.padding_left=($PADDING)" $"icon.padding_right=($PADDING)" "label.drawing=off" $"background.color=($mocha.surface1)" $"background.corner_radius=($CORNER_RADIUS)" "background.drawing=off" $"click_script=aerospace workspace ($i)"
}

sketchybar --set "workspace.1" $"script=nu ($nu.home-dir)/.config/sketchybar/plugins/workspaces.nu"
sketchybar --subscribe "workspace.1" "aerospace_workspace_change"

sketchybar --add item "space_separator" "left"
sketchybar --set "space_separator" "icon=|" $"icon.color=($mocha.surface2)" $"icon.padding_left=($PADDING)" $"icon.padding_right=($PADDING)" "label.drawing=off" "background.drawing=off"
