use ../colors.nu mocha
use ../icons.nu icons

sketchybar --add item "cpu" "right"
sketchybar --set "cpu" "update_freq=2" $"icon=($icons.cpu)" $"icon.color=($mocha.red)" $"background.color=($mocha.surface0)" "popup.align=center" "popup.background.color=0xff1e1e2e" "popup.background.corner_radius=8" "popup.background.border_width=2" "popup.background.border_color=0xff45475a" $"script=nu ($nu.home-dir)/.config/sketchybar/plugins/cpu.nu" "click_script=sketchybar --set $NAME popup.drawing=toggle"

# CPU details popup
sketchybar --add item "cpu.user" "popup.cpu"
sketchybar --set "cpu.user" "icon=User:" "icon.font=JetBrainsMono Nerd Font:Bold:14.0" $"icon.color=($mocha.text)" "label=Loading..." $"label.color=($mocha.text)" "background.drawing=off"

sketchybar --add item "cpu.sys" "popup.cpu"
sketchybar --set "cpu.sys" "icon=Sys:" "icon.font=JetBrainsMono Nerd Font:Bold:14.0" $"icon.color=($mocha.text)" "label=Loading..." $"label.color=($mocha.text)" "background.drawing=off"

sketchybar --add item "cpu.idle" "popup.cpu"
sketchybar --set "cpu.idle" "icon=Idle:" "icon.font=JetBrainsMono Nerd Font:Bold:14.0" $"icon.color=($mocha.text)" "label=Loading..." $"label.color=($mocha.text)" "background.drawing=off"
