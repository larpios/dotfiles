let battery = pmset -g batt | split row -r '\s+' | get 7 | split row '%' | get 0 | into int

let battery_icon = if $battery > 80 { 
  ""
} else if $battery > 50 {
  ""
} else if $battery > 30 {
  ""
} else if $battery > 10 {
  ""
} else {
  ""
}

sketchybar --set "battery" $"label=($battery)%" "label.drawing=on" "icon.drawing=on" $"icon=($battery_icon)"

