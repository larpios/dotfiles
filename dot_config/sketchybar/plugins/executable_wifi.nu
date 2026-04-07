#!/usr/bin/env nu
use ../colors.nu mocha
use ../icons.nu icons

let wifi_device = (networksetup -listallhardwareports | lines | window 2 | where { |it| ($it | get 0) =~ "Wi-Fi" } | first | get 1 | split row ": " | last | str trim)
let ssid = (try { networksetup -getairportnetwork $wifi_device | split row ": " | last | str trim } catch { "Error" })

if ($ssid | str contains "You are not associated") or ($ssid | str contains "Off") or ($ssid == "Error") {
    sketchybar --set $env.NAME $"icon=($icons.wifi_off)" "label=Disconnected" $"icon.color=($mocha.subtext0)"
} else {
    sketchybar --set $env.NAME $"icon=($icons.wifi)" $"label=($ssid)" $"icon.color=($mocha.green)"
}
