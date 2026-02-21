#!/bin/bash

notifications=(
  icon=􀐫
  icon.font="$FONT:Black:12.0"
  icon.padding_right=0
  label.align=right
  padding_left=15
  update_freq=30
  script="$PLUGIN_DIR/notifications.sh"
  click_script="$PLUGIN_DIR/zen.sh"
)

sketchybar --add item notifications right       \
           --set notifications "${notifications[@]}" \
           --subscribe notifications system_woke
