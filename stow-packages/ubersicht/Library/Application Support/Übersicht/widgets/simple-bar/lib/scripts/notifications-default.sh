#!/bin/bash

database="$1"
apps="$2"
count="$(echo "SELECT json_group_array(json_object('identifier', identifier, 'badge', badge)) FROM app WHERE identifier in ('$apps');" | sqlite3 "$database")"

echo "$count"
