use ../colors.nu mocha
use ../icons.nu icons

sketchybar --add item "clock" "right"
sketchybar --set "clock" "update_freq=10" $"icon=($icons.clock)" $"icon.color=($mocha.blue)" $"background.color=($mocha.surface0)" "popup.align=center" $"popup.background.color=($mocha.base)" "popup.background.corner_radius=8" "popup.background.border_width=2" $"popup.background.border_color=($mocha.surface1)" $"script=nu ($nu.home-dir)/.config/sketchybar/plugins/clock.nu" "click_script=sketchybar --set $NAME popup.drawing=toggle"

# Popup details: Full Date
sketchybar --add item "clock.date" "popup.clock"
sketchybar --set "clock.date" "icon=Date:" "icon.font=JetBrainsMono Nerd Font:Bold:14.0" $"icon.color=($mocha.text)" "label=Loading..." $"label.color=($mocha.text)" "background.drawing=off"

# Popup details: UTC Time
sketchybar --add item "clock.utc" "popup.clock"
sketchybar --set "clock.utc" "icon=UTC:" "icon.font=JetBrainsMono Nerd Font:Bold:14.0" $"icon.color=($mocha.text)" "label=Loading..." $"label.color=($mocha.text)" "background.drawing=off"
