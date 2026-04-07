use ../colors.nu mocha
use ../icons.nu icons

sketchybar --add item "wifi" "right"
sketchybar --set "wifi" "update_freq=5" $"icon=($icons.wifi)" $"icon.color=($mocha.green)" $"background.color=($mocha.surface0)" $"script=nu ($nu.home-dir)/.config/sketchybar/plugins/wifi.nu" "click_script=open 'x-apple.systempreferences:com.apple.preference.network'"
