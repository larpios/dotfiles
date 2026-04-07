use ../colors.nu mocha
use ../icons.nu icons

# Add workspaces 1-9
for i in 1..9 {
    sketchybar --add space $"space.($i)" "left"
    sketchybar --set $"space.($i)" $"associated_space=($i)" $"icon=($i)" "icon.padding_left=8" "icon.padding_right=8" "label.drawing=off" $"background.color=($mocha.surface0)" "background.corner_radius=6" "background.drawing=off" $"script=nu ($nu.home-dir)/.config/sketchybar/plugins/space.nu" $"click_script=yabai -m space --focus ($i)"
}

sketchybar --add item "space_separator" "left"
sketchybar --set "space_separator" "icon=|" $"icon.color=($mocha.surface2)" "icon.padding_left=10" "icon.padding_right=10" "label.drawing=off" "background.drawing=off"
