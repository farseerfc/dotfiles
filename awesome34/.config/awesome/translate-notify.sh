#!/bin/sh
#STYLE="/home/farseerfc/.config/awesome/awesome.outlang"
word=`xsel`
ydcv=`translate {=zh,en} \"$word\"`
notify-send -t 30000 "Google" "$ydcv"
