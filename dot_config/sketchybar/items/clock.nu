use ../colors.nu mocha
use ../icons.nu icons

sketchybar --add item "clock" "right"
sketchybar --set "clock" "update_freq=10" $"icon=($icons.clock)" $"icon.color=($mocha.blue)" $"background.color=($mocha.surface0)" $"script=nu ($nu.home-dir)/.config/sketchybar/plugins/clock.nu" "click_script=open -a 'Calendar'"
