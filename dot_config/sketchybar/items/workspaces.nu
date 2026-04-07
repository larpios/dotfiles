use ../colors.nu mocha
use ../icons.nu icons

# AeroSpace workspaces 1-9
for i in 1..9 {
    let workspace_name = $"workspace.($i)"
    sketchybar --add item $workspace_name "left"
    sketchybar --set $workspace_name $"icon=($i)" "update_freq=2" "icon.padding_left=10" "icon.padding_right=10" "label.drawing=off" $"background.color=($mocha.surface1)" "background.corner_radius=6" "background.drawing=off" $"script=nu ($nu.home-dir)/.config/sketchybar/plugins/workspace.nu" $"click_script=aerospace workspace ($i)"
    
    # Subscribe each workspace item to the aerospace_workspace_change event
    sketchybar --subscribe $workspace_name "aerospace_workspace_change" "mouse.clicked"
}

sketchybar --add item "space_separator" "left"
sketchybar --set "space_separator" "icon=|" $"icon.color=($mocha.surface2)" "icon.padding_left=10" "icon.padding_right=10" "label.drawing=off" "background.drawing=off"
