use ../colors.nu mocha
use ../icons.nu icons

sketchybar --add item "battery" "right"
sketchybar --set "battery" $"icon=($icons.battery)" $"icon.color=($mocha.text)" "label.drawing=on" $"background.color=($mocha.transparent)" "icon.font=JetBrainsMono Nerd Font:Regular:18.0 script=nu ($nu.home-dir)/.config/sketchybar/plugins/battery.nu"
