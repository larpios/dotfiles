#!/usr/bin/env nu

# Using top instead of sys cpu because it's more stable across nushell versions and simpler.
let cpu_usage = (bash -c "top -l 1 | grep -E '^CPU' | awk '{print $3}' | sed 's/%//'" | str trim)
sketchybar --set $env.NAME $"label=($cpu_usage)%"
