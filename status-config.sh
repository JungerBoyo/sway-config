#!/bin/bash

#################
## TIME CONFIG ##
#################
export DATE_TIME_UPDATE_PERIOD=1
export TIME_ENABLE=1
export TIME_INCLUDE_SECONDS=0
export TIME_TAG="🕒"
export DATE_ENABLE=1
export DATE_ORDER_INDEX=1
export DATE_TAG="📅"
################
## BAT CONFIG ##
################
export BAT_ENABLE=1
export BAT_UPDATE_PERIOD=1
export BAT_UEVENT_PATH="/sys/class/power_supply/BAT0/uevent"
export BAT_LOW_TAG="🪫"
export BAT_HIGH_TAG="🔋"
export BAT_STATE_CHARGING_TAG="😀"
export BAT_STATE_DISCHARGING_TAG="🫠"
export BAT_STATE_UNKNOWN_TAG="🧐"
################
## NET CONFIG ##
################
export NET_ENABLE=1
export NET_INCLUDE_IP_ADDRESS=0
export NET_UPDATE_PERIOD=1
export NET_WIFI_TAG="🛜"
export NET_ETHERNET_TAG="🪱"
export NET_UNKNOWN_TAG="🤷"
##################
## SOUND CONFIG ##
##################
export SOUND_ENABLE=1
export SOUND_UPDATE_PERIOD=1
export SOUND_CARD="default"
export SOUND_MIXER="Master"
export SOUND_LOW_TAG="🔈"
export SOUND_MEDIUM_TAG="🔉"
export SOUND_HIGH_TAG="🔊"
export SOUND_MUTE_TAG="🔇"
################
## MEM CONFIG ##
################
export MEM_ENABLE=1
export MEM_UPDATE_PERIOD=1
export MEM_INFO_PATH="/proc/meminfo"
export MEM_TAG="♎"
####################
## WEATHER CONFIG ##
####################
export WEATHER_ENABLE=1
export WEATHER_UPDATE_PERIOD=$((3 * 60 * 60))
export WEATHER_X_API_KEY="$(cat $HOME/.config/sway/xapikey.txt)"
export WEATHER_CITY="Bialystok"
export WEATHER_TEMP_COLD_THRESHOLD=9
export WEATHER_TEMP_HOT_THRESHOLD=25
export WEATHER_TEMP_HIGH_TAG="🥵"
export WEATHER_TEMP_MEDIUM_TAG="👌"
export WEATHER_TEMP_LOW_TAG="🥶"
export WEATHER_HUMIDITY_TAG="💧"
export WEATHER_SUNSET_TAG="🌇"
######################
## MOUSE POS CONFIG ##
######################
# export MOUSE_POS_ENABLE=1
# export MOUSE_POS_TAG="🐭"
