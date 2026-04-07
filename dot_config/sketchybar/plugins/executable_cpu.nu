#!/usr/bin/env nu

# Get detailed CPU load: User, System, Idle
let cpu_raw = (bash -c "top -l 1 | grep -E '^CPU'" | str trim)
# Expected format: CPU usage: 12.01% user, 8.16% sys, 79.82% idle
let user = ($cpu_raw | awk '{print $3}' | sed 's/%//')
let sys = ($cpu_raw | awk '{print $5}' | sed 's/%//')
let idle = ($cpu_raw | awk '{print $7}' | sed 's/%//')

# Calculate total load
let load = ($user | into int) + ($sys | into int) | math round 

sketchybar --set $env.NAME $"label=($load)%"
sketchybar --set "cpu.user" $"label=($user)%"
sketchybar --set "cpu.sys" $"label=($sys)%"
sketchybar --set "cpu.idle" $"label=($idle)%"
