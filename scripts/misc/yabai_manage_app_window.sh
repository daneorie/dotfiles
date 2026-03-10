#!/bin/sh

toggle_app=$1
file=$(readlink -f ~/.yabairc)
trunc_bottom="$(grep -n "" $file | sort -nr | sed '1,2d' | sort -n | sed 's/^[0-9]*://')"
app=$(yabai -m query --windows --window | jq -re '.app')
title=$(yabai -m query --windows --window | jq -re '.title')

# backup the file
cp $file $file.old

# Does the rule already exist?
if [ -n "$toggle_app" ]; then
	if egrep -q -- "label=\"off:$app\"" $file.old; then
		egrep -v "label=\"(off|on):$app(\|$title)?\"" $file.old > $file

		# Reset the management state of the app
		yabai -m rule --add manage=on  label="on:$app" app="^$app$"
		yabai -m rule --remove "on:$app"

		echo "Managing the app again."
	else
		echo "$trunc_bottom" | egrep -v "label=\"(on|off):$app(\|$title)?\"" > $file
		echo "yabai -m rule --add manage=off label=\"off:$app\" app=\"^$app\$\"" >> $file
		echo "" >> $file
		echo "echo \"yabai configuration loaded...\"" >> $file

		yabai -m rule --add manage=off label="off:$app" app="^$app$"

		echo "No longer managing the app."
	fi
else
	if egrep -q -- "label=\"off:$app(\|$title)?\"" $file.old; then
		if egrep -q -- "label=\"off:$app\"" $file.old; then
			if egrep -q -- "label=\"on:$app\|$title\"" $file.old; then
				egrep -v "label=\"on:$app|$title\"" $file.old > $file

				# Reset the management state of the window combination
				yabai -m rule --add manage=off label="off:$app|$title" app="^$app$" title="^$title$"
				yabai -m rule --remove "off:$app|$title"

				echo "No longer managing the window."
			else
				echo "$trunc_bottom" | egrep -v "label=\"off:$app(\|$title)?\"" > $file
				echo "yabai -m rule --add manage=on  label=\"on:$app|$title\" app=\"^$app\$\" title=\"^$title\$\"" >> $file
				#managing the app must always be last in order for the window management to also work
				echo "yabai -m rule --add manage=off label=\"off:$app\" app=\"^$app\$\"" >> $file
				echo "" >> $file
				echo "echo \"yabai configuration loaded...\"" >> $file

				yabai -m rule --add manage=on  label="on:$app|$title" app="^$app$" title="^$title$"

				echo "Managing the window again."
			fi
		else
			egrep -v "label=\"off:$app(\|$title)?\"" $file.old > $file

			# Reset the management state of the window combination
			yabai -m rule --add manage=on  label="on:$app|$title" app="^$app$" title="^$title$"
			yabai -m rule --remove "on:$app|$title"

			echo "Managing the window again."
		fi
	else
		echo "$trunc_bottom" | egrep -v "label=\"on:$app\|$title\"" > $file
		echo "yabai -m rule --add manage=off label=\"off:$app|$title\" app=\"^$app\$\" title=\"^$title\$\"" >> $file
		echo "" >> $file
		echo "echo \"yabai configuration loaded...\"" >> $file

		yabai -m rule --add manage=off label="off:$app|$title" app="^$app$" title="^$title$"

		echo "No longer managing the window."
	fi
fi

