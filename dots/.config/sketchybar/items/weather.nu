use ../colors.nu mocha
use ../icons.nu icons

sketchybar --add item "weather" "right"
sketchybar --set "weather" "update_freq=1800" $"icon=($icons.weather)" $"icon.color=($mocha.yellow)" $"background.color=($mocha.surface0)" $"script=nu ($nu.home-dir)/.config/sketchybar/plugins/weather.nu" "click_script=open 'https://weather.com'"
