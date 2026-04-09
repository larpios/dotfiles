let battery = pmset -g batt | split row -r '\s+' | get 7 | split row '%' | get 0

sketchybar --set "battery" $"label=($battery)% label.drawing=on"

