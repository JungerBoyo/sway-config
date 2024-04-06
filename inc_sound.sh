#!/bin/sh

# $1 = inc value in %
# $2 = sound to play after inc

amixer -q sset Master ${1}%+ -M unmute

sync

if [ -n "$2" ]; then
    aplay -q $2
fi
