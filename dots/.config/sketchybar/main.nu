#!/usr/bin/env nu

use colors.nu mocha
use icons.nu icons

# Define custom events
sketchybar --add event aerospace_workspace_change

# Clear bar
sketchybar --bar hidden=off
sketchybar --remove '/.*/'

# Set bar defaults
let default_settings = {
  color: $mocha.base
  position: 'top'
  height: 28
  margin: 8
  y_offset: 4
  corner_radius: 21
  border_width: 2
  border_color: $mocha.surface1
  padding_left: 8
  padding_right: 8
  notch_width: 200
}

let args = ($default_settings | transpose k v | each { |it| [$"--bar", $"($it.k)=($it.v)"] } | flatten)
sketchybar ...$args

# Set default item properties
let default_item = {
  icon.font: "JetBrainsMono Nerd Font:Regular:14.0"
  icon.color: $mocha.text
  label.font: "JetBrainsMono Nerd Font:Regular:12.0"
  label.color: $mocha.text
  padding_left: 4
  padding_right: 4
  icon.padding_left: 6
  icon.padding_right: 6
  label.padding_left: 6
  label.padding_right: 6
  background.color: $mocha.surface0
  background.corner_radius: 9
  background.height: 20
  icon.highlight_color: $mocha.mauve
  label.highlight_color: $mocha.mauve
}

let item_args = ($default_item | transpose k v | each { |it| [$"--default", $"($it.k)=($it.v)"] } | flatten)
sketchybar ...$item_args

# Load Items
source items/apple.nu
source items/workspaces.nu
source items/cpu.nu
source items/weather.nu
source items/bluetooth.nu
source items/network.nu
source items/clock.nu
source items/battery.nu

# Final update
sketchybar --update
sketchybar --trigger workspace_change
