#!/usr/bin/env nu

use colors.nu mocha
use icons.nu icons

# Clear bar
sketchybar --bar hidden=off
sketchybar --remove '/.*/'

# Set bar defaults
let default_settings = {
  color: $mocha.base
  position: 'top'
  height: '34'
  margin: '8'
  y_offset: '4'
  corner_radius: '10'
  border_width: '2'
  border_color: $mocha.surface1
  padding_left: '12'
  padding_right: '12'
  notch_width: '200'
}

let args = ($default_settings | transpose k v | each { |it| [$"--bar", $"($it.k)=($it.v)"] } | flatten)
sketchybar ...$args

# Set default item properties
let default_item = {
  icon.font: "JetBrainsMono Nerd Font:Regular:16.0"
  icon.color: $mocha.text
  label.font: "JetBrainsMono Nerd Font:Regular:14.0"
  label.color: $mocha.text
  padding_left: '6'
  padding_right: '6'
  icon.padding_left: '6'
  icon.padding_right: '6'
  label.padding_left: '6'
  label.padding_right: '6'
  background.color: $mocha.surface0
  background.corner_radius: '6'
  background.height: '24'
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
source items/wifi.nu
source items/clock.nu

# Final update
sketchybar --update
