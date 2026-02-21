#!/usr/bin/env bash
 
source "$CONFIG_DIR/colors.sh"

mainMonitor="HP VH240a (2)"
monitors=$(aerospace list-monitors)
monitorsSorted=("$(grep "$mainMonitor" <<< "$monitors")")
monitorsSorted+=("$(grep -v "$mainMonitor" <<< "$monitors")")
monitorsSorted=($(printf '%s\n' "${monitorsSorted[@]}" | awk '{ print $1 }'))

AEROSPACE_FOCUSED_MONITOR=$(aerospace list-monitors --focused | awk '{print $1}')
AEROSPACE_FOCUSED_MONITOR=${monitorsSorted[$AEROSPACE_FOCUSED_MONITOR - 1]}
AEROSAPCE_WORKSPACE_FOCUSED_MONITOR=$(aerospace list-workspaces --monitor focused --empty no)
AEROSPACE_EMPTY_WORKSPACE=$(aerospace list-workspaces --monitor focused --empty)

reload_workspace_icon() {
  apps=$(aerospace list-windows --workspace "$@" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi

  sketchybar --animate sin 10 --set space.$@ label="$icon_strip"
}

echo 'space_windows_change: '$AEROSPACE_FOCUSED_WORKSPACE
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  osascript -e 'tell application id "tracesOf.Uebersicht"' -e 'refresh widget id "battery-bar-widget-index-jsx"' -e 'end tell'

  # if [ $i = "$FOCUSED_WORKSPACE" ]; then
  #   sketchybar --set space.$FOCUSED_WORKSPACE background.drawing=on
  # else
  #   sketchybar --set space.$FOCUSED_WORKSPACE background.drawing=off
  # fi
  #echo 'space_windows_change: '$AEROSPACE_FOCUSED_WORKSPACE
  #space="$(echo "$INFO" | jq -r '.space')"
  #apps="$(echo "$INFO" | jq -r '.apps | keys[]')"
  # apps=$(aerospace list-windows --workspace $AEROSPACE_FOCUSED_WORKSPACE | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
  #
  # icon_strip=" "
  # if [ "${apps}" != "" ]; then
  #   while read -r app
  #   do
  #     icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
  #   done <<< "${apps}"
  # else
  #   icon_strip=" —"
  # fi

  reload_workspace_icon "$AEROSPACE_PREV_WORKSPACE"
  reload_workspace_icon "$AEROSPACE_FOCUSED_WORKSPACE"

  #sketchybar --animate sin 10 --set space.$space label="$icon_strip"

  # current workspace space border color
  sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE icon.highlight=true \
                         label.highlight=true \
                         background.border_color=$GREY

  # prev workspace space border color
  sketchybar --set space.$AEROSPACE_PREV_WORKSPACE icon.highlight=false \
                         label.highlight=false \
                         background.border_color=$BACKGROUND_2

  # if [ "$AEROSPACE_FOCUSED_WORKSPACE" -gt 3 ]; then
  #   sketchybar --animate sin 10 --set space.$AEROSPACE_FOCUSED_WORKSPACE display=1
  # fi
  ## focused 된 모니터에 space 상태 보이게 설정
  for i in $AEROSAPCE_WORKSPACE_FOCUSED_MONITOR; do
    sketchybar --set space.$i display=$AEROSPACE_FOCUSED_MONITOR
  done

  #for i in $AEROSPACE_EMPTY_WORKSPACE; do
  #  sketchybar --set space.$i display=0
  #done

  sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE display=$AEROSPACE_FOCUSED_MONITOR

fi
