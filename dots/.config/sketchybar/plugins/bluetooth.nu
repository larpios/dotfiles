#!/usr/bin/env nu
use ../colors.nu mocha
use ../icons.nu icons

let bt_state = (try { defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState | str trim } catch { "0" })

if $bt_state == "1" {
    sketchybar --set $env.NAME $"icon.color=($mocha.sky)" "label=On"
} else {
    sketchybar --set $env.NAME $"icon.color=($mocha.subtext0)" "label=Off"
}
