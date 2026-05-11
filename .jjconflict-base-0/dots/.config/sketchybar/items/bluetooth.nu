use ../colors.nu mocha
use ../icons.nu icons

sketchybar --add item "bluetooth" "right"
sketchybar --set "bluetooth" "update_freq=10" $"icon=($icons.bluetooth)" $"icon.color=($mocha.sky)" $"background.color=($mocha.surface0)" $"script=nu ($nu.home-dir)/.config/sketchybar/plugins/bluetooth.nu" "click_script=open 'x-apple.systempreferences:com.apple.preferences.Bluetooth'"
