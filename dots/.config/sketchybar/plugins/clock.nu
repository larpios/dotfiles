#!/usr/bin/env nu
let time = (date now | format date "%H:%M")
let full_date = (date now | format date "%A, %d %b %Y")
let utc_time = (date now | format date "%H:%M")

sketchybar --set $env.NAME $"label=($time)"
sketchybar --set "clock.date" $"label=($full_date)"
sketchybar --set "clock.utc" $"label=($utc_time)"
