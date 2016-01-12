#!/bin/bash -e
word=$(xsel)
ydcv=$(ydcv "$word" --color always | 
aha -n | sed \
  -e '/^<span[^>]*>/N' \
  -e 's/\n/<br>/' \
  -e 's/style="color:/color="/g' \
  -e 's/style="text-decoration:underline;/color="#990000/g' \
  -e 's/olive;/#3333ff/g' \
  -e 's/teal;/#999900/g' \
  -e 's/purple;/#009900/g' \
  -e '/>\s*Online Resource:/,$d' \
  -e 's/<br>/\n/')
meaning=$(echo -e "$ydcv\n")
echo $(notify-desktop -r $(grep -o '^[0-9]*' /tmp/ydcv-notifyid || echo 0) -t 30000 "ydcv: $word" "$meaning") >/tmp/ydcv-notifyid
