#!/bin/sh

# $1 = dec value in %
# $2 = sound to play after dec

amixer -q sset Master ${1}%- -M

sync

if [ -n "$2" ]; then
    aplay -q $2
fi
