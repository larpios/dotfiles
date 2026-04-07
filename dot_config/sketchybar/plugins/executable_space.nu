#!/usr/bin/env nu
use ../colors.nu mocha
use ../icons.nu icons

let is_selected = ($env.SELECTED? | default "false")

if $is_selected == "true" {
    sketchybar --set $env.NAME "background.drawing=on" $"icon=($icons.workspace_active)" $"icon.color=($mocha.mauve)"
} else {
    sketchybar --set $env.NAME "background.drawing=off" $"icon=($icons.workspace)" $"icon.color=($mocha.text)"
}
