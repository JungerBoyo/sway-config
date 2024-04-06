#!/bin/bash

. $HOME/.config/sway/status-config.sh

TIME_UPDATE_COUNTER=0
DATE_UPDATE_COUNTER=0
BAT_UPDATE_COUNTER=0
NET_UPDATE_COUNTER=0
SOUND_UPDATE_COUNTER=0
MEM_UPDATE_COUNTER=0
WEATHER_UPDATE_COUNTER=0

TIME_FMT=""
DATE_FMT=""
BAT_FMT=""
NET_FMT=""
SOUND_FMT=""
MEM_FMT=""
WEATHER_FMT=""

getBat() {
    POWER_SUPPLY_CAPACITY=$(cat "$BAT_UEVENT_PATH" | grep CAPACITY= | awk -F '=' '{print$2}')
    POWER_SUPPLY_STATUS=$(cat "$BAT_UEVENT_PATH" | grep STATUS= | awk -F '=' '{print$2}')

    local bat_capacity_emoji=""
    if [ $POWER_SUPPLY_CAPACITY -le 20 ]; then
        bat_capacity_emoji="$BAT_LOW_TAG"
    else
        bat_capacity_emoji="$BAT_HIGH_TAG"
    fi

    local bat_status_emoji=""
    case "${POWER_SUPPLY_STATUS}" in
    "Charging")
        bat_status_emoji="$BAT_STATE_CHARGING_TAG"
    ;;
    "Discharging")
        bat_status_emoji="$BAT_STATE_DISCHARGING_TAG"
    ;;
    *)
        bat_status_emoji="$BAT_STATE_UNKNOWN_TAG"
    ;;
    esac
    echo "$bat_capacity_emoji~$POWER_SUPPLY_CAPACITY%$bat_status_emoji"
    return 0

}
getTime() {
    if [ $TIME_INCLUDE_SECONDS -eq 1 ]; then
        echo "${TIME_TAG} $(date "+%a %T")"
    else
        echo "${TIME_TAG} $(date "+%a %H:%M")"
    fi
    return 0
}
getDate() {
    echo "${DATE_TAG} $(date "+%d %b %Y")"
    return 0
}
getNet() {
    local eth0_state=$(ip -brief address | grep eth0 | awk '{print$2}')
    local wlp2s0_state=$(ip -brief address | grep wlp2s0 | awk '{print$2}')
   
    if [[ "$eth0_state" == "UP" ]]; then
        local conn=$(nmcli dev show wlp2s0 | grep CONNECTION | awk '{print$2}')
        local address=$(nmcli dev show wlp2s0 | grep "IP4\.ADDRESS\[1\]" | awk '{print$2}')
        echo "$address | $NET_ETHERNET_TAG $conn"
        return 0
    else
        if [[ "$wlp2s0_state" == "UP" ]]; then
            local ssid=$(nmcli dev show wlp2s0 | grep CONNECTION | awk '{print$2}')
            local address=$(nmcli dev show wlp2s0 | grep "IP4\.ADDRESS\[1\]" | awk '{print$2}')
            echo "$address | $NET_WIFI_TAG $ssid"
            return 0
        fi
    fi

    echo "?.?.?.? | $NET_UNKNOWN_TAG ?????"
    return 0
}
getSound() {
    local state=($(amixer -D $SOUND_CARD sget $SOUND_MIXER | grep -E "\[[0-9]+%\]" | head -n 1 | awk '{print$5} {print$6}' | tr -d '\]&&\[&&\%'))
    local sound_state=${state[0]}
    local mute_state=${state[1]}
    
    local amp_emoji=""
    if [ $sound_state -ge 75 ]; then
        amp_emoji=$SOUND_HIGH_TAG
    elif [ $sound_state -le 25 ]; then
        amp_emoji=$SOUND_LOW_TAG
    else
        amp_emoji=$SOUND_MEDIUM_TAG
    fi
    
    if [[ $mute_state == "off" ]]; then
        amp_emoji=$SOUND_MUTE_TAG
    fi

    echo "$amp_emoji$sound_state%"
    return 0
}
getMem() {
    local mem=($(cat "$MEM_INFO_PATH" | grep -E "MemTotal|MemAvailable" | awk '{print$2}'))
    local mem_used=$(( (mem[0] - mem[1]) / 1000 ))
    echo "$MEM_TAG~$mem_used"MB""
    return 0
}
getWeather() {
    local header="X-Api-Key: $WEATHER_X_API_KEY"
    local url="https://api.api-ninjas.com/v1/weather?city=$WEATHER_CITY"
    local answer="$(curl -s --header "$header" "$url")"
    local data=($(echo ${answer//: /:} | tr ' ' '\n' | tr -d ',&&\"&&\{&&\}' | grep -E "^temp|feels_like|humidity|sunset"))

    local temp=$(echo ${data[0]} | tr -cd [:digit:])
    local feels_like=$(echo ${data[1]} | tr -cd [:digit:])
    local humidity=$(echo ${data[2]} | tr -cd [:digit:])
    local sunset=$(echo ${data[3]} | tr -cd [:digit:])

    local temp_emoji=""
    if [ $temp -le $WEATHER_TEMP_COLD_THRESHOLD ]; then
        temp_emoji=$WEATHER_TEMP_LOW_TAG
    elif [ $temp -ge $WEATHER_TEMP_HOT_THRESHOLD ]; then
        temp_emoji=$WEATHER_TEMP_HIGH_TAG
    else
        temp_emoji=$WEATHER_TEMP_MEDIUM_TAG
    fi
    
    echo "$temp_emoji$temp($feels_like) $WEATHER_HUMIDITY_TAG$humidity $WEATHER_SUNSET_TAG$(date -d @${sunset} "+%H:%M")"
}

getExecute() {
    local enable=$1
    local -n counter=$2
    local period=$3
    local func="$4"
    if [ $enable -eq 1 ]; then
        if [ $counter -eq 0 ]; then
            eval "$func"
        elif [ $counter -eq $period ]; then
            counter=0
            return 0
        fi
        ((counter++))
    fi
    return 0
}
update() {
    local -n fmt=$1
    local result=$2
    if [ ! -z "$result" ]; then
        echo $result
        fmt="$result"
    fi
}

getFullFmt() {
    update "TIME_FMT" "$(getExecute $TIME_ENABLE "TIME_UPDATE_COUNTER" $DATE_TIME_UPDATE_PERIOD "getTime")"
    update "DATE_FMT" "$(getExecute $DATE_ENABLE "DATE_UPDATE_COUNTER" $DATE_TIME_UPDATE_PERIOD "getDate")"
    update "BAT_FMT" "$(getExecute $BAT_ENABLE "BAT_UPDATE_COUNTER" $BAT_UPDATE_PERIOD "getBat")"
    update "NET_FMT" "$(getExecute $NET_ENABLE "NET_UPDATE_COUNTER" $NET_UPDATE_PERIOD "getNet")"
    update "SOUND_FMT" "$(getExecute $SOUND_ENABLE "SOUND_UPDATE_COUNTER" $SOUND_UPDATE_PERIOD "getSound")"
    update "MEM_FMT" "$(getExecute $MEM_ENABLE "MEM_UPDATE_COUNTER" $MEM_UPDATE_PERIOD "getMem")"
#    update "WEATHER_FMT" "$(getExecute $WEATHER_ENABLE "WEATHER_UPDATE_COUNTER" $WEATHER_UPDATE_PERIOD "getWeather")"

    echo "[$WEATHER_FMT] [$MEM_FMT] [$SOUND_FMT] [$NET_FMT] [$DATE_FMT] [$TIME_FMT] [$BAT_FMT]"
}

while true; do
    sleep 1
    echo "$(getFullFmt)"
done
