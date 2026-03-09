#!/bin/bash
aerospace_path="/usr/local/bin/aerospace"
focused_monitor="$("$aerospace_path" list-monitors --focused --format '%{monitor-id}')"

get_boolean() {
	if [ "~$1~" = "~$2~" ]; then
		echo "true"
	else
		echo "false"
	fi
}
export -f get_boolean

get_workspace() {
	aerospace_path="/usr/local/bin/aerospace"
	monitor="${1%%:*}"
	workspace="${1##*:}"
	visible_workspace="$("$aerospace_path" list-workspaces --monitor "$monitor" --visible)"
	is_visible="$(get_boolean "$visible_workspace" "$workspace")"
	has_focus="false"
	if [ "~$focused_monitor~" = "~$monitor~" ]; then
		has_focus="$is_visible"
	fi
	"$aerospace_path" list-workspaces --monitor "$monitor" --format '{"index":%{workspace},"label":"%{workspace}","type":"type","display":%{monitor-id},"has-focus":'"$has_focus"',"is-visible":'"$is_visible"',"is-native-fullscreen":false},' | grep "index\":$workspace"
}
export -f get_workspace

get_spaces() {
	#json="["
	#for i in $("$aerospace_path" list-workspaces --monitor all --format '%{monitor-id}:%{workspace}'); do
	#	json="$json$(get_workspace "$i"),"
	#done
	json="[$("$aerospace_path" list-workspaces --monitor all --format '%{monitor-id}:%{workspace}' | xargs -I {} -P 10 bash -c 'get_workspace "{}"')"
	echo "${json%?}]"
}

get_windows() {
	json="[$("$aerospace_path" list-windows --all --format '{"id":%{window-id},"app":"%{app-bundle-id}","display":%{monitor-id},"space":%{workspace},"is-native-fullscreen":false,"is-sticky":false},')"
	echo "${json%?}]"
}

get_displays() {
	json="[$("$aerospace_path" list-monitors --format '{"id":%{monitor-id},"index":%{monitor-id}},')"
	echo "${json%?}]"
}

get_spaces
get_windows
get_displays
