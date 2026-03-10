#!/bin/sh
/usr/local/bin/aerospace list-workspaces --focused >~/.aerospace.fw
/usr/local/bin/aerospace list-monitors --focused | awk '{print $1}' >~/.aerospace.fm
/usr/local/bin/aerospace list-workspaces --monitor "$(cat ~/.aerospace.fm)" | wc -l | awk '{print $1}' >~/.aerospace.nw
