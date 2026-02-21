#!/bin/zsh

json=$1
minifiedJson="$(jq -c . < ${json})"
base64="$(echo ${minifiedJson} | base64)"
baseUrl="karabiner://karabiner/assets/complex_modifications/import?url=data:application/json;charset=utf-8;base64,"
fullUrl=${baseUrl}${base64}

open "$fullUrl"
