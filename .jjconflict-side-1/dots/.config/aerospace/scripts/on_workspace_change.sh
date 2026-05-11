#!/usr/bin/env bash

sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE

PIP_ID="$(aerospace list-windows --all | grep -i "picture-in-picture" | cut -d '|' -f 1 | tr -d ' ')"

FOCUSED_WS="$(aerospace list-workspaces --focused)"
aerospace move-node-to-workspace --window-id "$PIP_ID" "$FOCUSED_WS" 

