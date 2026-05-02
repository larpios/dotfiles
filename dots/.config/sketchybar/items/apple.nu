use ../colors.nu mocha
use ../icons.nu icons

sketchybar --add item "apple.logo" "left"
sketchybar --set "apple.logo" $"icon=($icons.apple)" $"icon.color=($mocha.text)" "label.drawing=off" $"background.color=($mocha.transparent)" "icon.font=JetBrainsMono Nerd Font:Regular:18.0" "padding_right=15" "click_script=open -a 'System Settings'"
