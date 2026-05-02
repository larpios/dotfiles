#!/usr/bin/env nu
use ../colors.nu mocha
use ../icons.nu icons

# Find the active interface by looking for "status: active" in ifconfig
let active_interfaces = (bash -c "ifconfig -u | grep -B 10 'status: active' | grep 'flags=' | cut -d: -f1" | lines | str trim)

if ($active_interfaces | is-empty) {
    sketchybar --set "network" $"icon=($icons.wifi_off)" "label=Disconnected" $"icon.color=($mocha.subtext0)"
    sketchybar --set "network.ip" "label=N/A"
} else {
    # Pick the first active interface (usually en0 or bridge0)
    let device = ($active_interfaces | first)
    
    # Check if this interface is identified as Wi-Fi by networksetup
    let is_wifi = (bash -c $"networksetup -listallhardwareports | grep -B 1 'Device: ($device)' | grep 'Hardware Port: Wi-Fi'" | is-empty | not $in)

    # Try to get SSID using networksetup first, then fallback to ipconfig summary
    var ssid = (try { 
        networksetup -getairportnetwork $device | split row ": " | last | str trim 
    } catch { 
        "" 
    })
    
    if ($ssid | str contains "You are not associated") or ($ssid == "") {
        # Fallback to ipconfig summary
        $ssid = (try {
            bash -c $"ipconfig getsummary ($device) | grep SSID | awk -F': ' '{print $2}'" | str trim
        } catch {
            ""
        })
    }

    let display_ssid = if ($ssid == "") {
        if ($is_wifi) { "Wi-Fi" } else { "Ethernet" }
    } else {
        $ssid
    }

    # Get the IP address for this specific device
    let ip = (bash -c $"ifconfig ($device) | grep 'inet ' | awk '{print $2}'" | str trim)
    
    # Update SketchyBar
    let icon = if ($is_wifi) { $icons.wifi } else { "󰈀" }
    
    sketchybar --set "network" $"icon=($icon)" $"label=($display_ssid)" $"icon.color=($mocha.green)"
    sketchybar --set "network.ip" $"label=($ip)"
    sketchybar --set "network.device" $"label=($device)"
}
