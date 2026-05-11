#!/usr/bin/env nu
let weather = (try { curl -s "wttr.in/?format=%t" } catch { "N/A" })
sketchybar --set $env.NAME $"label=($weather)"
