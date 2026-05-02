use ../colors.nu mocha
use ../icons.nu icons

# Add the main Network item
sketchybar --add item "network" "right"
sketchybar --set "network" "update_freq=5" $"icon=($icons.wifi)" $"icon.color=($mocha.green)" $"background.color=($mocha.surface0)" "popup.align=center" "popup.background.color=0xff1e1e2e" "popup.background.corner_radius=8" "popup.background.border_width=2" "popup.background.border_color=0xff45475a" $"script=nu ($nu.home-dir)/.config/sketchybar/plugins/network.nu" "click_script=sketchybar --set $NAME popup.drawing=toggle"

# Add a popup item to show the Local IP address
sketchybar --add item "network.ip" "popup.network"
sketchybar --set "network.ip" "icon=Local IP:" "icon.font=JetBrainsMono Nerd Font:Bold:14.0" $"icon.color=($mocha.text)" "label=Loading..." $"label.color=($mocha.text)" "background.drawing=off" "padding_left=10" "padding_right=10"

# Add a popup item to show the Device interface
sketchybar --add item "network.device" "popup.network"
sketchybar --set "network.device" "icon=Device:" "icon.font=JetBrainsMono Nerd Font:Bold:14.0" $"icon.color=($mocha.text)" "label=Loading..." $"label.color=($mocha.text)" "background.drawing=off" "padding_left=10" "padding_right=10"
