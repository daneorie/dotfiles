#!/bin/bash

#default["Messages"]="com.apple.mobilesms"
#default["Reminders"]="com.apple.reminders"
default=("com.apple.mobilesms" "com.apple.reminders")
#python["Discord"]="Discord"
#python["Mail"]="Mail"
#python["Microsoft Outlook"]="Microsoft Outlook"
#python["Microsoft Teams"]="Microsoft Teams"
#python["Slack"]="Slack"
python=("Discord" "Mail" "Microsoft Outlook" "Microsoft Teams" "Slack")

widgets="~/Library/Application\ Support/Übersicht/widgets"

notificationDefault="$widgets/simple-bar/lib/scripts/notifications-default.sh"
database="$(lsof -p "$(ps aux | grep -m1 usernoted | awk '{ print $2 }')" | awk '{ print $NF }' | grep 'db2/db$')"
defaultAppBadgeJsonList="$($notificationDefault "$database" "${default[@]}")"

notificationPython="$widgets/simple-bar/lib/scripts/notifications-other.py3"
pythonAppBadgeJsonList="$($notificationPython)"

#sketchybar --set "$NAME" label="$(echo $defaultAppBadgeJsonList | jq '.[].badge')"
#sketchybar --set "$NAME" label="$(echo $notificationDefault)"
#sketchybar --set "$NAME" label="$(echo "${default[@]}")"
#sketchybar --set "$NAME" label="$(echo $pythonAppBadgeJsonList | tr "'" '"' | jq '.Mail')"
sketchybar --set "$NAME" label="$(echo $pythonAppBadgeJsonList)"
