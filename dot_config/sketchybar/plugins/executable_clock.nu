#!/usr/bin/env nu
let time = (date now | format date "%H:%M")
sketchybar --set $env.NAME $"label=($time)"
