use ../colors.nu mocha
use ../icons.nu icons

sketchybar --add item "cpu" "right"
sketchybar --set "cpu" "update_freq=2" $"icon=($icons.cpu)" $"icon.color=($mocha.red)" $"background.color=($mocha.surface0)" $"script=nu ($nu.home-dir)/.config/sketchybar/plugins/cpu.nu" "click_script=open -a 'Activity Monitor'"
